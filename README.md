This repository contains results and example scripts for the paper:

"A Framework for Constrained Static State Estimation in Unbalanced Distribution Networks"

If you are looking for the general open-source state estimation framework package instead, that's [here](https://github.com/Electa-Git/PowerModelsDistributionStateEstimation.jl).

## Producing and comparing the results

The csv files in result_files/clean_csv_files are the ones used to generate the figures in the paper. The figures in the paper are directly plotted in LaTeX (tikz), but some plotting functionalities are provided here in this package (see below), so that the user can generate virtually the same plots directly in julia.

The scripts in this repository allow the user to reproduce the paper results, but slight variations in their values can always occur depending on the solvers types and versions, machine used, etc. The paper contains the updated details on the conditions in which its results were generated. The code has been tested on Ubuntu and Windows but not MacOS, although I believe that it should work there too.

Feel free to contact me in case of doubts or mistakes.

## Installation

This repository takes the form of a (non-registered) julia package, and can be installed from the package manager, i.e., copy-pasting the following in the julia REPL:
```
]add https://github.com/MartaVanin/SE_framework_paper_results.git
```
All needed dependencies are installed automatically, so the user does not need to worry about them. If interested, the dependencies are reported in `Project.toml`.

*For optimal results please use Julia v1.6*

## How to run the script for a case study

The scripts for each case study are in src/scripts, and the reader can inspect the source code there. Each case study bears the name or letter or number with which it appears in the paper. To run a script, it is sufficient to have the present package installed as indicated above, and type in the REPL:
```julia
import SE_framework_paper_results
_SEF =  SE_framework_paper_results

csv_result_path = "path/to/results_cs_A.csv" # the user needs to provide this string
_SEF.run_case_study_A(csv_result_path)
```
(of course, you need to be in the environment where the package is installed).
Note that some of the case studies run on > 100 networks, and therefore take a while.

Also note that `run_case_study_` functions have only one "compulsory" argument, which is the path to the csv result file. Some optional arguments, which take the default value if the user does not enter them explicitly, can also be used. These are some solver parameters:
- rescaler (`set_rescaler`): default value = 100, recommended value = default
- underlying linear solver for ipopt (`ipopt_lin_sol`): default value = "mumps", recommended value = "MA27"
- solver tolerance (`tolerance`): default value = 1.0e-5, recommended value = default
- Gurobi license (`gurobi_lic`): default value = `false`, recommended = `true`

### Recommended solvers and settings

Specifically, it is 

### NOTE
1) Case study B and C work best with Gurobi. However, if you do not have a license, it can be set to call back to ipopt, even though the latter is not the fastest linear program solver. 
2) Ipopt needs and underlying linear solver. The default one is "mumps", while the recommended one to solve these se problems is "ma27", by HSL. However, this also requires a license. If the user does not have it, they can set `lin_sol` to "mumps"