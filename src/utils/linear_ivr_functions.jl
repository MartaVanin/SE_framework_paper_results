################################################################################
#  Copyright 2021, Marta Vanin                                                 #
################################################################################
"solves the reduced state estimation in current and voltage rectangular coordinates (ReducedIVR formulation)"
function run_linear_ivr_red_mc_se(data::Union{Dict{String,<:Any},String}, solver; kwargs...)
    return run_mc_selin(data, PowerModelsDistributionStateEstimation.ReducedIVRUPowerModel, solver; kwargs...)
end

function run_mc_selin(data::Union{Dict{String,<:Any},String}, model_type::Type, solver; kwargs...)
    if haskey(data["se_settings"], "criterion")
        _PMDSE.assign_unique_individual_criterion!(data)
    end
    if !haskey(data["se_settings"], "rescaler")
        data["se_settings"]["rescaler"] = 1
        @warn "Rescaler set to default value, edit data dictionary if you wish to change it."
    end
    if !haskey(data["se_settings"], "number_of_gaussian")
        data["se_settings"]["number_of_gaussian"] = 10
        @warn "Estimation criterion set to default value, edit data dictionary if you wish to change it."
    end
    return PowerModelsDistribution.run_mc_model(data, model_type, solver, build_mc_selin; kwargs...)
end

"specification of an exact linear state estimation problem for the reduced IVR Flow formulation
The difference with the regular state estimation available in PowerModelsDistributionStateEstimation is that
variable_mc_bus_voltage and constraint_mc_gen_setpoint_se are unbounded "
function build_mc_selin(pm::PowerModelsDistributionStateEstimation.ReducedIVRUPowerModel)
    # Variables

     PowerModelsDistribution.variable_mc_bus_voltage(pm, bounded = false)
     PowerModelsDistributionStateEstimation.variable_mc_branch_current(pm, bounded = true)
     PowerModelsDistributionStateEstimation.variable_mc_generator_current_se(pm, bounded = true)
     PowerModelsDistributionStateEstimation.variable_mc_load_current(pm, bounded = true)
     PowerModelsDistributionStateEstimation.variable_mc_residual(pm, bounded = true)
     PowerModelsDistributionStateEstimation.variable_mc_measurement(pm, bounded = true)

    # Constraints
    for (i,bus) in PowerModelsDistribution.ref(pm, :ref_buses)
        @assert bus["bus_type"] == 3
        PowerModelsDistribution.constraint_mc_theta_ref(pm, i)
    end

    # gens should be constrained before KCL, or Pd/Qd undefined
    for id in PowerModelsDistribution.ids(pm, :gen)
        PowerModelsDistributionStateEstimation.constraint_mc_generator_power_se(pm, id; bounded = false)
    end

    for (i,bus) in PowerModelsDistribution.ref(pm, :bus)
        PowerModelsDistributionStateEstimation.constraint_mc_current_balance_se(pm, i)
    end

    for i in PowerModelsDistribution.ids(pm, :branch)
        PowerModelsDistributionStateEstimation.constraint_current_to_from(pm, i)
        PowerModelsDistributionStateEstimation.constraint_mc_bus_voltage_drop(pm, i)
    end

    for (i,meas) in PowerModelsDistribution.ref(pm, :meas)
        PowerModelsDistributionStateEstimation.constraint_mc_residual(pm,i)
    end

    PowerModelsDistributionStateEstimation.objective_mc_se(pm)

end
