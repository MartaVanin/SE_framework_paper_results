function run_case_study_D(path_to_csv_result::String; ipopt_lin_sol::String="mumps", tolerance::Float64=1e-5)

    # Input data
    rm_transfo = true
    rd_lines = true

    season = "summer"
    time_step = 144
    elm = ["load", "pv"]
    pfs = [0.95, 0.90]

    msr_path = joinpath(mktempdir(),"temp.csv")
    # Set solve
    solver = _PMD.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                            "tol"=>tolerance,
                                                            "print_level"=>0,
                                                            "linear_solver"=>ipopt_lin_sol)

    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
                termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                        linear_solver = String[], tol = Any[], err_max_1=Float64[], err_max_2=Float64[], err_max_3=Float64[], err_avg_1 = Float64[], err_avg_2 = Float64[], err_avg_3 = Float64[])

    # Load the data
    data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(1, 1),data_model=_PMD.ENGINEERING);
    if rm_transfo _PMDSE.rm_enwl_transformer!(data) end
    if rd_lines _PMDSE.reduce_enwl_lines_eng!(data) end

    # Insert the load profiles
    _PMDSE.insert_profiles!(data, season, elm, pfs, t = time_step)

    # Transform data model
    data = _PMD.transform_data_model(data);

    # Solve the power flow
    pf_results = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, solver)

    # Write measurements based on power flow
    _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results, msr_path)

    # Read-in measurement data and set initial values
    _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 2)
    _PMDSE.update_all_bounds!(data; v_min = 0.85, v_max = 1.15, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

    # Set se settings
    data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                            "rescaler" => 100)

    load_ids = []
    bus_ids = []
    for (l, load) in data["load"]
        push!(load_ids, parse(Int64, l))
        push!(bus_ids, load["load_bus"])
    end

    meas_ids = []
    for i in 1:length(load_ids)
        for (m, meas) in data["meas"]
            if meas["var"] == :vm && meas["cmp_id"] == bus_ids[i]
                push!(meas_ids, m)
            elseif meas["var"] != :vm && meas["cmp_id"] == load_ids[i]
                push!(meas_ids, m)
            end
        end
    end
    delete_bus = []
    for i in 1:length(load_ids)
        se_results = _PMDSE.solve_ivr_red_mc_se(data, solver)
        se_res = deepcopy(se_results)
        pf_res = deepcopy(pf_results)

        if i != 1
            for db in delete_bus
                if db == 1
                    pf_res["solution"]["bus"]["1"] = Dict{String, Any}("vm" => [1.0, 1.0, 1.0])
                    se_res["solution"]["bus"]["1"] = Dict{String, Any}("vr" => [1.0, 1.0, 1.0])
                    se_res["solution"]["bus"]["1"]["vi"] = [0.0, 0.0, 0.0]
                else
                    delete!(se_res["solution"]["bus"], "$db")
                    delete!(pf_res["solution"]["bus"], "$db")
                end
            end
        end

        delta_1, delta_2, delta_3, max_1, max_2, max_3, mean_1, mean_2, mean_3 = _SEF.calculate_voltage_magnitude_error_perphase(se_results, pf_results)

        # store result
        push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                string(se_results["termination_status"]),
                se_results["objective"], "rwlav", 100, "rIVR", ipopt_lin_sol, tolerance, max_1, max_2, max_3, mean_1, mean_2, mean_3])
        
        push!(delete_bus, data["meas"][meas_ids[3*(i-1)+1]]["cmp_id"])
        delete!(data["meas"], meas_ids[3*(i-1)+1])
        delete!(data["meas"], meas_ids[3*(i-1)+2])
        delete!(data["meas"], meas_ids[3*(i-1)+3])
    end
    CSV.write(path_to_csv_result, df)
end