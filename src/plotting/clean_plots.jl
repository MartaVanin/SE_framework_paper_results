#using LaTeXStrings, DataFramesMeta, Plots
## case study 1

#df_cs1 = CSV.read(joinpath(dirname(@__DIR__), "result_files\\clean_csv_files\\case_study_1_clean.csv"))

# function plot_case_study_one_time(df)
#     time_data_points = []
#     criterion = []
#     n_bus = []
#     eqmodels = ["rIVR" "rACR" "rACP"]
#     labels = ["IVR" "ACR" "ACP"]
#     subtitles = ["wls" "rwls" "rwlav"]
#     mrkrkclr=["orange" "blue" "red"]
#     mrkrsize = 3
#     scale = 5
#     mrkrshape = [:circle :dtriangle :diamond]
#     pyplot()
#     for crit in subtitles
#         df_crit = @linq df |> where(:criterion .== crit)
#         for pfform in eqmodels
#             df_form_crit = @linq df_crit |> where(:eq_model .== pfform)
#             push!(time_data_points, df_form_crit.solve_time)
#             push!(n_bus, df_form_crit.n_bus)
#         end
#     end
#     pl1 = scatter(n_bus[1], time_data_points[1:3], ylims=[0.012, 8.9], markerstrokecolor=[:blue :black :orange], markercolor= [:blue :black :orange], markersize=[3 7 7],
#                     markershape = [:dtriangle :+ :circle], markeralpha=[0 1 0] , markerstrokealpha=[0.5 1 0.5], legend=false, ylabel = "Solve time [s]")
#     annotate!([(9,Statistics.mean(time_data_points[1])+0.04,text("$(round(Statistics.mean(time_data_points[1]), digits=3))", 14, :blue))])
#     annotate!([(9,Statistics.mean(time_data_points[2])+0.08,text("$(round(Statistics.mean(time_data_points[2]), digits=3))", 14, :black))])
#     annotate!([(9,Statistics.mean(time_data_points[3])+0.4,text("$(round(Statistics.mean(time_data_points[3]), digits=3))", 14, :orange))])

#     plot!(0:400, fill(Statistics.mean(time_data_points[1]), 100), seriestype=:hline, linestyle=:dash, linecolor=:blue, label="Avg. $(labels[1])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[2]), 100), seriestype=:hline, linestyle=:dash, linecolor=:black, label="Avg. $(labels[2])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[3]), 100), seriestype=:hline, linestyle=:dash, linecolor=:orange, label="Avg. $(labels[3])")

#     pl2 = scatter(n_bus[1], time_data_points[4:6], ylims=[0.012, 8.9], markerstrokecolor=[:blue :black :orange], markercolor= [:blue :black :orange], markersize=[3 7 7],
#                     markershape = [:dtriangle :+ :circle], legend=:bottomright, label=labels, markeralpha=[0 1 0] , markerstrokealpha=[0.5 1 0.5], yaxis=false, xlabel = "Number of buses in the feeder [-]")

#     annotate!([(9,Statistics.mean(time_data_points[4])+0.04,text("$(round(Statistics.mean(time_data_points[4]), digits=3))", 14, :blue))])
#     annotate!([(9,Statistics.mean(time_data_points[5])+0.08,text("$(round(Statistics.mean(time_data_points[5]), digits=3))", 14, :black))])
#     annotate!([(9,Statistics.mean(time_data_points[6])+0.4,text("$(round(Statistics.mean(time_data_points[6]), digits=3))", 14, :orange))])

#     plot!(0:400, fill(Statistics.mean(time_data_points[4]), 100), seriestype=:hline, linestyle=:dash, linecolor=:blue, label="Avg. $(labels[1])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[5]), 100), seriestype=:hline, linestyle=:dash, linecolor=:black, label="Avg. $(labels[2])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[6]), 100), seriestype=:hline, linestyle=:dash, linecolor=:orange, label="Avg. $(labels[3])")

#     pl3 = scatter(n_bus[1], time_data_points[7:9], ylims=[0.012, 8.9], markerstrokecolor=[:blue :black :orange], markercolor= [:blue :black :orange], markersize=[3 7 7],
#                     markershape = [:dtriangle :+ :circle], markeralpha=[0 1 0] , markerstrokealpha=[0.5 1 0.5], yaxis=false, legend=false)

#     annotate!([(9,Statistics.mean(time_data_points[7])+0.04,text("$(round(Statistics.mean(time_data_points[7]), digits=3))", 14, :blue))])
#     annotate!([(9,Statistics.mean(time_data_points[8])+0.08,text("$(round(Statistics.mean(time_data_points[8]), digits=3))", 14, :black))])
#     annotate!([(9,Statistics.mean(time_data_points[9])+0.4,text("$(round(Statistics.mean(time_data_points[9]), digits=3))", 14, :orange))])

#     plot!(0:400, fill(Statistics.mean(time_data_points[7]), 100), seriestype=:hline, linestyle=:dash, linecolor=:blue, label="Avg. $(labels[1])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[8]), 100), seriestype=:hline, linestyle=:dash, linecolor=:black, label="Avg. $(labels[2])")
#     plot!(0:400, fill(Statistics.mean(time_data_points[9]), 100), seriestype=:hline, linestyle=:dash, linecolor=:orange, label="Avg. $(labels[3])")

#     plt = plot(pl1, pl2, pl3, legendfontsize = 12, xtickfontsize=14, ytickfontsize=14, layout = (1,3),
#                 title = subtitles, titlefontsize=16, guidefontsize=16, size = (300*scale,100*scale), yaxis=:log)

#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\")*"time_comparison_cs1.png")
#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\")*"time_comparison_cs1.pdf")
#     plt
# end

# ## case study 2: LD3F vs IVR

# #df_cs1 = CSV.read(joinpath(dirname(@__DIR__), "result_files\\clean_csv_files\\case_study_2_clean.csv"))

# function plot_time_cs2(df; choose_criterion="rwlav")
#     scale=5
#     df_crit = @linq df |> where(:criterion .== choose_criterion)
#     df_IVR = @linq df_crit |> where(:eq_model .== "rIVR")
#     df_LD3F = @linq df_crit |> where(:eq_model .== "LD3F")
#     plt = scatter(df_IVR.n_bus, [df_IVR.solve_time, df_LD3F.solve_time], ylims=[0, 1], markerstrokecolor=[:black :orange], markercolor= [:black :orange], markersize=[6 7],
#                     markershape = [:+ :circle], markeralpha=[1 0] , markerstrokealpha=[1 0.5], label=["IVR" "LD3F"], legend=:topleft,
#                      ylabel = "Solve time [s]", xlabel="Number of buses in the feeder [-]")

#     plot!(0:400, fill(Statistics.mean(df_IVR.solve_time), 2), seriestype=:hline, linestyle=:dash, linecolor=:black, label="Avg. IVR")
#     plot!(0:400, fill(Statistics.mean(df_LD3F.solve_time), 2), seriestype=:hline, linestyle=:dash, linecolor=:orange, label="Avg. LD3F")

#     plot!(legendfontsize = 12, xtickfontsize=14, ytickfontsize=14, titlefontsize=16, guidefontsize=16, size = (130*scale,100*scale))

#     annotate!([(410,Statistics.mean(df_IVR.solve_time)+0.02, text("$(round(Statistics.mean(df_IVR.solve_time), digits=3))", 14, :black))])
#     annotate!([(410,Statistics.mean(df_LD3F.solve_time)+0.02, text("$(round(Statistics.mean(df_LD3F.solve_time), digits=3))", 14, :orange))])

#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"compare_time_IVR_LD3F.pdf")
#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"compare_time_IVR_LD3F.png")
#     plt
# end

# function plot_errors_cs2(df; choose_criterion="rwlav")#The second plot: plt2 also good for case study 1!
#     scale=5
#     df_crit = @linq df |> where(:criterion .== choose_criterion)
#     df_IVR = @linq df_crit |> where(:eq_model .== "rIVR")
#     df_LD3F = @linq df_crit |> where(:eq_model .== "LD3F")
#     plt = scatter(df_IVR.n_bus, [df_LD3F.err_max, df_LD3F.err_avg], ylims=[0, 2*0.00167+0.0005], markerstrokecolor=[:black :orange], markercolor= [:black :orange], markersize=[6 7],
#                     markershape = [:+ :circle], markeralpha=[1 0] , markerstrokealpha=[1 0.5], label=[L"\varepsilon^{max, LD3F}" L"\varepsilon^{avg, LD3F}"],
#                      ylabel = L"\varepsilon"*" [p.u.]", xlabel="Number of buses in the feeder [-]")

#     plot!(0:400, fill(0.00167, 2), seriestype=:hline, linestyle=:dash, linecolor=:red, label = "")
#     plot!(0:400, fill(2*0.00167, 2), seriestype=:hline, linestyle=:dash, linecolor=:red, label = "")

#     plot!(legendfontsize = 15, xtickfontsize=14, ytickfontsize=14, titlefontsize=16, guidefontsize=16, size = (130*scale,100*scale), legend=:bottomright)

#     annotate!([(410, 0.00167+0.00007, text("σ", 14, :red))])
#     annotate!([(410, 0.00167*2+0.00007, text("2σ", 14, :red))])

#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_LD3F.pdf")
#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_LD3F.png")

#     ## SECOND PLOT ##

#     plt2 = scatter(df_IVR.n_bus, [df_IVR.err_max, df_IVR.err_avg], ylims=[0, 2*0.00167+0.0005], markerstrokecolor=[:black :orange], markercolor= [:black :orange], markersize=[6 7],
#                     markershape = [:+ :circle], markeralpha=[1 0] , markerstrokealpha=[1 0.5], label=[L"\varepsilon^{max, IVR}" L"\varepsilon^{avg, IVR}"],
#                      ylabel = L"\varepsilon"*" [p.u.]", xlabel="Number of buses in the feeder [-]")

#     plot!(0:400, fill(0.00167, 2), seriestype=:hline, linestyle=:dash, linecolor=:red, label = "")
#     plot!(0:400, fill(2*0.00167, 2), seriestype=:hline, linestyle=:dash, linecolor=:red, label = "")

#     plot!(legendfontsize = 15, xtickfontsize=14, ytickfontsize=14, titlefontsize=16, guidefontsize=16, size = (130*scale,100*scale), legend=:bottomright)

#     annotate!([(410, 0.00167+0.00007, text("σ", 14, :red))])
#     annotate!([(410, 0.00167*2+0.00007, text("2σ", 14, :red))])

#     savefig(plt2, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_IVRcs2.pdf")
#     savefig(plt2, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_IVRcs2.png")

# end

# ## case study 3: linear IVR vs IVR

# #df_cs1 = CSV.read(joinpath(dirname(@__DIR__), "result_files\\clean_csv_files\\case_study_3_clean.csv"))

# function plot_time_cs3(df; choose_criterion="rwlav")
#     scale=5
#     df_crit = @linq df |> where(:criterion .== choose_criterion)
#     df_IVR = @linq df_crit |> where(:linear_solver .== "ma27")
#     df_lin = @linq df_crit |> where(:linear_solver .== "gurobi")
#     plt = scatter(df_IVR.n_bus, [df_IVR.solve_time, df_lin.solve_time], ylims=[0, 1.8], markerstrokecolor=[:black :orange], markercolor= [:black :orange], markersize=[6 7],
#                     markershape = [:+ :circle], markeralpha=[1 0] , markerstrokealpha=[1 0.5], label=["Nonlinear IVR" "Linear IVR"], legend=:topleft,
#                      ylabel = "Solve time [s]", xlabel="Number of buses in the feeder [-]")

#     plot!(0:400, fill(Statistics.mean(df_IVR.solve_time), 2), seriestype=:hline, linestyle=:dash, linecolor=:black, label="Avg. NL")
#     plot!(0:400, fill(Statistics.mean(df_lin.solve_time), 2), seriestype=:hline, linestyle=:dash, linecolor=:orange, label="Avg. Linear")

#     plot!(legendfontsize = 12, xtickfontsize=14, ytickfontsize=14, titlefontsize=16, guidefontsize=16, size = (130*scale,100*scale))

#     annotate!([(410,Statistics.mean(df_IVR.solve_time)+0.02, text("$(round(Statistics.mean(df_IVR.solve_time), digits=3))", 14, :black))])
#     annotate!([(410,Statistics.mean(df_lin.solve_time)+0.02, text("$(round(Statistics.mean(df_lin.solve_time), digits=3))", 14, :orange))])

#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"time_comparison_cs3.pdf")
#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"time_comparison_cs3.png")
#     plt
# end

# ## case study 4

# function plot_errors_cs4(df; unknowns = 111, upper_y_lim=NaN)
#     scale=5
#     isnan(upper_y_lim) ? uylim = maximum(df.err_max) : uylim = upper_y_lim
#     plt = scatter(df.n_meas/unknowns, [df.err_max, df.err_avg], ylims=[0.0001, uylim], markerstrokecolor=[:black :orange], markercolor= [:black :orange], markersize=[7 7],
#                     markershape = [:+ :circle], markeralpha=[1 0] , markerstrokealpha=[1 0.5], label=[L"\varepsilon^{max}" L"\varepsilon^{avg}"],
#                      ylabel = L"\varepsilon"*" [p.u.]", xlabel="Measurements/unknowns ratio [-]")

#     plot!([1.0], seriestype=:vline, linestyle=:dash, linecolor=:red, label = "")

#     plot!(yaxis=:log, legendfontsize = 15, xtickfontsize=14, ytickfontsize=14, titlefontsize=16, guidefontsize=16, size = (130*scale,100*scale), legend=:bottomleft)

#     annotate!([(0.7, 0.0011, text("Underdetermined", 14, :black))])
#     annotate!([(1.25, 0.0011, text("Overdetermined", 14, :black))])

#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_cs4.pdf")
#     savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"error_cs4.png")
#     plt
# end