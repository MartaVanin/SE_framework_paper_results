module SE_framework_paper_results

import DataFrames, CSV, Distributions, Query
import PowerModelsDistribution
import PowerModelsDistributionStateEstimation
import Plots: savefig
import Plots
import Random, Statistics

# Define Pkg constants
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
include("utils/other_utils.jl")

export run_case_study_A, run_case_study_B, run_case_study_C, run_case_study_D, run_case_study_E
export plot_result_caseA,plot_result_caseB,plot_result_caseC,plot_result_caseD
export savefig # so users do not have to install plots to save their figures

end
