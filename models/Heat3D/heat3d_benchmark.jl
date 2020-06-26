using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "HEAT3D"
cases = ["HEAT01", "HEAT01-discrete",
         "HEAT02", "HEAT02-discrete",
         "HEAT03", "HEAT03-discrete",
         "HEAT04", "HEAT04-discrete",
         "HEAT05", "HEAT05-discrete"]
SUITE[model] = BenchmarkGroup()

include("heat3d.jl")

NSTEPS = 2_000
recursive = Val(:false)

# ----------------------------------------
#  HEAT01 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat01(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time RA.reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true)
@show maximum(out)
GC.gc()

# ----------------------------------------
#  HEAT02 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat02(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time RA.reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true, m=50, tol=1e-8)
@show maximum(out)

# ----------------------------------------
#  HEAT03 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat03(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time RA.reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true, m=94, tol=1e-8)
@show maximum(out)

# ----------------------------------------
#  HEAT04 (discrete time)
# ----------------------------------------
A, Aᵀδ, Ω₀, ℓ = heat04(δ=0.02)
out = Vector{Float64}(undef, NSTEPS)
@time RA.reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀ, sparse(ℓ), NSTEPS, recursive, m=211, tol=1e-8)
@show maximum(out)
