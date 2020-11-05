#!/home/adrian03/julia-1.5.2/bin/julia

cd("/home/adrian03/StateEstimationScripts")

using Pkg
pkg"activate ."

# Load Pkgs
using Ipopt, Gurobi
using DataFrames, CSV
using JuMP, PowerModels, PowerModelsDistribution
using PowerModelsSE

# Define Pkg cte
const _DF = DataFrames
const _JMP = JuMP
const _PMs = PowerModels
const _PMD = PowerModelsDistribution
const _PMS = PowerModelsSE

################################################################################

# Input data
models = [_PMD.LinDist3FlowPowerModel, _PMS.ReducedIVRPowerModel]
abbreviation = ["LD3F","rIVR"]
rm_transfo = true
rd_lines = true
criteria = ["wls", "rwls", "rwlav"]
set_rescaler = 100

season = "summer"
time_step = 144
elm = ["load", "pv"]
pfs = [0.95, 0.90]

################################################################################

# Set path
msr_path = joinpath(BASE_DIR,"test/data/enwl/measurements/temp.csv")
#NB depending on the OS settings, the user might not have permission to write the temp.csv file in this folder
#NB if so, a differente msr_path needs to be set, such as: msr_path= joinpath(pwd(), "/temp.csv")
# Set solve
tolerance = 1e-5
pf_solver = _JMP.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                        "tol"=>tolerance,
                                                        "print_level"=>0,
                                                        "linear_solver"=>"MA27")

se_solver = _JMP.optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit"=>180.0)

display("You are launching a simulation with rm_transfo: $(string(rm_transfo)) and rd_lines: $(string(rd_lines)), criterion: $(set_criterion), variable rescaler, linear solver : $linear_solver")

for i in 1:length(models)
    mod = models[i]
    short = abbreviation[i]
    df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
                   termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                        linear_solver = String[], tol = Any[], err_max= Float64[], err_avg = Float64[], seed = Int64[])

    for set_criterion in criteria
        for ntw in 1:25 for fdr in 1:10
            data_path = _PMS.get_enwl_dss_path(ntw, fdr)
            if !isdir(dirname(data_path)) break end

            # Load the data
            data = _PMD.parse_file(_PMS.get_enwl_dss_path(ntw, fdr),data_model=_PMD.ENGINEERING);
            if rm_transfo _PMS.rm_enwl_transformer!(data) end
            if rd_lines _PMS.reduce_enwl_lines_eng!(data) end

            # Insert the load profiles
            _PMS.insert_profiles!(data, season, elm, pfs, t = time_step)

            # Transform data model
            data = _PMD.transform_data_model(data);

            # Solve the power flow
            pf_results = _PMD.run_mc_pf(data, _PMs.ACPPowerModel, pf_solver)

            # Write measurements based on power flow
            _PMS.write_measurements!(_PMD.ACPPowerModel, data, pf_results, msr_path)

            # Read-in measurement data and set initial values
            _PMS.add_measurements!(data, msr_path, actual_meas = false, seed = current_seed)
            _PMS.assign_start_to_variables!(data)
            _PMS.update_all_bounds!(data; v_min = 0.8, v_max = 1.2, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

            # Set se settings
            data["se_settings"] = Dict{String,Any}("estimation_criterion" => set_criterion,
                                       "weight_rescaler" => set_rescaler)

			if mod == _PMD.LinDist3FlowPowerModel
	            _PMS.vm_to_w_conversion!(data)
				se_results = _PMS.run_mc_se(data, mod, se_solver)
				chosen_solver = "gurobi"
			else
				se_results = _PMS.run_mc_se(data, mod, pf_solver)
				chosen_solver = "MA27"
			end
            delta, max_err, avg = _PMS.calculate_voltage_magnitude_error(se_results, pf_results)

            # PRINT
            push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
                     string(se_results["termination_status"]),
                     se_results["objective"], set_criterion, set_rescaler, short, chosen_solver, tolerance, max_err, avg, current_seed])
       end end #loop through feeder and network
   end #criteria loop
end #end models loop
CSV.write("/home/adrian03/StateEstimationScripts/case_study_2_up.csv", df)
