function add_reduced_gaussian_noise(data::Dict)
    Random.seed!(123)
    for (_, meas) in data["meas"]
        σ = _DST.std.(meas["dst"])
        μ = _DST.mean.(meas["dst"])
        new_μ = [rand(_DST.Normal(μ[i], σ[i]/1000),1)[1] for i in 1:length(meas["dst"])]
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