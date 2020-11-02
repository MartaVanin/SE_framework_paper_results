using Plots, CSV, DataFramesMeta

include("functions_for_plotting.jl")

## #XXX# CASE STUDY #1 #XXX# ##
##

cs1_df = CSV.read("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_1_ma27.csv")

## PLOT SOLVER TIME FOR ALL THREE EXACT FORMULATIONS, ALL CRITERIA

for pfform in unique(cs1_df.eq_model)
    plt = plot()
    cs1_df_seed = @linq cs1_df |> where(:seed .== 2)
    cs1_df_frm = @linq cs1_df_seed |> where(:eq_model .== pfform)
    idx = 1
    for crit in unique(cs1_df_frm.criterion)
        cs1_df_frm_cr = @linq cs1_df_frm |> where(:criterion .== crit)
        res, fast_df = find_fastest_rescaler(cs1_df_frm_cr)
        plt = compare_computation_time_criteria(plt, fast_df, pfform, crit, idx; yaxis_lim=Inf)
        idx+=1
    end
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"time_$(pfform).pdf")
end

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


## #XXX# CASE STUDY #2 #XXX# ##
##

cs2_df = CSV.read("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_2.csv")

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
    savefig(plt, joinpath(@__DIR__, "result_files\\plots\\")*"casestudy2_errors_$(pfform)_Max.pdf")
end
