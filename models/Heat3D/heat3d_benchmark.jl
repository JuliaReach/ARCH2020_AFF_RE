# We don't use BenchmarkTools for this model

model = "HEAT3D"
cases = ["HEAT01-discrete"] # , "HEAT02-discrete", "HEAT03-discrete", "HEAT04-discrete"]
results = Dict(model => Dict(c => -1.0 for c in cases))
max_temp = Dict()
validation = []
Tmax = [0.10369, 0.02966, 0.01716, 0.01161, 0.01005]

include("heat3d.jl")

Δ = 1e-4
NSTEPS = 2_000
recursive = Val(:false)
idx = 1 # index for the case considered

# ----------------------------------------
#  HEAT01 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat01(δ=0.02)

# warm-up run
out = Vector{Float64}(undef, NSTEPS)
reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true)
out = nothing
GC.gc()

out = Vector{Float64}(undef, NSTEPS)
results[model][cases[idx]] = @elapsed reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true)
max_out = maximum(out)
max_temp[cases[idx]] = max_out
property = max_out ∈ Tmax[idx] .. Tmax[idx] + Δ
push!(validation, Int(property))

out = nothing
GC.gc()

#=
# ----------------------------------------
#  HEAT02 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat02(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true, m=50, tol=1e-8)
@show maximum(out)

out = nothing
GC.gc()

# ----------------------------------------
#  HEAT03 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat03(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true, m=94, tol=1e-8)
@show maximum(out)

out = nothing
GC.gc()

# ----------------------------------------
#  HEAT04 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat04(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
results[model][cases[4]] = [@elapsed reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀ, sparse(ℓ), NSTEPS, recursive, hermitian=true, m=211, tol=1e-8) for _ in 1:1]
property = maximum(out) ∈ [Tmax - Δ, Tmax + Δ]
push!(validation, Int(property))
push!(max_temp, maximum(out))

out = nothing
GC.gc()
=#

# ==============================================================================
# Save benchmark results
# ==============================================================================

# export runtimes
runtimes = Dict()
for (i, c) in enumerate(cases)
    t = results[model][c] # in seconds
    runtimes[c] = round(t, digits=4)
end

for (i, c) in enumerate(cases)
    max_temp_c = round(max_temp[c], digits=6)
    print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c]), $max_temp_c\n")
end
