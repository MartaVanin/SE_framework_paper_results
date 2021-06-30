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
    _PMDSE.add_measurements!(data, msr_path, actual_meas = true, seed = 2)
    data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                                            "rescaler" => 1)

    _PMDSE.assign_start_to_variables!(data)
    _PMDSE.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

    se_result = _PMDSE.solve_acp_red_mc_se(data, solver)

    ###############################################################
    ######                                                    #####
    ######    ADD BAD DATA AND RUN STATE ESTIMATION AGAIN     #####
    ######     comment out single lines in 60-62 for the      #####
    ######       different cases: bad voltage, P and Q        #####
    ###############################################################

    bad_data = deepcopy(data)
    # bad_data_point = ("28", 0.02, σ_p)
    # bad_data_point = ("53", 0.029, σ_p)
     bad_data_point = ("81", 1.005, σ_v)
    bad_data["meas"][bad_data_point[1]]["dst"] = [_DST.Normal(bad_data_point[2], bad_data_point[3])]

    se_result_bd = _PMDSE.solve_acp_red_mc_se(bad_data, solver)

    ###############################################################
    ######                                                    #####
    ######                Chi-SQUARE ANALYSIS                 #####
    ######                                                    #####
    ###############################################################

    # FIRST WITHOUT BAD DATA, TO CHECK THAT NO BAD DATA ARE DETECTED #
    excds, obj, trsh = _PMDSE.exceeds_chi_squares_threshold(se_result, data, suppress_display=true)

    if !excds
        display("The objective of ACP state estimation WITHOUT bad data is $(obj), and does not exceed the Chi-square threshold of $trsh. Thus, no bad data detected (correct).")
    else
        display("The objective of ACP state estimation WITHOUT bad data is $(obj), and exceeds the Chi-square threshold of $trsh. This result does not match the paper result. Please check the code/package settings, or try to ask the authors.")
    end

    # NOW WITH BAD DATA #
    excds_bd, obj_bd, trsh_bd = _PMDSE.exceeds_chi_squares_threshold(se_result_bd, bad_data, suppress_display=true) 

    if excds_bd
        display("The objective of ACP state estimation WITH bad data is $(obj_bd), and exceeds the Chi-square threshold of $trsh_bd. Bad data detected.")
    else
        display("The objective of ACP state estimation WITH bad data is $(obj_bd), and does not exceed the Chi-square threshold of $trsh_bd. This result does not match the paper result. Please check the code/package settings, or try to ask the authors.")
    end

    ###############################################################
    ######                                                    #####
    ###### LAV ESTIMATION AND HIGHEST RESIDUAL IDENTIFICATION #####
    ######                                                    #####
    ###############################################################

    bad_data["se_settings"] = Dict{String,Any}("criterion" => "lav",
                                            "rescaler" => 1)

    se_result_bd_lav = _PMDSE.solve_acp_red_mc_se(bad_data, solver)
    residual_tuples = [(m, maximum(meas["res"])[1]) for (m, meas) in se_result_bd_lav["solution"]["meas"]]
    sorted_tuples = sort(residual_tuples, by = last, rev = true)

    if first(sorted_tuples[1]) == bad_data_point[1]
        display("The LAV state estimation with bad data finds that measurement $(bad_data_point[1]) has the highest residual: $(last(sorted_tuples[1])), which is $(last(sorted_tuples[1])/last(sorted_tuples[2])) times larger than the second largest residual. Bad data point correctly identified.")
    else
        display("The LAV state estimation with bad data finds that measurement $(first(sorted_tuples[1])) has the largest residual. This is wrong and does not match the paper result. Please check the code/package settings, or try to ask the authors.")
    end

    ###############################################################
    ######                                                    #####
    ######           LARGEST NORMALIZED RESIDUALS             #####
    ######                                                    #####
    ###############################################################

    ## FIRST WITHOUT BAD DATA ##

    _PMDSE.add_zib_virtual_meas!(data, 1e-15, exclude = [2, 1, 30, 48, 36])
    for (l, load) in data["load"]
        load["status"] = 1 
        if !haskey(load, "connections") load["connections"] = [1,2,3] end
    end
    _PMDSE.add_zib_virtual_residuals!(se_result, data)
    variable_dict = _PMDSE.build_variable_dictionary(data)
    h_array = _PMDSE.build_measurement_function_array(data, variable_dict)
    state_array = _PMDSE.build_state_array(se_result, variable_dict)

    H = _PMDSE.build_H_matrix(h_array, state_array)
    R = _PMDSE.build_R_matrix(data)
    G = _PMDSE.build_G_matrix(H, R)
    Ω = _PMDSE.build_omega_matrix(R, H, G)

    id_val, exc = _PMDSE.normalized_residuals(data, se_result, Ω)    

    if !exc
        display("The largest normalized residual method does not detect bad data in this case. This is correct at this stage.")
    else
        display("Largest normalized residuals detect bad data but there are not. This is not the expected result.")
    end

    ## THEN WITH BAD DATA ##

    _PMDSE.add_zib_virtual_meas!(bad_data, 1e-15, exclude = [2, 1, 30, 48, 36])   
    for (l, load) in bad_data["load"]
        load["status"] = 1 
        if !haskey(load, "connections") load["connections"] = [1,2,3] end
    end
    _PMDSE.add_zib_virtual_residuals!(se_result_bd, bad_data)
    
    variable_dict = _PMDSE.build_variable_dictionary(bad_data)
    h_array = _PMDSE.build_measurement_function_array(bad_data, variable_dict)
    state_array = _PMDSE.build_state_array(se_result_bd, variable_dict)

    H = _PMDSE.build_H_matrix(h_array, state_array)
    R = _PMDSE.build_R_matrix(bad_data)
    G = _PMDSE.build_G_matrix(H, R)
    Ω = _PMDSE.build_omega_matrix(R, H, G)

    id_val, exc = _PMDSE.normalized_residuals(bad_data,se_result_bd, Ω)

    if !exc 
        display("The largest normalized residual method does not detect bad data in this case. This is not correct and is not the expected result.")
    elseif id_val[1] != bad_data_point[1]
        display("Largest normalized residuals detect bad data but thinks the bad data point is $(id_val[1]) instead of $(bad_data_point[1]). This is not correct and is not the expected result.")
    else
        display("Largest normalized residuals correctly detects that $(bad_data_point[1]) is a bad data point.")
    end

end