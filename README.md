This repository contains results and example scripts for the paper:

"A Framework for Constrained Static State Estimation in Unbalanced Distribution Networks" by M. Vanin, T. Van Acker, R. D'hulst and D. Van Hertem.

If you are looking for the general open-source state estimation framework package instead, that's [here](https://github.com/Electa-Git/PowerModelsDistributionStateEstimation.jl).

This code has a BSD-3 clause license.

## Producing and comparing the results

The csv files in `result_files/` are the ones used to generate the figures in the paper. The figures in the paper are directly plotted in LaTeX (tikz), but some plotting functionalities are provided here in this package (see instructions below), so that the user can generate virtually the same plots directly in julia.

The scripts in this repository allow the user to reproduce the paper results, but slight variations in their values can always occur depending on the solvers types and versions, machine used, etc. The paper contains the updated details on the conditions in which its results were generated. The code has been tested on Ubuntu and Windows but not MacOS.

Feel free to contact me in case of doubts or mistakes.

## Installation

*Please use Julia version 1.6*

This repository takes the form of a (non-registered) julia package, and can be installed from the package manager, i.e., copy-pasting the following in the julia REPL:
```
]add https://github.com/MartaVanin/SE_framework_paper_results.git
```
If interested, the user can see this package's dependencies in the `Project.toml` file.
In addition to the package itself, one (or more) solvers to solve the optimization problem is required. A popular and open non-linear solver is Ipopt. To obtain it, since it is
a registered julia package, it is sufficient to install it from package manager:
```
]add Ipopt
```
to obtain a specific version of Ipopt (or any other package, do):
```
]add Ipopt@0.6.5
```
Ipopt can also be used to solve the linear problems that are present in the scripts. However, for these problems Ipopt is largely outperformed by other linear solvers, e.g., Gurobi.
If you have a Gurobi license (easily available for academics), we recommend that you use that.
In general, any solver compatible with JuMP can be used. See the available solvers and which problem classes they can solve [here](https://jump.dev/JuMP.jl/stable/installation/#Supported-solvers). Typically, specific indications on how to install a solver and/or its license can be found in its `README.md`.

## How to run a script for a case study

The scripts for each case study are in `src/scripts`, and the reader can inspect the source code there. Each case study bears the name/letter/number with which it appears in the paper. To run a script, it is sufficient to have the present package and one or more solvers installed as indicated above. Once that is done, it is sufficient to type in the julia REPL:
```julia
import SE_framework_paper_results, Ipopt
_SEF =  SE_framework_paper_results
csv_result_path = "path/to/results_cs_A.csv" # the user needs to provide this string
nlsolver = (Ipopt.Optimizer, "max_cpu_time"=>180.0, "tol"=>1e-10, "print_level"=>0) # the user sets the solver settings, this is just an example 
_SEF.run_case_study_A(csv_result_path, nlsolver)
```
(of course, you need to be in the environment where the packages are installed in order to use them).
Note that some of the case studies run on > 100 networks, and therefore might take a while.
The result of case studies A to D are csv files, to be found in the user-defined path. 

*Note on case study E:*
Since there is no plot associated with it, case study E's output is not a csv but is printed in the REPL. Please ignore the estimation criterion warnings in the REPL.

### Arguments for case study functions

Script functions `run_case_study_*` have some "compulsory" and some "optional" arguments. In the function definitions within `src/scripts`, these are separated by a semicolon. Compulsory arguments have to be provided by the user. Optional arguments can be provided by the user, and otherwise take the default value assigned in the function definition. For example, the definition of `run_case_study_A` is:
```
run_case_study_A(path_to_result_csv::String, nlsolver::Any; models::Array=[_PMDSE.ReducedIVRUPowerModel, _PMDSE.ReducedACRUPowerModel, _PMDSE.ReducedACPUPowerModel], ...)
```
where
- `path_to_result_csv`, and `solver` are compulsory arguments, whereas,
- `set_rescaler` and `power_base` are optional and have as default value `1000` and `1.0`, respectively, and so on for `start`, `vmin`, `vmax`, etc..

Using the default values of the optional arguments will solve most of the networks for all formulations and criteria, but there will be exceptions with numerical issues, especially with the "wls" criterion. In practice, since the "wls" and the "rwls" are equivalent, the user should in general probably just use the "rwls".
Changing the optional values, e.g., start value, bounds, but particularly the `set_rescaler` and `power_base` can improve convergence a lot. In general, different networks with different characteristics might prefer different settings, and trying to force the same settings to all networls as we do in this exercise is probably not the best way to go. To produce `case_A.csv`, for a minority of feeders with the wls criterion, different rescalers and power bases have been used, as can be seen in the csv file itself.

Below, an explanation of all the arguments of all the case study functions (not all arguments are needed in all functions, e.g., `linsolver` is not used in `run_case_study_A`, where there are no linear optimization problems). Please have a look at the source code and at the section below to see which functions uses which arguments:

- `path_to_result_csv`: Path where the csv file with the results is created and stored. It needs to be a string!
- `nlsolver`: Solver (with settings) for non-linear SE problems. It needs to have the form (Ipopt.Optimizer, "print_level"=>0), i.e., wrapped in brackets and with at least one setting.
- `linsolver`: Solver (with settings) for the linear SE problems. It needs to have the form (Ipopt.Optimizer, "print_level"=>0), i.e., wrapped in brackets and with at least one setting.
- `set_rescaler`: Scalar value that rescales ALL weights (see the package manual). It has the potential to speed up calculations without affecting the results. It has to be an Integer!
- `power_base`: Scalar value which is used to convert the power and impedance values in per unit. It has to be a Float!
- `vmin`, `vmax`: Lower and upper bounds on voltages, Floats.
- `start`: Boolean that states whether start values are used for SE calculations. If `true`, start values of the variables equal their measured value (i.e., with errors).
- `models`: array that contains the different exact SE formulations for case study A: ACR, ACP and IVR. The user can pass a subset of the default set,
- `abbreviations`: array of strings that contains the abbreviations of the formulations in `models`, to be written in the result csv file,
- `criteria`: wls, rwlas and rwlav or a subset of these, i.e., the SE objective.  

### Solver set-up

The following solver settings are used:
```julia
nlsolver = (Ipopt.Optimizer, "max_cpu_time"=>180.0, "tol"=>1e-8, "print_level"=>0, "linear_solver"=>"MA27")
linsolver = (Gurobi.Optimizer, "TimeLimit"=>180.0)
```

*NOTES*:
1) Case study B and C work best with Gurobi. However, if you do not have a license, it can be set to call back to ipopt, even though the latter is not the fastest linear program solver. 
2) Ipopt needs and underlying linear solver. The default one is "mumps", while the recommended one to solve these se problems is "ma27", by HSL. However, this also requires a license. If the user does not have it, they should set `"linear_solver"` to "mumps" or remove the `"linear_solver"` attribute altogether.

## Plot the results

The scripts for plotting results can be found in `src/plotting`. For the sake of clarity, every case study has its own plotting function. 

All plotting functions have as first argument the path to the csv file where the results of the case study is stored. If you want to use the csv files that are also used in the paper, these can be found in the `\result_file` folder. E.g.,
```julia
using SE_framework_paper_results
plot_result_caseC("../result_files/case_study_C.csv")
```
To save the last produced plot to your machine, you can use the savefig function: `savefig("path/to/savedplot/picture_title.PNG")`. Changing the extension to e.g. `pdf` instead of `png` returns a pdf file, and so on.

Of course, you can produce your own results and plot those, as running case studies automatically returns a csv file which is compatible with the plotting functions.

Some case studies, like case study C and D, only have one plot (like in the paper), i.e., solve time or measurement errors. In the case of cases with multiple possible plots, users can specify which ones they want via the second function argument.