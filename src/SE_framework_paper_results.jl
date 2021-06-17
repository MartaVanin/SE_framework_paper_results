module SE_framework_paper_results

import Ipopt, Gurobi
import DataFrames, CSV, Distributions
import PowerModelsDistribution
import PowerModelsDistributionStateEstimation
import Statistics

# Define Pkg cte
const _DF = DataFrames
const _DST = Distributions
const _PMD = PowerModelsDistribution
const _PMDSE = PowerModelsDistributionStateEstimation
const _SEF = SE_framework_paper_results
const _STT = Statistics

include("plotting/clean_plots.jl")

include("scripts/case_study_A.jl")
include("scripts/case_study_B.jl")
include("scripts/case_study_C.jl")
include("scripts/case_study_D.jl")

include("utils/io_utils.jl")
include("utils/linear_ivr_functions.jl")

export calculate_voltage_magnitude_error_perphase
export run_case_study_A, run_case_study_B, run_case_study_C, run_case_study_D

end