function run_case_study_C(path_to_result_csv; nlsolver::Any="ipopt", ipopt_lin_sol::String="mumps", tolerance::Float64=1e-5, gurobi_lic::Bool=false, set_rescaler = 100, power_base::Float64=1e5)

    # Input data
    rm_transfo = true
    rd_lines = true

    season = "summer"
    time = 144
    elm = ["load", "pv"]
    pfs = [0.95, 0.90]

    ################################################################################

    # Set path
    msr_path = joinpath(mktempdir(),"temp.csv")

    # Set solve
    if nlsolver == "ipopt"
        solver = _PMD.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                                "tol"=>tolerance,
                                                                "print_level"=>0,
                                                                "linear_solver"=>ipopt_lin_sol)
    else
        solver = _PMD.optimizer_with_attributes(nlsolve...)
    end

    lin_se_solver = gurobi_lic ? _PMD.optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit"=>180.0) : solver

    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
    termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
            solver = String[], tol = Any[])

    for ntw in 1:25 for fdr in 1:10
        data_path = _PMDSE.get_enwl_dss_path(ntw, fdr)
        if !isdir(dirname(data_path)) break end

        # Load the data
        data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(ntw, fdr),data_model=_PMD.ENGINEERING);
        if rm_transfo _PMDSE.rm_enwl_transformer!(data) end
        if rd_lines _PMDSE.reduce_enwl_lines_eng!(data) end
        data["settings"]["sbase_default"] = power_base

        # Insert the load profiles
        _PMDSE.insert_profiles!(data, season, elm, pfs, t = time)

        # Transform data model
        data = _PMD.transform_data_model(data);

        # Solve the ivr  power flow for linear
        pf_results_ivr = _PMD.solve_mc_pf(data, _PMD.IVRUPowerModel, solver)
        _PMDSE.write_measurements!(_PMD.IVRUPowerModel, data, pf_results_ivr, msr_path)
        _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 1)
        _PMDSE.assign_start_to_variables!(data)
        _PMDSE.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

        # Set se settings
        data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                                "rescaler" => set_rescaler)

        linear_se_results = _SEF.run_linear_ivr_red_mc_se(data, lin_se_solver)

        pf_results_nl = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, solver)
        _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results_nl, msr_path)
        _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 1)
        _PMDSE.assign_start_to_variables!(data)
        _PMDSE.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

        # Set se settings
        data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                                    "rescaler" => set_rescaler)

        se_results = _PMDSE.solve_mc_se(data, _PMDSE.ReducedIVRUPowerModel, solver)

        # PRINT
        push!(df, [ntw, fdr, linear_se_results["solve_time"], length(data["bus"]),
                string(linear_se_results["termination_status"]),
                linear_se_results["objective"], "rwlav", set_rescaler, "linIVR", string(lin_se_solver.optimizer_constructor)[1:end-9], tolerance])

        push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                string(se_results["termination_status"]),
                se_results["objective"], "rwlav", set_rescaler, "rIVR", ipopt_lin_sol, tolerance])

    end end #loop through feeder and network
    CSV.write(path_to_result_csv, df)
end