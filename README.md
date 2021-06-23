This repository contains results and example scripts for the paper:

"A Framework for Constrained Static State Estimation in Unbalanced Distribution Networks"

If you are looking for the general open-source state estimation framework package instead, that's [here](https://github.com/Electa-Git/PowerModelsDistributionStateEstimation.jl).

## Producing and comparing the results

The csv files in `result_files/` are the ones used to generate the figures in the paper. The figures in the paper are directly plotted in LaTeX (tikz), but some plotting functionalities are provided here in this package (see instructions below), so that the user can generate virtually the same plots directly in julia.

The scripts in this repository allow the user to reproduce the paper results, but slight variations in their values can always occur depending on the solvers types and versions, machine used, etc. The paper contains the updated details on the conditions in which its results were generated. This code has been tested on Ubuntu and Windows but not MacOS.

Feel free to contact me in case of doubts or mistakes.

## Installation

*Please use Julia v1.6*

This repository takes the form of a (non-registered) julia package, and can be installed from the package manager, i.e., copy-pasting the following in the julia REPL:
```
]add https://github.com/MartaVanin/SE_framework_paper_results.git
```
All needed dependencies are installed automatically, so the user does not need to worry about them. If interested, the dependencies are reported in `Project.toml`.
In addition to the package itself, one (or more) solvers to solve the optimization problem is required. A popular non linear solver is Ipopt. To obtain it, since it is
a registered julia package, it is sufficient to install it from package manager:
```
]add Ipopt
```
to obtain a spcific version of Ipopt (or any other package):
```
]add Ipopt@0.6.5
```
Ipopt can be used also to solve the linear problems that are present in the scripts. However, for these problems Ipopt is largely outperformed by other linear solvers, e.g., Gurobi.
If you have a Gurobi license (easily available for academics), we recommend that you use that.
In general, any solver compatible with JuMP can be used. See the available solvers and which problem classes they can solve [here](https://jump.dev/JuMP.jl/stable/installation/#Supported-solvers). Typically, specific indications on how to install a solver and/or its license can be found in its `README.md`.

## How to run a script for a case study

The scripts for each case study are in `src/scripts`, and the reader can inspect the source code there. Each case study bears the name or letter or number with which it appears in the paper. To run a script, it is sufficient to have the present package and one or more solvers installed as indicated above. Once that is done, it is sufficient to type in the julia REPL:
```julia
import SE_framework_paper_results, Ipopt
_SEF =  SE_framework_paper_results

csv_result_path = "path/to/results_cs_A.csv" # the user needs to provide this string
nlsolver = (Ipopt.Optimizer)
_SEF.run_case_study_A(csv_result_path, nlsolver)
```
(of course, you need to be in the environment where the packages are installed).
Note that some of the case studies run on > 100 networks, and therefore take a while.

### Arguments for case study functions

Script functions `run_case_study_*` have some "compulsory" and some "optional" arguments. In the function definitions within `src/scripts`, these are separated by a semicolon. Compulsory arguments have to be provided by the user. Optional arguments can be provided by the user, and otherwise take the default value assigned in the function definition. For example, the definition of `run_case_study_A` is:
```
function run_case_study_A(path_to_result_csv::String, solver::Any; set_rescaler::Int64 = 100, power_base::Float64=1e5)
```
where
- `path_to_result_csv`, and `solver` are compulsory arguments, whereas,
- `set_rescaler` and `power_base` are optional and have as default value `100` and `1e5`, respectively.

Below, an explanation of all the arguments of all the case study functions (not all arguments are needed in all functions, e.g., `linsolver` is not used in `run_case_study_A`, where there are no linear optimization problems). Please have a look at the source code and at the section below to see which functions uses which arguments:

- `path_to_result_csv`:
- `nlsolver`:
- `linsolver`:
- `set_rescaler`:
- `power_base`:


### Argument values used in the original paper calculations

TODO!!!!

1) Case study B and C work best with Gurobi. However, if you do not have a license, it can be set to call back to ipopt, even though the latter is not the fastest linear program solver. 
2) Ipopt needs and underlying linear solver. The default one is "mumps", while the recommended one to solve these se problems is "ma27", by HSL. However, this also requires a license. If the user does not have it, they can set `lin_sol` to "mumps"

## Plot the results