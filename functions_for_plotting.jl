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

    scatter!(df.n_bus, df[yax], label = criterion, markercolor = clr,
                markershape = mrkshp, xaxis = "Number of feeder buses [-]",
                yaxis = " Error [p.u.]", ylims = [0, yaxis_lim],
                title = "$(max_or_avg) absolute error", legend=:bottomleft )
end

function compare_errors_compact(plt, df; yaxis_lim=Inf)

    mrkshp_list = [:circle, :X]
    clr_list = [:blue, :orange]

    scatter!(df.n_bus, df[:err_avg], label = "Average error", markercolor = clr_list[1],
                markershape = mrkshp_list[1], xaxis = "Number of feeder buses [-]",
                yaxis = " Error [p.u.]", ylims = [0, yaxis_lim],
                title = "Error - any formulation, any criterion", legend=:topright )
    scatter!(df.n_bus, df[:err_max], label = "Maximum error", markercolor = clr_list[2],
                markershape = mrkshp_list[2], xaxis = "Number of feeder buses [-]",
                yaxis = " Error [p.u.]", ylims = [0, yaxis_lim],
                title = "Error - any exact formulation, any criterion", legend=:topright )

end

function compare_time_compact(plt, df_ivr, df_ld3f; yaxis_lim=Inf)

    mrkshp_list = [:circle, :X]
    clr_list = [:blue, :orange]

    scatter!(df_ivr.n_bus, df_ivr.solve_time, label = "IVR", markercolor = clr_list[1],
                markershape = mrkshp_list[1], xaxis = "Number of feeder buses [-]",
                yaxis = " Solve time [s]", ylims = [0, yaxis_lim],
                title = "Compare time LD3F - IVR", legend=:topleft )
    scatter!(df_ld3f.n_bus, df_ld3f.solve_time, label = "LD3F", markercolor = clr_list[2],
                markershape = mrkshp_list[2], xaxis = "Number of feeder buses [-]",
                yaxis = " Solve time [s]", ylims = [0, yaxis_lim],
                title = "Compare time LD3F - IVR", legend=:topleft )

end

function save_pdf_current_plot(plot_name::String="unknown_plot")
    savefig(joinpath(@__DIR__, "result_files\\plots\\")*plot_name*".pdf")
end

function calculate_unbalance(pf_result)
    a = exp(im*2*π/3)
    are = real(a)
    aim = imag(a)
    a2re = real(a^2)
    a2im = imag(a^2)

    vuf = []
    for (b, bus) in pf_result["solution"]["bus"]

        (vm_a, vm_b, vm_c) = [bus["vm"][i] for i in 1:3]
        (va_a, va_b, va_c) = [bus["va"][i] for i in 1:3]

        v_real_pos = (vm_a*cos(va_a) + are*vm_b*cos(va_b) - aim*vm_b*sin(va_b) + a2re*vm_c*cos(va_c) - a2im*vm_c*sin(va_c))/3
        v_imag_pos =  (vm_a*sin(va_a) + are*vm_b*sin(va_b) + aim*vm_b*cos(va_b) + a2re*vm_c*sin(va_c) + a2im*vm_c*cos(va_c))/3

        vm_pos = sqrt.(v_real_pos.^2+v_imag_pos.^2)

        v_real_neg = (vm_a*cos(va_a) + a2re*vm_b*cos(va_b) - a2im*vm_b*sin(va_b) + are*vm_c*cos(va_c) - aim*vm_c*sin(va_c))/3

        v_imag_neg = (vm_a*sin(va_a) + a2re*vm_b*sin(va_b) + a2im*vm_b*cos(va_b) + are*vm_c*sin(va_c) + aim*vm_c*cos(va_c))/3

        vm_neg = sqrt.(v_real_neg.^2+v_imag_neg.^2)

        push!(vuf, (parse(Int64, b), vm_neg/vm_pos*100))

    end
    return vuf #[%]
end
