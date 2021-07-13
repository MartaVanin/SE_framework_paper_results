function add_reduced_gaussian_noise(data::Dict)
    Random.seed!(123)
    for (_, meas) in data["meas"]
        σ = _DST.std.(meas["dst"])
        μ = _DST.mean.(meas["dst"])
        new_μ = [rand(_DST.Normal(μ[i], σ[i]/1000),1)[1] for i in 1:length(meas["dst"])]
        meas["dst"] = [_DST.Normal(new_μ[i], σ[i]) for i in 1:length(meas["dst"])]
    end
end
