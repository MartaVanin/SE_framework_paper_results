function run_case_study_E(nlsolver; power_base::Float64=1e5)

    solver = _PMD.optimizer_with_attributes(nlsolver...)

    msr_path = mktempdir()*"temp.csv"

    data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(1, 2),data_model=_PMD.ENGINEERING); #EU LV feeder
    _PMDSE.rm_enwl_transformer!(data)
    _PMDSE.reduce_enwl_lines_eng!(data)
    data["settings"]["sbase_default"] = power_base

    # Insert the load profiles
    _PMDSE.insert_profiles!(data, "summer", ["load", "pv"], [0.95, 0.90], t = 144)

    # Transform data model
    data = _PMD.transform_data_model(data);
    _PMDSE.reduce_single_phase_loadbuses!(data)

    # Solve the power flow to create the measurements
    pf_results = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, solver)

    for (l,load) in data["load"]
        delete!(load, "pd")
        delete!(load, "qd")
    end

    v_pu = data["settings"]["vbases_default"]["1"]* data["settings"]["voltage_scale_factor"] # divider [V] to get the voltage in per units.
    v_max_err = 1.15 # maximum error of voltage measurement = 0.5% or 1.15 V
    σ_v = 1/3*v_max_err/v_pu

    p_pu = data["settings"]["sbase"] # divider [kW] to get the power in per units.
    p_max_err = 0.01 # maximum error of power measurement = 10W, or 0.01 kW
    σ_p = 1/3*p_max_err/p_pu

    # Write measurements based on power flow
    σ_dict = Dict("load" => Dict("load" => σ_p,
                    "bus"  => σ_v),
                    "gen"  => Dict("gen" => σ_p,
                    "bus"  => σ_v)
                            )

    _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results, msr_path, σ=σ_dict)

    # Read-in measurement data and set initial values
    _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 2)

    df = _DF.DataFrame(form=String[], resc = [], crit = [], nobd_obj = [], nobd_conv=[], bd_obj = [], bd_conv = [], power_base=[])

    for rsc in [1, 10, 100 ,1000, 10000, 100000]
        for crit in ["rwls", "wlav", "rwlav", "wls"]
            # Set se settings
            data["se_settings"] = Dict{String,Any}("criterion" => crit,
                                    "rescaler" => rsc)

            # run SE with no bad data, and see that indeed no bad data is detected

            se_result_acr = _PMDSE.solve_acr_red_mc_se(data, solver)
            se_result_ivr = _PMDSE.solve_ivr_red_mc_se(data, solver)
            se_result_acp = _PMDSE.solve_acp_red_mc_se(data, solver)
            #excds, obj, trsh = _PMDSE.exceeds_chi_squares_threshold(se_result, data, rescaler = rsc) #if excds = true, the chi-square test indicate that there are bad data

            #adds bad data point
            bad_data = deepcopy(data)
            bad_data["meas"]["28"]["dst"] = [_DST.Normal(2.5e-4, σ_p)]
            se_result_acr_bd = _PMDSE.solve_acr_red_mc_se(bad_data, solver)
            se_result_ivr_bd = _PMDSE.solve_ivr_red_mc_se(bad_data, solver)
            se_result_acp_bd = _PMDSE.solve_acp_red_mc_se(bad_data, solver)

            push!(df, ["acr", rsc, crit, se_result_acr["objective"], se_result_acr["termination_status"], se_result_acr_bd["objective"], se_result_acr_bd["termination_status"], power_base])
            push!(df, ["acp", rsc, crit, se_result_acp["objective"], se_result_acp["termination_status"], se_result_acp_bd["objective"], se_result_acp_bd["termination_status"], power_base])
            push!(df, ["ivr", rsc, crit, se_result_ivr["objective"], se_result_ivr["termination_status"], se_result_ivr_bd["objective"], se_result_ivr_bd["termination_status"], power_base])
            
            #excds, obj, trsh = _PMDSE.exceeds_chi_squares_threshold(se_result_bd, bad_data, rescaler = rsc) #if excds = true, the chi-square test indicate that there are bad data
        end
    end
    CSV.write(pwd()*"case_e_res_$(power_base).csv", df)
end
