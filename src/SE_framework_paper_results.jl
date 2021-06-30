module SE_framework_paper_results

import DataFrames, CSV, Distributions, Query
import PowerModelsDistribution
import PowerModelsDistributionStateEstimation
import Plots: savefig
import Plots
import Statistics

# Define Pkg cte
const _DF = DataFrames
const _DST = Distributions
const _PMD = PowerModelsDistribution
const _PMDSE = PowerModelsDistributionStateEstimation
const _SEF = SE_framework_paper_results
const _STT = Statistics

include("plotting/all_plots.jl")

include("scripts/case_study_A.jl")
include("scripts/case_study_B.jl")
include("scripts/case_study_C.jl")
include("scripts/case_study_D.jl")
include("scripts/case_study_E.jl")

include("utils/linear_ivr_functions.jl")

export run_case_study_A, run_case_study_B, run_case_study_C, run_case_study_D, run_case_study_E
export savefig # so users do not have to install plots to save their figures

end
