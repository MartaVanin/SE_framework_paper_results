function run_case_study_E(nlsolver)

    season = "winter"
    time_step = 144
    elm = ["load"]
    pfs = [0.95]

    msr_path = joinpath(mktempdir(),"temp.csv")

    solver = _PMD.optimizer_with_attributes(nlsolver...)

    data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(1, 2),data_model=_PMD.ENGINEERING); #EU LV feeder
    _PMDSE.rm_enwl_transformer!(data)
    _PMDSE.reduce_enwl_lines_eng!(data)
    data["settings"]["sbase_default"] = 100.0 # set power_base to convert in per unit
    _PMDSE.insert_profiles!(data, season, elm, pfs, t = time_step)

    data = _PMD.transform_data_model(data);
    _PMDSE.reduce_single_phase_loadbuses!(data, exclude = [])

    pf_results = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, solver)

    # Write measurements based on power flow
    v_pu = data["settings"]["vbases_default"]["1"]* data["settings"]["voltage_scale_factor"] # divider [V] to get the voltage in per units.
    v_max_err = 1.15
    σ_v = 1/3*v_max_err/v_pu

    p_pu = data["settings"]["sbase"] 
    p_max_err = 0.01 
    σ_p = 1/3*p_max_err/p_pu

    # Write measurements based on power flow
    σ_dict = Dict("load" => Dict("load" => σ_p,
                    "bus"  => σ_v),
                    "gen"  => Dict("gen" => σ_p/100,
                    "bus"  => σ_v/100)
                            )                

    _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results, msr_path, σ = σ_dict)

    # Read-in measurement data and set initial values
    _PMDSE.add_measurements!(data, msr_path, actual_meas = true)

    data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                                            "rescaler" => 100)

    _PMDSE.assign_start_to_variables!(data)
    _PMDSE.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

    ###############################################################
    ######                                                    #####
    ######      ADD BAD DATA AND RUN STATE ESTIMATION         #####
    ######                                                    #####
    ###############################################################

    bad_data_lav = deepcopy(data)
    bad_data_lav["meas"]["43"]["dst"] = [_DST.Normal(0.019, σ_p)]
    bad_data_lav["meas"]["53"]["dst"] = [_DST.Normal(0.01, σ_p)]
    bad_data_lav["meas"]["33"]["dst"] = [_DST.Normal(1.01, σ_v)]

    bad_data_chi = deepcopy(bad_data_lav)
    bad_data_lnr = deepcopy(bad_data_lav)

    bad_data_lav["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
    "rescaler" => 1)

    for (m, meas) in bad_data_lav["meas"]
        σ = [1.0, 1.0, 1.0]
        μ = _DST.mean.(meas["dst"])
        meas["dst"] = [_DST.Normal(μ[i], σ[i]) for i in 1:length(meas["dst"])]
    end

    deleted_data_points_lav = []
    for i in 1:4 # runs SE+chi square test+lav 4 times, three of which have a bad data point, the last one has no bad data (see paper)

        bad_data_n = [3, 2, 1, "no"]
        display("Now running SE with Chi-squares and LAV for the $i time. There are now $(bad_data_n[i]) bad data points.")

        ###############################################################
        ######                                                    #####
        ######                Chi-SQUARE ANALYSIS                 #####
        ######                                                    #####
        ###############################################################

        # NB: bad_data_chi and bad_data_lav are identical except for the SE settings: all weights are 1 in bad_data_lav, but that assumption won't work with chi square analysis
        se_result_bd = _PMDSE.solve_acp_red_mc_se(bad_data_chi, solver)
        
        excds_bd, obj_bd, trsh_bd = _PMDSE.exceeds_chi_squares_threshold(se_result_bd, bad_data_chi, suppress_display=true) 

        if excds_bd
            display("The objective of ACP state estimation WITH bad data is $(obj_bd), and exceeds the Chi-square threshold of $trsh_bd. Bad data detected.")
        else
            display("The objective of ACP state estimation WITH bad data is $(obj_bd), and does not exceed the Chi-square threshold of $trsh_bd.")
        end

        ###############################################################
        ######                                                    #####
        ###### LAV ESTIMATION AND HIGHEST RESIDUAL IDENTIFICATION #####
        ######                                                    #####
        ###############################################################

        se_result_bd_lav = _PMDSE.solve_acp_red_mc_se(bad_data_lav, solver)
        residual_tuples = [(m, maximum(meas["res"])[1]) for (m, meas) in se_result_bd_lav["solution"]["meas"]]
        sorted_tuples = sort(residual_tuples, by = last, rev = true)

        delete!(bad_data_lav["meas"], first(sorted_tuples[1]))
        delete!(bad_data_chi["meas"], first(sorted_tuples[1]))
        push!(deleted_data_points_lav, first(sorted_tuples[1]))

        display("The largest residuals and their relative measurement number are the following:")
        display(sorted_tuples[1:4])

    end

    deleted_data_points_lnr = []
    for i in 1:4 # runs LNR 4 times, three of which have a bad data point, the last one has no bad data (see paper)

        bad_data_n = [3, 2, 1, "no"]
        display("Now running SE + LNR for the $i time. There are now $(bad_data_n[i]) bad data points.")
        se_result_bd = _PMDSE.solve_acp_red_mc_se(bad_data_lnr, solver)

        ###############################################################
        ######                                                    #####
        ######           LARGEST NORMALIZED RESIDUALS             #####
        ######                                                    #####
        ###############################################################

        max_meas_idx = maximum([parse(Int64, m) for (m,meas) in data["meas"]])

        _PMDSE.add_zib_virtual_meas!(bad_data_lnr, 1e-15, exclude = [2, 1, 30, 48, 36])   
        for (_, load) in bad_data_lnr["load"]
            load["status"] = 1 
            if !haskey(load, "connections") load["connections"] = [1,2,3] end
        end
        
        variable_dict = _PMDSE.build_variable_dictionary(bad_data_lnr)
        h_array = _PMDSE.build_measurement_function_array(bad_data_lnr, variable_dict)
        state_array = _PMDSE.build_state_array(se_result_bd, variable_dict)

        H = _PMDSE.build_H_matrix(h_array, state_array)
        R = _PMDSE.build_R_matrix(bad_data_lnr)
        G = _PMDSE.build_G_matrix(H, R)
        K = _PMDSE.build_K_matrix(H, G, R)
        S = _PMDSE.build_S_matrix(K)
        Ω = _PMDSE.build_omega_matrix(S, R)

        for (m,meas) in bad_data_lnr["meas"]
            if parse(Int64, m) > max_meas_idx delete!(bad_data_lnr["meas"], m) end
        end

        id_val, exc = _PMDSE.normalized_residuals(bad_data_lnr, se_result_bd, Ω)
        lnr_tuples = [(m, maximum(se_result_bd["solution"]["meas"][m]["nr"])[1]) for (m, meas) in bad_data_lnr["meas"]]
        sorted_lnr_tuples = sort(lnr_tuples, by = last, rev = true)

        push!(deleted_data_points_lnr, first(id_val))
        bad_data_lnr = deepcopy(data)
        bad_data_lnr["meas"]["43"]["dst"] = [_DST.Normal(0.019, σ_p)]
        bad_data_lnr["meas"]["53"]["dst"] = [_DST.Normal(0.01, σ_p)]
        bad_data_lnr["meas"]["33"]["dst"] = [_DST.Normal(1.01, σ_v)]    
        for m in deleted_data_points_lnr
            delete!(bad_data_lnr["meas"], m)
        end

        display("The largest normalizes residuals and their relative measurement number are the following:")
        display(sorted_lnr_tuples[1:4])
        display("If bigger than 3, the first LNR is deleted.")

    end
end