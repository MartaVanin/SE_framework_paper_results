# Load Pkgs
using Ipopt, Gurobi
using DataFrames, CSV
using JuMP, PowerModels, PowerModelsDistribution
using PowerModelsSE, Distributions
include("linear_ivr_functions.jl")

# Define Pkg cte
const _DF = DataFrames
const _JMP = JuMP
const _PMs = PowerModels
const _PMD = PowerModelsDistribution
const _PMS = PowerModelsDistributionStateEstimation
const _DST = Distributions

################################################################################

# Input data
models = [_PMS.ReducedIVRPowerModel]
abbreviation = ["rIVR"]
rm_transfo = true
rd_lines = true
set_criterion = "rwlav"
rescalers = [1000]
seeds = 1

season = "summer"
time = 144
elm = ["load", "pv"]
pfs = [0.95, 0.90]

################################################################################

# Set path
msr_path = joinpath(BASE_DIR,"test/data/enwl/measurements/temp.csv")
# Set solve
linear_solver = "MA27"
tolerance = 1e-5
solver = _JMP.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                        "tol"=>tolerance,
                                                        "print_level"=>0,
                                                        "linear_solver"=>linear_solver)

solver_linear = _JMP.optimizer_with_attributes(Gurobi.Optimizer,"TimeLimit"=>180.0)

for i in 1:length(models)
    mod = models[i]
    short = abbreviation[i]
    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
                   termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                        linear_solver = String[], tol = Any[])


    for set_rescaler in rescalers
        for ntw in 1:25 for fdr in 1:10
            data_path = _PMS.get_enwl_dss_path(ntw, fdr)
            if !isdir(dirname(data_path)) break end

            # Load the data
            data = _PMD.parse_file(_PMS.get_enwl_dss_path(ntw, fdr),data_model=_PMD.ENGINEERING);
            if rm_transfo _PMS.rm_enwl_transformer!(data) end
            if rd_lines _PMS.reduce_enwl_lines_eng!(data) end

            # Insert the load profiles
            _PMS.insert_profiles!(data, season, elm, pfs, t = time)

            # Transform data model
            data = _PMD.transform_data_model(data);

            # Set se settings
            data["se_settings"] = Dict{String,Any}("estimation_criterion" => set_criterion,
                                       "weight_rescaler" => set_rescaler)

            # Solve the ivr  power flow for linear
            pf_results_ivr = _PMD.run_mc_pf(data, _PMs.IVRPowerModel, solver)
            _PMS.write_measurements!(_PMD.IVRPowerModel, data, pf_results_ivr, msr_path)
            _PMS.add_measurements!(data, msr_path, actual_meas = false, seed = seeds)
            _PMS.assign_start_to_variables!(data)
            _PMS.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

            linear_se_results = run_linear_ivr_red_mc_se(data, solver_linear)

            pf_results_nl = _PMD.run_mc_pf(data, _PMs.ACPPowerModel, solver)
            _PMS.write_measurements!(_PMD.ACPPowerModel, data, pf_results_nl, msr_path)
            _PMS.add_measurements!(data, msr_path, actual_meas = false, seed = seeds)
            _PMS.assign_start_to_variables!(data)
            _PMS.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

			se_results = _PMS.run_mc_se(data, _PMS.ReducedIVRPowerModel, solver)

            # PRINT
            push!(df, [ntw, fdr, linear_se_results["solve_time"], length(data["bus"]),
                     string(linear_se_results["termination_status"]),
                     linear_se_results["objective"], set_criterion, set_rescaler, short, "gurobi", tolerance])
            push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                     string(se_results["termination_status"]),
                     se_results["objective"], set_criterion, set_rescaler, short, "ma27", tolerance])

       end end #loop through feeder and network
    end #rescaler loop

    CSV.write("case_study_3.csv", df)
end #end models loop
