function plot_result_caseA(path_to_caseA_csv::String, which_plot::String)

    casea = CSV.read(path_to_caseA_csv)

    casea_wls = casea |> Query.@filter(_.criterion .== "wls") |> DataFrames.DataFrame
    casea_rwls = casea |> Query.@filter(_.criterion .== "rwls") |> DataFrames.DataFrame
    casea_rwlav = casea |> Query.@filter(_.criterion .== "rwlav") |> DataFrames.DataFrame

    ACP_df_wls = casea_wls |> Query.@filter(_.eq_model .== "rACP") |> DataFrames.DataFrame
    ACR_df_wls = casea_wls |> Query.@filter(_.eq_model .== "rACR") |> DataFrames.DataFrame
    IVR_df_wls = casea_wls |> Query.@filter(_.eq_model .== "rIVR") |> DataFrames.DataFrame

    ACP_df_rwls = casea_rwls |> Query.@filter(_.eq_model .== "rACP") |> DataFrames.DataFrame
    ACR_df_rwls = casea_rwls |> Query.@filter(_.eq_model .== "rACR") |> DataFrames.DataFrame
    IVR_df_rwls = casea_rwls |> Query.@filter(_.eq_model .== "rIVR") |> DataFrames.DataFrame

    ACP_df_rwlav = casea_rwlav |> Query.@filter(_.eq_model .== "rACP") |> DataFrames.DataFrame
    ACR_df_rwlav = casea_rwlav |> Query.@filter(_.eq_model .== "rACR") |> DataFrames.DataFrame
    IVR_df_rwlav = casea_rwlav |> Query.@filter(_.eq_model .== "rIVR") |> DataFrames.DataFrame

    timeylimlow = 0.01
    timeylim = 180

    ylim1 = 0.003
    ylim2 = 0.001
    ylim3 = 0.006
    if which_plot == "time"
        p1 = Plots.scatter([ACP_df_wls.n_bus, ACR_df_wls.n_bus, IVR_df_wls.n_bus], [ACP_df_wls.solve_time, ACR_df_wls.solve_time, IVR_df_wls.solve_time], markershape=[:circle :rect :utriangle], label=["ACP" "ACR" "IVR"], ylabel="Solve time [s]",
                yscale=:log, legend=false, ylims=(timeylimlow, timeylim), title="WLS")
        p2 = Plots.scatter([ACP_df_rwls.n_bus, ACR_df_rwls.n_bus, IVR_df_rwls.n_bus], [ACP_df_rwls.solve_time, ACR_df_rwls.solve_time, IVR_df_rwls.solve_time], markershape=[:circle :rect :utriangle], label=["ACP" "ACR" "IVR"],
                legend=:bottomright, yscale=:log, xlabel="number of buses [-]", ylims=(timeylimlow, timeylim), yaxis=nothing, title="rWLS")
        p3 = Plots.scatter([ACP_df_rwlav.n_bus, ACR_df_rwlav.n_bus, IVR_df_rwlav.n_bus], [ACP_df_rwlav.solve_time, ACR_df_rwlav.solve_time, IVR_df_rwlav.solve_time], markershape=[:circle :rect :utriangle],   
                legend=false, yscale=:log, ylims=(timeylimlow, timeylim), yaxis=nothing, title="rWLAV")
        Plots.plot(p1, p2, p3, layout = (1,3))
    elseif which_plot == "error_ph1"
        Plots.scatter([ACR_df_rwlav.n_bus, ACR_df_rwlav.n_bus], [ACR_df_rwlav.err_max_1, ACR_df_rwlav.err_avg_1], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study A - Phase 1", ylims = (0.0, ylim1))
    elseif which_plot == "error_ph2"
        Plots.scatter([ACR_df_rwlav.n_bus, ACR_df_rwlav.n_bus], [ACR_df_rwlav.err_max_2, ACR_df_rwlav.err_avg_2], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study A - Phase 2", ylims = (0.0, ylim2))
    elseif which_plot == "error_ph3"
        Plots.scatter([ACR_df_rwlav.n_bus, ACR_df_rwlav.n_bus], [ACR_df_rwlav.err_max_3, ACR_df_rwlav.err_avg_3], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study A - Phase 3", ylims = (0.0, ylim3))
    else
        display("ERROR: plot type $which_plot in argument `which_plot` not recognized. Possibilities are: \"time\", \"error_ph1\", \"error_ph2\", \"error_ph3\"")
    end
end

function plot_result_caseB(path_to_caseB_csv::String, which_plot::String)
    caseb = CSV.read(path_to_caseB_csv)

    LDF_df = caseb |> Query.@filter(_.eq_model .== "LD3F") |> DataFrames.DataFrame
    IVR_df = caseb |> Query.@filter(_.eq_model .== "rIVR") |> DataFrames.DataFrame
    
    if which_plot == "time"
        Plots.scatter([IVR_df.n_bus, LDF_df.n_bus], [IVR_df.solve_time, LDF_df.solve_time], markershape=[:utriangle :diamond], label=["IVR" "LD3F"], ylabel="Solve time [s]", xlabel="Number of buses [-]", 
                legend=:bottomright, title="$which_plot plot for case study B", yscale=:log)
    elseif which_plot == "error_ph1"
        Plots.scatter([LDF_df.n_bus, LDF_df.n_bus], [LDF_df.err_max_1, LDF_df.err_avg_1], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study B - Phase 1")
    elseif which_plot == "error_ph2"
        Plots.scatter([LDF_df.n_bus, LDF_df.n_bus], [LDF_df.err_max_2, LDF_df.err_avg_2], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study B - Phase 2")
    elseif which_plot == "error_ph3"
        Plots.scatter([LDF_df.n_bus, LDF_df.n_bus], [LDF_df.err_max_3, LDF_df.err_avg_3], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Number of buses [-]", 
                legend=:topright, title="Error plot for case study B - Phase 3")
    else
        display("ERROR: plot type $which_plot in argument `which_plot` not recognized. Possibilities are: \"time\", \"error_ph1\", \"error_ph2\", \"error_ph3\"")
    end
end

function plot_result_caseC(path_to_caseC_csv::String)
    casec = CSV.read(path_to_caseC_csv)

    linIVR_df = casec |> Query.@filter(_.eq_model .== "linIVR") |> DataFrames.DataFrame
    rIVR_df = casec |> Query.@filter(_.eq_model .== "rIVR") |> DataFrames.DataFrame

    Plots.scatter([linIVR_df.n_bus, rIVR_df.n_bus], [linIVR_df.solve_time, rIVR_df.solve_time], markershape=[:circle :utriangle], label=["IVR - linear" "IVR - nonlinear"], ylabel="Solve time [s]", xlabel="Number of buses [-]", 
             legend=:bottomright, title="Plot for case study C", yscale=:log)
end

function plot_result_caseD(path_to_caseD_csv::String, which_plot::String)
    
    caseD = CSV.read(path_to_caseD_csv)

    x = (caseD.n_meas.-3)/(3*55)*100

    if which_plot == "error_ph1"
        Plots.scatter([x, x], [caseD.err_max_1, caseD.err_avg_1], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Measured users [%]", 
                legend=:bottomleft, title="Error plot for case study D - Phase 1", yscale=:log)
    elseif which_plot == "error_ph2"
        Plots.scatter([x, x], [caseD.err_max_2, caseD.err_avg_2], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Measured users [%]", 
                legend=:bottomleft, title="Error plot for case study D - Phase 2", yscale=:log)
    elseif which_plot == "error_ph3"
        Plots.scatter([x, x], [caseD.err_max_3, caseD.err_avg_3], markershape=[:circle :utriangle], label=["max. abs. error" "avg. abs. error"], ylabel="Absolute error ϵ [p.u.]", xlabel="Measured users [%]", 
                legend=:bottomleft, title="Error plot for case study D - Phase 3", yscale=:log)
    else
        display("ERROR: plot type $which_plot in argument `which_plot` not recognized. Possibilities are: \"error_ph1\", \"error_ph2\", \"error_ph3\"")
    end
end

