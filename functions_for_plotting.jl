using DataFrames, CSV

function find_fastest_rescaler(df)
    resc_time = []
    for resc in unique(df.rescaler)
        df_resc = @linq df |> where(:rescaler .== resc)
        push!(resc_time, (resc, sum(df_resc.solve_time)))
    end
    rescaler = first.(resc_time)[findall(x->x==minimum(last.(resc_time)), last.(resc_time))]
    fastest_df = @linq df |> where(:rescaler .== rescaler)
    return resc_time, fastest_df
end

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

function compare_computation_time_criteria(plt, df::DataFrame, formulation, criterion, index; yaxis_lim=Inf)

    mrkshp_list = [:circle, :star5, :X, :diamond]
    clr_list = [:blue, :orange, :green, :grey]

    mrkshp = mrkshp_list[index]
    clr = clr_list[index]
    formulation[1] == 'r' ? form = formulation[2:end] : form = formulation

    scatter!(df.n_bus, df.solve_time, label = criterion, markercolor = clr,
                markershape = mrkshp, xaxis = "Number of feeder buses [-]",
                yaxis = "Solve time [s]", ylims = [0, yaxis_lim],
                title = "Computational time comparison - $(formulation)", legend=:topleft )

end

function compare_errors(plt, df, formulation, criterion, index; yaxis_lim=Inf, remove_outlier::Bool=false, max_or_avg::String="Max.")

    mrkshp_list = [:circle, :star5, :X, :diamond]
    clr_list = [:blue, :orange, :green, :grey]

    mrkshp = mrkshp_list[index]
    clr = clr_list[index]
    formulation[1] == 'r' ? form = formulation[2:end] : form = formulation

    max_or_avg == "Max." ? yax = :err_max : yax = :err_avg

    scatter!(df.n_bus, df[yax], label = formulation, markercolor = clr,
                markershape = mrkshp, xaxis = "Number of feeder buses [-]",
                yaxis = " Error [p.u.]", ylims = [0, yaxis_lim],
                title = "$(max_or_avg) absolute error", legend=:topleft )
end

function save_pdf_current_plot(plot_name::String="unknown_plot")
    savefig(joinpath(@__DIR__, "result_files\\plots\\")*plot_name*".pdf")
end
