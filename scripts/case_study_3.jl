# #!/home/adrian03/julia-1.5.2/bin/julia
#
# cd("/home/adrian03/StateEstimationScripts")
#
# using Pkg
# pkg"activate ."

# Load Pkgs
using Ipopt, Gurobi
using DataFrames, CSV
using JuMP, PowerModels, PowerModelsDistribution
using PowerModelsDistributionStateEstimation, Distributions

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
rescalers = 100
seeds = 2

season = "summer"
time = 144
elm = ["load", "pv"]
pfs = [0.95, 0.90]

################################################################################

# Set path
msr_path = joinpath("C:/Users/mvanin/Desktop/repos/temp.csv")
# Set solve
linear_solver = "mumps"
tolerance = 1e-5
solver = _JMP.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                        "tol"=>tolerance,
                                                        "print_level"=>0,
                                                        "linear_solver"=>linear_solver)

solver_linear = _JMP.optimizer_with_attributes(Cbc.Optimizer,"seconds"=>180.0)

display("You are launching a simulation with rm_transfo: $(string(rm_transfo)) and rd_lines: $(string(rd_lines)), criterion: $(set_criterion), variable rescaler, linear solver : $linear_solver")

for i in 1:length(models)
    mod = models[i]
    short = abbreviation[i]
    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
                   termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                        linear_solver = String[], tol = Any[], err_max= Float64[], err_avg = Float64[], seed = Int64[])


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

        # Solve the power flow
        pf_results = _PMD.run_mc_pf(data, _PMs.IVRPowerModel, solver)

        # Write measurements based on power flow
        _PMS.write_measurements!(_PMD.IVRPowerModel, data, pf_results, msr_path)
        _PMS.write_measurements!(_PMD.ACRPowerModel, data, pf_results, msr_path)

        # Read-in measurement data and set initial values
        _PMS.add_measurements!(data, msr_path, actual_meas = false, seed = current_seed)
        _PMS.assign_start_to_variables!(data)
        _PMS.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

        # Set se settings
        data["se_settings"] = Dict{String,Any}("estimation_criterion" => set_criterion,
                                   "weight_rescaler" => rescalers)

        se_results = run_linear_ivr_red_mc_se(data, solver_linear)

        delta, max_err, avg = _PMS.calculate_voltage_magnitude_error(se_results, pf_results)

        # PRINT
        push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                 string(se_results["termination_status"]),
                 se_results["objective"], set_criterion, rescalers, short, linear_solver, tolerance, max_err, avg, seeds])
   end end #loop through feeder and network
    CSV.write("/home/adrian03/StateEstimationScripts/$(short)_PQVm_werrors.csv", df)
end #end models loop
