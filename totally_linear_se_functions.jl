using JuMP, PowerModelsDistribution, PowerModels, PowerModelsSE

"solves the reduced state estimation in current and voltage rectangular coordinates (ReducedIVR formulation)"
function run_linear_ivr_red_mc_se(data::Union{Dict{String,<:Any},String}, solver; kwargs...)
    return run_mc_selin(data, PowerModelsSE.ReducedIVRPowerModel, solver; kwargs...)
end

function run_mc_selin(data::Union{Dict{String,<:Any},String}, model_type::Type, solver; kwargs...)
    if !haskey(data["se_settings"], "rescaler")
        data["se_settings"]["rescaler"] = 1
    end
    if !haskey(data["se_settings"], "criterion")
        data["se_settings"]["criterion"] = "rwlav"
    end
    return PowerModelsDistribution.run_mc_model(data, model_type, solver, build_mc_selin; kwargs...)
end

"specification of an exact linear state estimation problem for the reduced IVR Flow formulation
The difference with the regular state estimation available in PowerModelsSE is that
variable_mc_bus_voltage and constraint_mc_gen_setpoint_se are unbounded "
function build_mc_selin(pm::PowerModelsSE.ReducedIVRPowerModel)
    # Variables

     PowerModelsDistribution.variable_mc_bus_voltage(pm, bounded = false)
     PowerModelsSE.variable_mc_branch_current(pm, bounded = true)
     PowerModelsSE.variable_mc_gen_power_setpoint_se(pm, bounded = true)
     PowerModelsSE.variable_mc_load_current(pm, bounded = true)
     PowerModelsSE.variable_mc_residual(pm, bounded = true)
     PowerModelsSE.variable_mc_measurement(pm, bounded = true)

    # Constraints
    for (i,bus) in PowerModelsDistribution.ref(pm, :ref_buses)
        @assert bus["bus_type"] == 3
        PowerModelsDistribution.constraint_mc_theta_ref(pm, i)
    end

    # gens should be constrained before KCL, or Pd/Qd undefined
    for id in PowerModelsDistribution.ids(pm, :gen)
        PowerModelsSE.constraint_mc_gen_setpoint_se(pm, id; bounded = false)
    end

    for (i,bus) in PowerModelsDistribution.ref(pm, :bus)
        PowerModelsSE.constraint_mc_load_current_balance_se(pm, i)
    end

    for i in PowerModelsDistribution.ids(pm, :branch)
        PowerModelsSE.constraint_current_to_from(pm, i)
        PowerModelsSE.constraint_mc_bus_voltage_drop(pm, i)
    end

    for (i,meas) in PowerModelsDistribution.ref(pm, :meas)
        PowerModelsSE.constraint_mc_residual(pm,i)
    end

    PowerModelsSE.objective_mc_se(pm)

end
