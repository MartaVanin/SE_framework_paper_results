################################################################################
#  Copyright 2021, Marta Vanin                                                 #
################################################################################
function add_some_noise!(data::Dict)
    Random.seed!(1)
    err_array = 1e-6:1e-6:2e-6
    for (_, meas) in data["meas"]
        σ = _DST.std.(meas["dst"])
        μ = _DST.mean.(meas["dst"])
        new_μ = [μ[i]*(1+rand(err_array)) for i in 1:length(meas["dst"])]
        meas["dst"] = [_DST.Normal(new_μ[i], σ[i]) for i in 1:length(meas["dst"])]
    end
end

function add_errors!(data::Dict; seed::Int64=1)
    for (m, meas) in data["meas"]
        σ = [_DST.std(meas["dst"][i]) for i in 1:length(meas["dst"])]
        new_μ = [_RAN.rand(_RAN.seed!(seed+parse(Int64,m)+i), _DST.Normal(_DST.mean(meas["dst"][i]), _DST.std(meas["dst"][i]))) for i in 1:length(meas["dst"])]
        meas["dst"] = [_DST.Normal(new_μ[i], σ[i]) for i in 1:length(σ)]
    end
end