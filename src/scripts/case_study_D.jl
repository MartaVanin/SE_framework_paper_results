################################################################################
#  Copyright 2021, Marta Vanin                                                 #
################################################################################
function run_case_study_D(path_to_csv_result::String, nlsolver; power_base::Float64=1e5, rsc::Int64=100)

    # Input data
    rm_transfo = true
    rd_lines = true

    season = "summer"
    time_step = 144
    elm = ["load", "pv"]
    pfs = [0.95, 0.90]

    msr_path = joinpath(mktempdir(),"temp.csv")
    # Set solve
    solver = _PMD.optimizer_with_attributes(nlsolver...)

    df = _DF.DataFrame(solve_time=Float64[], n_bus=Int64[],
                termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                     err_max_1=Float64[], err_max_2=Float64[], err_max_3=Float64[], err_avg_1 = Float64[], err_avg_2 = Float64[], err_avg_3 = Float64[], n_meas = Float64[], pbase=Float64[])

    # Load the data
    data = _PMD.parse_file(_PMDSE.get_enwl_dss_path(1, 1),data_model=_PMD.ENGINEERING);
    if rm_transfo _PMDSE.rm_enwl_transformer!(data) end
    if rd_lines _PMDSE.reduce_enwl_lines_eng!(data) end
    data["settings"]["sbase_default"] = power_base

    # Insert the load profiles
    _PMDSE.insert_profiles!(data, season, elm, pfs, t = time_step)

    # Transform data model
    data = _PMD.transform_data_model(data);

    # Solve the power flow
    pf_results = _PMD.solve_mc_pf(data, _PMD.ACPUPowerModel, solver)

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

    _PMDSE.write_measurements!(_PMD.ACPUPowerModel, data, pf_results, msr_path, σ = σ_dict)

    # Read-in measurement data and set initial values
    _PMDSE.add_measurements!(data, msr_path, actual_meas = false, seed = 2)

    # Set se settings
    data["se_settings"] = Dict{String,Any}("criterion" => "rwlav",
                            "rescaler" => rsc)

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

        delta_1, delta_2, delta_3, max_1, max_2, max_3, mean_1, mean_2, mean_3 = _PMDSE.calculate_voltage_magnitude_error_perphase(se_results, pf_results)

        # store result
        push!(df, [se_results["solve_time"], length(data["bus"]),
                string(se_results["termination_status"]),
                se_results["objective"], "rwlav", rsc, "rIVR", max_1, max_2, max_3, mean_1, mean_2, mean_3, length(data["meas"]), power_base])
        
        push!(delete_bus, data["meas"][meas_ids[3*(i-1)+1]]["cmp_id"])
        delete!(data["meas"], meas_ids[3*(i-1)+1])
        delete!(data["meas"], meas_ids[3*(i-1)+2])
        delete!(data["meas"], meas_ids[3*(i-1)+3])
    end
    CSV.write(path_to_csv_result, df)
end