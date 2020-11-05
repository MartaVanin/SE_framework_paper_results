using Plots, PyPlot, CSV, DataFramesMeta, Statistics

include("functions_for_plots.jl")

## #XXX# CASE STUDY #1 #XXX# ##
##



## PLOT AVERAGE ERROR FOR ALL THREE EXACT FORMULATIONS, ALL CRITERIA
for pfform in unique(cs1_df.eq_model)
    plt = plot()
    cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
    cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs1_df_frm.criterion)
        cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=Inf, max_or_avg="Avg.")
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"errors_$(pfform)_Avg.pdf")
end

## PLOT MAXIMUM ERROR FOR ALL THREE EXACT FORMULATIONS, ALL CRITERIA
for pfform in unique(cs1_df.eq_model)
    plt = plot()
    cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
    cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs1_df_frm.criterion)
        cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=Inf, max_or_avg="Max.")
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"errors_$(pfform)_Max.pdf")
end


## PLOT AVERAGE ERROR FOR ALL THREE EXACT FORMULATIONS, ALL CRITERIA, without outlier
for pfform in unique(cs1_df.eq_model)
    plt = plot()
    cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
    cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs1_df_frm.criterion)
        cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=0.002, max_or_avg="Avg.")
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"errors_$(pfform)_Avg_nooutlier.pdf")
end

## PLOT MAXIMUM ERROR FOR ALL THREE EXACT FORMULATIONS, ALL CRITERIA, without outlier
for pfform in unique(cs1_df.eq_model)
    plt = plot()
    cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
    cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs1_df_frm.criterion)
        cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=0.007, max_or_avg="Max.")
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"errors_$(pfform)_Max_nooutlier.pdf")
end


## compact PLOT ANY FORMULATION, Any CRITERIA, without outlier

plt = plot()
cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== "rIVR")
cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== "rwlav")
res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
plt = compare_errors_compact(plt, fast_df; yaxis_lim=0.007)
savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"errors_compact_nooutlier.pdf")



## #XXX# CASE STUDY #2 #XXX# ##
##

cs2_df = CSV.read("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\clean_csv_files\\case_study_2_clean.csv")

## PLOT MAXIMUM ERROR FOR LINEAR VS IVR EXACT FORMULATIONS, ALL CRITERIA
for pfform in unique(cs2_df.eq_model)
    plt = plot()
    cs2_df_seed = @linq cs2_df |> where(:seed .== 2)
    cs2_df_frm = @linq cs2_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs2_df_frm.criterion)
        cs2_df_frm_cr = @linq cs2_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs2_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=Inf, max_or_avg="Max.")
        idx+=1
    end
    savefig(plt, joinpath(dirname(@__DIR__), "result_files\\plots\\")*"casestudy2_errors_$(pfform)_Max.pdf")
end

## PLOT COMPACT ERROR FOR LINEARIZED VS IVR EXACT FORMULATIONS, ALL CRITERIA, no outlier
plt = plot()
cs2_df_seed = @linq cs2_df |> where(:seed .== 2)
cs2_df_frm = @linq cs2_df_seed |> where(:eq_model .== "LD3F")
cs2_df_frm_cr = @linq cs2_df_frm |> where(:criterion .== "rwls")
res, fast_df2 = find_fastest_rescaler(cs2_df_frm_cr)
plt = compare_errors_compact(plt, fast_df2; yaxis_lim=0.007)
savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"casestudy2_errors_compact_nooutlier.pdf")

for pfform in unique(cs2_df.eq_model)
    plt = plot()
    cs2_df_seed = @linq cs2_df |> where(:seed .== 2)
    cs2_df_frm = @linq cs2_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs2_df_frm.criterion)
        cs2_df_frm_cr = @linq cs2_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs2_df_frm_cr)
        plt = compare_computation_time_criteria(plt, fast_df, pfform, crit, idx; yaxis_lim=Inf)
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"time_$(pfform).pdf")
end

plt = plot()
cs2_df_seed = @linq cs2_df |> where(:seed .== 2)
cs2_df_crit = @linq cs2_df_seed |> where(:criterion .== "rwlav")
cs2_df_ivr = @linq cs2_df_crit |> where(:eq_model .== "rIVR")
cs2_df_ld3f = @linq cs2_df_crit |> where(:eq_model .== "LD3F")
res, fast_df_ivr = find_fastest_rescaler(cs2_df_ivr)
res, fast_df_ld3f = find_fastest_rescaler(cs2_df_ld3f)
plt = compare_time_compact(plt, cs2_df_ivr, cs2_df_ld3f; yaxis_lim=0.85)
savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"compare_time_IVR_LD3F.pdf")


## #XXX# CASE STUDY #3 #XXX# ##
##

cs3_df = CSV.read("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_3.csv")

plt = plot()
cs3_df_seed = @linq cs3_df |> where(:seed .== 2)
cs3_df_crit = @linq cs3_df_seed |> where(:criterion .== "rwlav")
cs3_df_nl = @linq cs3_df_crit |> where(:linear_solver .== "ma27")
cs3_df_lin = @linq cs3_df_crit |> where(:linear_solver .== "mumps")
res, fast_df_nl = find_fastest_rescaler(cs3_df_nl)
res, fast_df_lin = find_fastest_rescaler(cs3_df_lin)
plt = compare_time_compact(plt, cs3_df_nl, cs3_df_lin; yaxis_lim=Inf)
savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"compare_time_IVR_lin_nl.pdf")

plt = plot()
cs3_df_seed = @linq cs3_df |> where(:seed .== 2)
cs3_df_frm = @linq cs3_df_seed |> where(:eq_model .== "rIVR")
cs3_df_frm_slv = @linq cs3_df_frm |> where(:linear_solver .== "mumps")
idx = 1
for crit in unique(cs3_df_frm_slv.criterion)
    cs3_df_frm_cr = @linq cs3_df_frm_slv |> where(:criterion .== crit)
    res, fast_df = find_fastest_rescaler(cs3_df_frm_cr)
    plt = compare_computation_time_criteria(plt, fast_df, "rIVR", crit, idx; yaxis_lim=Inf)
    idx+=1
end
savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"time_exactlinear_IVR.pdf")

for pfform in unique(cs3_df.linear_solver)
    plt = plot()
    cs3_df_seed = @linq cs3_df |> where(:seed .== 2)
    cs3_df_frm = @linq cs3_df_seed |> where(:linear_solver .== pfform)
    idx = 1
    for crit in unique(cs3_df_frm.criterion)
        cs3_df_frm_cr = @linq cs3_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs3_df_frm_cr)
        plt = compare_errors(plt, fast_df, pfform, crit, idx; yaxis_lim=0.005, max_or_avg="Max.")
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"casestudy3_errors_Max_$(pfform).pdf")
end
