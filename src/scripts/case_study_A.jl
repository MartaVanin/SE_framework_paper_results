
function run_case_study_A(path_to_result_csv::String; solver::Any="ipopt", ipopt_lin_sol::String="mumps", tolerance::Float64=1e-5, set_rescaler::Int64 = 100, power_base::Float64=1e5)

    # Input data
    models = [_PMDSE.ReducedIVRUPowerModel, _PMDSE.ReducedACRUPowerModel, _PMDSE.ReducedACPUPowerModel]
    abbreviation = ["rIVR", "rACR", "rACP"]
    rm_transfo = true
    rd_lines = true
    criteria = ["rwlav", "wls", "rwls"]

    season = "summer"
    time_step = 144
    elm = ["load", "pv"]
    pfs = [0.95, 0.90]

    ################################################################################

    # Set path
    msr_path = joinpath(mktempdir(),"temp.csv")

    # Set solve
    if solver == "ipopt"
        pf_solver = _PMD.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                                "tol"=>tolerance,
                                                                "print_level"=>0,
                                                                "linear_solver"=>ipopt_lin_sol)
    else
        pf_solver = _PMD.optimizer_with_attributes(solver)
    end

    se_solver = pf_solver

    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
    termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
            linear_solver = String[], tol = Any[], err_max_1=Float64[], err_max_2=Float64[], err_max_3=Float64[], err_avg_1 = Float64[], err_avg_2 = Float64[], err_avg_3 = Float64[])

    for i in 1:length(models)
        mod = models[i]
        short = abbreviation[i]

        for criterion in criteria
            for ntw in 1:25 for fdr in 1:10
                data_path = _PMDSE.get_enwl_dss_path(ntw, fdr)
                if !isdir(dirname(data_path)) break end

                # Load the data
                data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(ntw, fdr),data_model=_PMD.ENGINEERING);
                if rm_transfo _PMDSE.rm_enwl_transformer!(data) end
                if rd_lines _PMDSE.reduce_enwl_lines_eng!(data) end
                data["settings"]["sbase_default"] = power_base

                # Insert the load profiles
                _PMDSE.insert_profiles!(data, season, elm, pfs, t = time_step)

                # Transform data model
                data = _PMD.transform_data_model(data);

                # Solve the power flow
                pf_results = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, se_solver)

                # Write measurements based on power flow
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

                _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results, msr_path, σ= σ_dict)

                # Read-in measurement data and set initial values
                _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 2)
                _PMDSE.assign_start_to_variables!(data)
                _PMDSE.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

                # Set se settings
                data["se_settings"] = Dict{String,Any}("criterion" => criterion,
                                        "rescaler" => set_rescaler)

                # Solve the state estimation
                se_results = _PMDSE.solve_mc_se(data, mod, pf_solver)
                delta_1, delta_2, delta_3, max_1, max_2, max_3, mean_1, mean_2, mean_3 = _SEF.calculate_voltage_magnitude_error_perphase(se_results, pf_results)

                # store result
                push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                        string(se_results["termination_status"]),
                        se_results["objective"], criterion, set_rescaler, short, ipopt_lin_sol, tolerance, max_1, max_2, max_3, mean_1, mean_2, mean_3])
            end end #loop through feeder and network
        CSV.write(path_to_result_csv, df)
        end #criterion loop
    end #end models loop
end