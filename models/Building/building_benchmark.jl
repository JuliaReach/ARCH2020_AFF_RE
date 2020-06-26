using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "BUILDING"
cases = ["BLDF01-BDS01", "BLDF01-BDU01", "BLDF01-BDU02",
         "BLDF01-BDS01-discrete", "BLDF01-BDU01-discrete", "BLDF01-BDU02-discrete"]

# , "BLDF01-D", "BLDC01", "BLDC01-D"]
SUITE[model] = BenchmarkGroup()

include("building.jl")
validation = []

# ----------------------------------------
#  BLDF01 (dense time)
# ----------------------------------------
prob_BLDF01 = building_BLDF01()

# BLDF01 - BDS01
sol_BLDF01_BDS01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01_BDS01) <= 0.0051
push!(validation, Int(property))
SUITE[model][cases[1]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# BLDF01 - BDU01
sol_BLDF01_BDU01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01_BDU01) <= 4e-3
push!(validation, Int(property))
SUITE[model][cases[2]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# BLDF01 - BDU02
sol_BLDF01_BDU01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01_BDU01(20.0)) <= -0.78e-3
push!(validation, Int(property))
SUITE[model][cases[3]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# ----------------------------------------
#  BLDF01 (discrete time)
# ----------------------------------------

# ----------------------------------------
#  BLDC01 (dense time)
# ----------------------------------------

# ----------------------------------------
#  BLDC01 (discrete time)
# ----------------------------------------

# ==============================================================================
# Execute benchmarks and save benchmark results
# ==============================================================================

# tune parameters
tune!(SUITE)

# run the benchmarks
results = run(SUITE, verbose=true)

# return the sample with the smallest time value in each test
println("minimum time for each benchmark:\n", minimum(results))

# return the median for each test
println("median time for each benchmark:\n", median(results))

# export runtimes
runtimes = Dict()
for (i, c) in enumerate(cases)
    t = median(results[model][c]).time * 1e-9
    runtimes[c] = t
end

for (i, c) in enumerate(cases)
    print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c])\n")
end

# ==============================================================================
# Plot
# ==============================================================================

#
