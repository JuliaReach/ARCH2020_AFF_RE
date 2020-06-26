using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "BUILDING"
cases = ["BLDF01-BDS01", "BLDF01-BDU01", "BLDF01-BDU02",
         "BLDF01-BDS01-discrete", "BLDF01-BDU01-discrete", "BLDF01-BDU02-discrete",
         "BLDC01-BDS01", "BLDC01-BDU01", "BLDC01-BDU02",
         "BLDC01-BDS01-discrete", "BLDC01-BDU01-discrete", "BLDC01-BDU02-discrete"]

SUITE[model] = BenchmarkGroup()

include("building.jl")
validation = []

# ----------------------------------------
#  BLDF01 (dense time)
# ----------------------------------------
prob_BLDF01 = building_BLDF01()

# BLDF01 - BDS01
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01) <= 0.0051
push!(validation, Int(property))
SUITE[model][cases[1]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# BLDF01 - BDU01
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01) <= 4e-3
push!(validation, Int(property))
SUITE[model][cases[2]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# BLDF01 - BDU02
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=x25))
property = ρ(x25, sol_BLDF01(20.0)) <= -0.78e-3
push!(validation, Int(property))
SUITE[model][cases[3]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.004, template=$x25))

# ----------------------------------------
#  BLDF01 (discrete time)
# ----------------------------------------

# BLDF01 - BDS01
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=x25, approx_model=NoBloating()))
property = ρ(x25, sol_BLDF01) <= 0.0051
push!(validation, Int(property))
SUITE[model][cases[4]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=$x25, approx_model=NoBloating()))

# BLDF01 - BDU01
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=x25, approx_model=NoBloating()))
property = ρ(x25, sol_BLDF01) <= 4e-3
push!(validation, Int(property))
SUITE[model][cases[5]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=$x25, approx_model=NoBloating()))

# BLDF01 - BDU02
sol_BLDF01 = solve(prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=x25, approx_model=NoBloating()))
property = ρ(x25, sol_BLDF01(20.0)) <= -0.78e-3
push!(validation, Int(property))
SUITE[model][cases[6]] = @benchmarkable solve($prob_BLDF01, T=20.0, alg=LGG09(δ=0.01, template=$x25, approx_model=NoBloating()))

# ----------------------------------------
#  BLDC01 (dense time)
# ----------------------------------------
prob_BLDC01 = building_BLDC01()

# BLDC01 - BDS01
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=x25e))
property = ρ(x25e, sol_BLDC01) <= 0.0051
push!(validation, Int(property))
SUITE[model][cases[7]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=$x25e))

# BLDC01 - BDU01
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=x25e))
property = ρ(x25e, sol_BLDC01) <= 4e-3
push!(validation, Int(property))
SUITE[model][cases[8]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=$x25e))

# BLDC01 - BDU02
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=x25e))
property = ρ(x25e, sol_BLDC01(20.0)) <= -0.78e-3
push!(validation, Int(property))
SUITE[model][cases[9]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.006, template=$x25e))

# ----------------------------------------
#  BLDC01 (discrete time)
# ----------------------------------------

# BLDC01 - BDS01
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=x25e, approx_model=NoBloating()))
property = ρ(x25e, sol_BLDC01) <= 0.0051
push!(validation, Int(property))
SUITE[model][cases[10]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=$x25e, approx_model=NoBloating()))

# BLDC01 - BDU01
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=x25e, approx_model=NoBloating()))
property = ρ(x25e, sol_BLDC01) <= 4e-3
push!(validation, Int(property))
SUITE[model][cases[11]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=$x25e, approx_model=NoBloating()))

# BLDC01 - BDU02
sol_BLDC01 = solve(prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=x25e, approx_model=NoBloating()))
property = ρ(x25e, sol_BLDC01(20.0)) <= -0.78e-3
push!(validation, Int(property))
SUITE[model][cases[12]] = @benchmarkable solve($prob_BLDC01, T=20.0, alg=LGG09(δ=0.01, template=$x25e, approx_model=NoBloating()))


sol_BLDF01 = nothing
sol_BLDC01 = nothing
GC.gc()

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
    runtimes[c] = round(t, digits=4)
end

for (i, c) in enumerate(cases)
    print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c])\n")
end

# ==============================================================================
# Plot
# ==============================================================================
#
