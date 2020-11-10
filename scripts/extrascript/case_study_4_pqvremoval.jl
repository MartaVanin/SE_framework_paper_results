using Ipopt
using DataFrames, CSV
using JuMP, PowerModels, PowerModelsDistribution
using PowerModelsSE, Distributions

include("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\plotting\\clean_plots.jl")

# Define Pkg cte
const _DF = DataFrames
const _JMP = JuMP
const _PMs = PowerModels
const _PMD = PowerModelsDistribution
const _PMS = PowerModelsSE
const _DST = Distributions

# Input data
modl = _PMS.ReducedIVRPowerModel
short = "rIVR"
rm_transfo = true
rd_lines = true
set_criterion = "rwlav"
set_rescaler = 100

season = "summer"
time = 144
elm = ["load", "pv"]
pfs = [0.95, 0.90]

msr_path = joinpath("C:/Users/mvanin/Desktop/repos/temp.csv")
# Set solve
linear_solver = "mumps"
tolerance = 1e-5
solver = _JMP.optimizer_with_attributes(Ipopt.Optimizer,"max_cpu_time"=>180.0,
                                                        "tol"=>tolerance,
                                                        "print_level"=>0,
                                                        "linear_solver"=>linear_solver)

df = _DF.DataFrame(ntw=Int64[], fdr=Int64[], solve_time=Float64[], n_bus=Int64[],
               termination_status=String[], objective=Float64[], criterion=String[], rescaler = Float64[], eq_model = String[],
                    linear_solver = String[], tol = Any[], err_max= Float64[], err_avg = Float64[], n_meas = Int64[])

ntw = 1
fdr = 1

data_path = _PMS.get_enwl_dss_path(ntw, fdr)

# Load the data
data = _PMD.parse_file(_PMS.get_enwl_dss_path(ntw, fdr),data_model=_PMD.ENGINEERING);
if rm_transfo _PMS.rm_enwl_transformer!(data) end
if rd_lines _PMS.reduce_enwl_lines_eng!(data) end

# Insert the load profiles
_PMS.insert_profiles!(data, season, elm, pfs, t = time)

# Transform data model
data = _PMD.transform_data_model(data);

# Solve the power flow
pf_results = _PMD.run_mc_pf(data, _PMs.ACPPowerModel, solver)

# Write measurements based on power flow
_PMS.write_measurements!(_PMD.ACPPowerModel, data, pf_results, msr_path)

# Read-in measurement data and set initial values
_PMS.add_measurements!(data, msr_path, actual_meas = false, seed = 2)
_PMS.update_all_bounds!(data; v_min = 0.85, v_max = 1.15, pg_min=-1.0, pg_max = 1.0, qg_min=-1.0, qg_max=1.0, pd_min=-1.0, pd_max=1.0, qd_min=-1.0, qd_max=1.0 )

# Set se settings
data["se_settings"] = Dict{String,Any}("estimation_criterion" => set_criterion,
                           "weight_rescaler" => set_rescaler)


meas_ids = []
for (m, meas) in data["meas"]
    if meas["var"] == :qd
        push!(meas_ids, m)
    end
end
for (m, meas) in data["meas"]
    if meas["var"] == :pd
        push!(meas_ids, m)
    end
end
for (m, meas) in data["meas"]
    if meas["var"] == :vm
        push!(meas_ids, m)
    end
end

for i in 1:length(meas_ids)
    se_results = _PMS.run_ivr_red_mc_se(data, solver)
    delta, max_err, avg = _PMS.calculate_voltage_magnitude_error(se_results, pf_results)

    push!(df, [ntw, fdr, se_results["solve_time"], length(data["bus"]),
         string(se_results["termination_status"]),
         se_results["objective"], set_criterion, set_rescaler, short, linear_solver, tolerance, max_err, avg, length(data["meas"])])

     delete!(data["meas"], meas_ids[i])
end

plot_errors_cs4(df; unknowns = 111, upper_y_lim=1)

CSV.write(joinpath(dirname(@__DIR__), "result_files\\clean_csv_files\\case_study_4_pqvremoval_seereadme.csv"), df)
