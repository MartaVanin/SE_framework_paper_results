using Plots, CSV

# WITH IVR reduced

IVR_wls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_rforms_werrors.csv")
IVR_rwls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_rforms_werrors_rwls.csv")
IVR_rwlav = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_rforms_werrors_wlav.csv")

IVR_wls_100resc = @linq IVR_wls |> where(:rescaler .== 100.0)
IVR_wls_1000resc = @linq IVR_wls |> where(:rescaler .== 1000.0)
IVR_wls_10000resc = @linq IVR_wls |> where(:rescaler .== 10000.0)

sum(IVR_wls_100resc.solve_time)
sum(IVR_wls_1000resc.solve_time)
sum(IVR_wls_10000resc.solve_time)

IVR_rwls_100resc = @linq IVR_rwls |> where(:rescaler .== 100.0)
IVR_rwls_1000resc = @linq IVR_rwls |> where(:rescaler .== 1000.0)
IVR_rwls_10000resc = @linq IVR_rwls |> where(:rescaler .== 10000.0)

sum(IVR_rwls_100resc.solve_time)
sum(IVR_rwls_1000resc.solve_time)
sum(IVR_rwls_10000resc.solve_time)

IVR_rwlav_1000resc = @linq IVR_rwlav |> where(:rescaler .== 1000.0)
IVR_rwlav_10000resc = @linq IVR_rwlav |> where(:rescaler .== 10000.0)

sum(IVR_rwlav_1000resc.solve_time)
sum(IVR_rwlav_10000resc.solve_time)

# WITH ACP reduced

ACP_wls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACP_PQVm_rforms_werrors.csv")
ACP_rwls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACP_PQVm_rforms_werrors_rwls.csv")
ACP_rwlav = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACP_PQVm_rforms_werrors_wlav.csv")

ACP_wls_100resc = @linq ACP_wls |> where(:rescaler .== 100.0)
ACP_wls_1000resc = @linq ACP_wls |> where(:rescaler .== 1000.0)
ACP_wls_10000resc = @linq ACP_wls |> where(:rescaler .== 10000.0)

sum(ACP_wls_100resc.solve_time)
sum(ACP_wls_1000resc.solve_time)
sum(ACP_wls_10000resc.solve_time)

ACP_rwls_100resc = @linq ACP_rwls |> where(:rescaler .== 100.0)
ACP_rwls_1000resc = @linq ACP_rwls |> where(:rescaler .== 1000.0)
ACP_rwls_10000resc = @linq ACP_rwls |> where(:rescaler .== 10000.0)

sum(ACP_rwls_100resc.solve_time)
sum(ACP_rwls_1000resc.solve_time)
sum(ACP_rwls_10000resc.solve_time)

ACP_rwlav_1000resc = @linq ACP_rwlav |> where(:rescaler .== 1000.0)
ACP_rwlav_10000resc = @linq ACP_rwlav |> where(:rescaler .== 10000.0)

sum(ACP_rwlav_1000resc.solve_time)
sum(ACP_rwlav_10000resc.solve_time)

# WITH ACR reduced

ACR_wls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACR_PQVm_rforms_werrors.csv")
ACR_rwls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACR_PQVm_rforms_werrors_rwls.csv")
ACR_rwlav = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rACR_PQVm_rforms_werrors_wlav.csv")

ACR_wls_100resc = @linq ACR_wls |> where(:rescaler .== 100.0)
ACR_wls_1000resc = @linq ACR_wls |> where(:rescaler .== 1000.0)
ACR_wls_10000resc = @linq ACR_wls |> where(:rescaler .== 10000.0)

sum(ACR_wls_100resc.solve_time)
sum(ACR_wls_1000resc.solve_time)
sum(ACR_wls_10000resc.solve_time)

ACR_rwls_100resc = @linq ACR_rwls |> where(:rescaler .== 100.0)
ACR_rwls_1000resc = @linq ACR_rwls |> where(:rescaler .== 1000.0)
ACR_rwls_10000resc = @linq ACR_rwls |> where(:rescaler .== 10000.0)

sum(ACR_rwls_100resc.solve_time)
sum(ACR_rwls_1000resc.solve_time)
sum(ACR_rwls_10000resc.solve_time)

ACR_rwlav_1000resc = @linq ACR_rwlav |> where(:rescaler .== 1000.0)
ACR_rwlav_10000resc = @linq ACR_rwlav |> where(:rescaler .== 10000.0)

sum(ACR_rwlav_1000resc.solve_time)
sum(ACR_rwlav_10000resc.solve_time)

unique(ACR_rwlav_1000resc.termination_status)

#################### EXACT LINEAR DATAFRAMES ###################

lin_exact_wls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_exactlinear.csv")
lin_exact_rwls = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_exactlinear_rwls.csv")
lin_exact_rwlav = CSV.read("C:\\Users\\mvanin\\Downloads\\Results_DSSE_paper-master3\\Results_DSSE_paper-master3\\result_files\\rIVR_PQVm_exactlinear_wlav.csv")

lin_exact_wls_100resc = @linq lin_exact_wls |> where(:rescaler .== 100.0)
lin_exact_wls_1000resc = @linq lin_exact_wls |> where(:rescaler .== 1000.0)
lin_exact_wls_10000resc = @linq lin_exact_wls |> where(:rescaler .== 10000.0)

sum(lin_exact_wls_100resc.solve_time)
sum(lin_exact_wls_1000resc.solve_time)
sum(lin_exact_wls_10000resc.solve_time)

lin_exact_rwls_100resc = @linq lin_exact_rwls |> where(:rescaler .== 100.0)
lin_exact_rwls_1000resc = @linq lin_exact_rwls |> where(:rescaler .== 1000.0)
lin_exact_rwls_10000resc = @linq lin_exact_rwls |> where(:rescaler .== 10000.0)

sum(lin_exact_rwls_100resc.solve_time)
sum(lin_exact_rwls_1000resc.solve_time)
sum(lin_exact_rwls_10000resc.solve_time)

lin_exact_rwlav_100resc = @linq lin_exact_rwlav |> where(:rescaler .== 100.0)
lin_exact_rwlav_1000resc = @linq lin_exact_rwlav |> where(:rescaler .== 1000.0)
lin_exact_rwlav_10000resc = @linq lin_exact_rwlav |> where(:rescaler .== 10000.0)

sum(lin_exact_rwlav_100resc.solve_time)
sum(lin_exact_rwlav_1000resc.solve_time)
sum(lin_exact_rwlav_10000resc.solve_time)


function plot_speed_vs_criterion(df::DataFrame, choose_seed::Int64, solver_name::String="solver name?")

    formulation = df.eq_model[1]
    formulation[1] == 'r' ? form = formulation[2:end] : form = formulation

    df_clean = @linq df |> where(:seed .== choose_seed)
    df_wls = @linq df_clean |> where(:criterion .== "wls")
    df_rwls = @linq df_clean |> where(:criterion .== "rwls")
    df_rwlav = @linq df_clean |> where(:criterion .== "rwlav")

    scatter(df_wls.n_bus, df_wls.solve_time, label = "WLS", markershape = :circle, xaxis = "Number of feeder buses [-]", yaxis = "Solve time [s]", title = "Computational speed for $(form) form, with $(solver_name)" )
    scatter!(df_rwls.n_bus, df_rwls.solve_time, label = "rWLS", markershape = :x )
    scatter!(df_rwlav.n_bus, df_rwlav.solve_time, label = "rWLAV", markershape = :diamond )

end

function plot_error_vs_criterion(df::DataFrame, choose_seed::Int64; solver_name::String="solver name?", remove_outlier::Bool=false, max_or_avg::String="Max.")

    formulation = df.eq_model[1]
    formulation[1] == 'r' ? form = formulation[2:end] : form = formulation

    df_clean = @linq df |> where(:seed .== choose_seed)
    df_wls = @linq df_clean |> where(:criterion .== "wls")
    df_rwls = @linq df_clean |> where(:criterion .== "rwls")
    df_rwlav = @linq df_clean |> where(:criterion .== "rwlav")
    max_or_avg == "Max." ? yax = :err_max : yax = :err_avg

    if remove_outlier
        scatter(df_wls.n_bus, df_wls[Symbol(yax)], label = "$(max_or_avg) err. WLS", markercolor = :blue, markershape = :circle, ylims = [0.0, 0.005], xaxis = "Number of feeder buses [-]", yaxis = "Absolute error [p.u.]", title = "SE error for $(form) form, with $(solver_name)" )
    else
        scatter(df_wls.n_bus, df_wls[Symbol(yax)], label = "$(max_or_avg) err. WLS", markercolor = :blue, markershape = :circle, xaxis = "Number of feeder buses [-]", yaxis = "Absolute error [p.u.]", title = "SE error for $(form) form, with $(solver_name)" )
    end
    scatter!(df_rwls.n_bus, df_rwls[Symbol(yax)], label = "$(max_or_avg) err. rWLS", markercolor = :orange, markershape = :star5 )
    scatter!(df_rwlav.n_bus, df_rwlav[Symbol(yax)], label = "$(max_or_avg) err. rWLAV", markercolor = :green, markershape = :diamond )
end

function plot_speed_different_forms(df::DataFrame, choose_seed::Int64; solver_name::String="solver name?", remove_outlier::Bool=false, max_or_avg::String="Max.")

    formulation = df.eq_model[1]
    formulation[1] == 'r' ? form = formulation[2:end] : form = formulation

    df_clean = @linq df |> where(:seed .== choose_seed)
    df_wls = @linq df_clean |> where(:criterion .== "wls")
    df_rwls = @linq df_clean |> where(:criterion .== "rwls")
    df_rwlav = @linq df_clean |> where(:criterion .== "rwlav")
    max_or_avg == "Max." ? yax = :err_max : yax = :err_avg

    if remove_outlier
        scatter(df_wls.n_bus, df_wls[Symbol(yax)], label = "$(max_or_avg) err. WLS", markercolor = :blue, markershape = :circle, ylims = [0.0, 0.005], xaxis = "Number of feeder buses [-]", yaxis = "Absolute error [p.u.]", title = "SE error for $(form) form, with $(solver_name)" )
    else
        scatter(df_wls.n_bus, df_wls[Symbol(yax)], label = "$(max_or_avg) err. WLS", markercolor = :blue, markershape = :circle, xaxis = "Number of feeder buses [-]", yaxis = "Absolute error [p.u.]", title = "SE error for $(form) form, with $(solver_name)" )
    end
    scatter!(df_rwls.n_bus, df_rwls[Symbol(yax)], label = "$(max_or_avg) err. rWLS", markercolor = :orange, markershape = :star5 )
    scatter!(df_rwlav.n_bus, df_rwlav[Symbol(yax)], label = "$(max_or_avg) err. rWLAV", markercolor = :green, markershape = :diamond )
end

df2 = append!(IVR_rwls_1000resc, IVR_wls_1000resc)
df = append!(df2, IVR_rwlav_1000resc)

plot_speed_vs_criterion(df, 2, "Ipopt - mumps")
plot_error_vs_criterion(df, 2, solver_name="Ipopt - mumps", remove_outlier = true, max_or_avg="Max.")
save_pdf_current_plot("IVR_mumps")


function save_pdf_current_plot(plot_name::String="unknown_plot")
    savefig(joinpath(@__DIR__, "result_files\\plots\\")*plot_name*".pdf")
end

dataf_array = [IVR_rwls_10000resc, ACP_rwls_100resc, ACR_rwls_100resc]

function compare_computation_time(df_array::Array, choose_seed; yaxis_lim=Inf)

    plt = plot() #initialize plot
    mrkshp_list = [:circle, :star5, :X, :diamond]
    clr_list = [:blue, :orange, :green, :grey]
    for i in 1:length(df_array)
        df = df_array[i]
        mrkshp = mrkshp_list[i]
        clr = clr_list[i]
        formulation = df.eq_model[1]
        formulation[1] == 'r' ? form = formulation[2:end] : form = formulation
        df_clean = @linq df |> where(:seed .== choose_seed)

        scatter!(df.n_bus, df.solve_time, label = formulation, markercolor = clr,
                    markershape = mrkshp, xaxis = "Number of feeder buses [-]",
                    yaxis = "Solve time [s]", ylims = [0, yaxis_lim],
                    title = "Computational time comparison", legend=:topleft )
    end
    plt
end

function compare_errors(df_array::Array, choose_seed; yaxis_lim=Inf, remove_outlier::Bool=false, max_or_avg::String="Max.")

    plt = plot() #initialize plot
    mrkshp_list = [:circle, :star5, :X, :diamond]
    clr_list = [:blue, :orange, :green, :grey]
    for i in 1:length(df_array)
        df = df_array[i]
        mrkshp = mrkshp_list[i]
        clr = clr_list[i]
        formulation = df.eq_model[1]
        formulation[1] == 'r' ? form = formulation[2:end] : form = formulation
        df_clean = @linq df |> where(:seed .== choose_seed)
        max_or_avg == "Max." ? yax = :err_max : yax = :err_avg

        scatter!(df.n_bus, df[yax], label = formulation, markercolor = clr,
                    markershape = mrkshp, xaxis = "Number of feeder buses [-]",
                    yaxis = " Error [p.u.]", ylims = [0, yaxis_lim],
                    title = "$(max_or_avg) absolute error", legend=:topleft )
    end
    plt
end

dataf_array = [lin_exact_rwls_1000resc, IVR_wls_10000resc]
compare_computation_time(dataf_array, 1; yaxis_lim=10)
compare_errors(dataf_array, 1; max_or_avg = "Avg.")
