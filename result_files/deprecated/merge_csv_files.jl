using CSV

file1 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACP_PQVm_rforms_werrors_rwls.csv"
file2 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACP_PQVm_rforms_werrors_wlav.csv"
file3 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACP_PQVm_rforms_werrors.csv"
file4 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACR_PQVm_rforms_werrors_rwls.csv"
file5 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACR_PQVm_rforms_werrors_wlav.csv"
file6 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rACR_PQVm_rforms_werrors.csv"
file7 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_rforms_werrors_rwls.csv"
file8 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_rforms_werrors_wlav.csv"
file9 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_rforms_werrors.csv"

df1 = CSV.read(file1)
df2 = CSV.read(file2)
df3 = CSV.read(file3)
df4 = CSV.read(file4)
df5 = CSV.read(file5)
df6 = CSV.read(file6)
df7 = CSV.read(file7)
df8 = CSV.read(file8)
df9 = CSV.read(file9)

mumps_df = vcat(df1, df2, df3, df4, df5, df6, df7, df8, df9)

CSV.write("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_1_mumps.csv", mumps_df)

##


file1 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_1_ma27.csv"
file2 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\LD3F_PQVm_rforms_werrors_gurobi_wls.csv"
file3 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\LD3F_PQVm_rforms_werrors_gurobi_rwls.csv"
file4 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\LD3F_PQVm_rforms_werrors_gurobi_rwlav.csv"

df1 = CSV.read(file1)
df1_clean = @linq df1 |> where(:eq_model .== "rIVR")
df2 = CSV.read(file2)
df3 = CSV.read(file3)
df4 = CSV.read(file4)

df = vcat(df1_clean, df2, df3, df4)

CSV.write("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_2.csv", df)

##

file1 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_nl_vs_exlinear_rwlav.csv"
file2 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_nl_vs_exlinear_rwls.csv"
file3 = "C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\rIVR_PQVm_nl_vs_exlinear_wls.csv"

df1 = CSV.read(file1)
df2 = CSV.read(file2)
df3 = CSV.read(file3)

df_cs3 = vcat(df1, df2, df3)

CSV.write("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_3_update.csv", df_cs3)

##

df_to_fix = CSV.read("C:\\Users\\mvanin\\Desktop\\repos\\Results_DSSE_paper\\result_files\\case_study_3.csv")

df_fixed = df_to_fix
