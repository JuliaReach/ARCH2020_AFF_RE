using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "PLATOONING"
cases = ["PLAD01-BND42", "PLAD01-BND42-discrete",
         "PLAD01-BND30", "PLAD01-BND30-discrete"]
#cases =
#["PLAA01-BND50", "PLAA01-BND50-discrete", "PLAA01-BND42", "PLAA01-BND42-discrete",
#"PLAN01-UNB50", "PLAN01-UNB50-discrete"]

SUITE[model] = BenchmarkGroup()

include("Platoon.jl")
validation = []

const boxdirs = BoxDirections{Float64, Vector{Float64}}(10)
const octdirs = CustomDirections([Vector(vi) for vi in OctDirections(10)])

# ----------------------------------------
#  PLAD01-BND42 (dense time)
# ----------------------------------------

prob_PLAD01_BND42 = platoon(; deterministic_switching=true)
sol_PLAD01_BND42 = solve(prob_PLAD01_BND42, alg=BOX(δ=0.01), max_jumps=10_000,
                         clustering_method=BoxClustering(1),
                         intersection_method=TemplateHullIntersection(boxdirs),
                         intersect_source_invariant=false,
                         tspan = (0.0 .. 20.0))
property = dmin_specification(sol_PLAD01_BND42, -42.0)
push!(validation, Int(property))
SUITE[model][cases[1]] = @benchmarkable solve($prob_PLAD01_BND42, alg=BOX(δ=0.01), max_jumps=10_000,
                               clustering_method=BoxClustering(1),
                               intersection_method=TemplateHullIntersection($boxdirs),
                               intersect_source_invariant=false,
                               tspan = (0.0 .. 20.0))

# ----------------------------------------
#  PLAD01-BND42 (discrete time)
# ----------------------------------------

prob_PLAD01_BND42 = platoon(; deterministic_switching=true)
sol_PLAD01_BND42_d = solve(prob_PLAD01_BND42,
                           alg=BOX(δ=0.1, approx_model=NoBloating()),
                           max_jumps=10_000,
                           clustering_method=BoxClustering(1, [3,1,1,1,1,1,1,1,1,1]),
                           intersection_method=TemplateHullIntersection(boxdirs),
                           intersect_source_invariant=false,
                           tspan = (0.0 .. 20.0))
property = dmin_specification(sol_PLAD01_BND42_d, -42.0)
push!(validation, Int(property))
SUITE[model][cases[2]] = @benchmarkable solve($prob_PLAD01_BND42,
                               alg=BOX(δ=0.1, approx_model=NoBloating()),
                               max_jumps=10_000,
                               clustering_method=BoxClustering(1, [3,1,1,1,1,1,1,1,1,1]),
                               intersection_method=TemplateHullIntersection($boxdirs),
                               intersect_source_invariant=false,
                               tspan = (0.0 .. 20.0))

#=

# ----------------------------------------
#  PLAA01-BND50 (dense time)
# ----------------------------------------

sol_PLAA01_BND50 = solve_platoon_continuous_split(0.01, 1200)

property = dmin_specification(sol_PLAA01_BND50, -50.0)
push!(validation, Int(property))
SUITE[model][cases[1]] = @benchmarkable solve_platoon_continuous_split(0.01, 1200)

# ----------------------------------------
#  PLAA01-BND50 (discrete time)
# ----------------------------------------

sol_PLAA01_BND50_d = solve_platoon_continuous_split(0.1, 400)

property = dmin_specification(sol_PLAA01_BND50_d, -50.0)
push!(validation, Int(property))
SUITE[model][cases[2]] = @benchmarkable solve_platoon_continuous_split(0.1, 400)

# ----------------------------------------
#  PLAA01-BND42 (dense time)
# ----------------------------------------

sol_PLAA01_BND42 = solve_platoon_continuous_split(0.01, 400)

property = dmin_specification(sol_PLAA01_BND42, -42.0)
push!(validation, Int(property))
SUITE[model][cases[3]] = @benchmarkable solve_platoon_continuous_split(0.01, 400)

# ----------------------------------------
#  PLAA01-BND42 (discrete time)
# ----------------------------------------

sol_PLAA01_BND42_d = solve_platoon_continuous_split(0.1, 1100)

property = dmin_specification(sol_PLAA01_BND42_d, -42.0)
push!(validation, Int(property))
SUITE[model][cases[4]] = @benchmarkable solve_platoon_continuous_split(0.1, 1100)

# ----------------------------------------
#  PLAD01-BND30 (dense time)
# ----------------------------------------

# ----------------------------------------
#  PLAD01-BND30 (discrete time)
# ----------------------------------------

# ----------------------------------------
#  PLAN01-UNB50 (dense time)
# ----------------------------------------

# ----------------------------------------
#  PLAN01-UNB50 (discrete time)
# ----------------------------------------

=#

sol_PLAD01_BND42 = nothing
sol_PLAD01_BND42_d = nothing
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
    tm = median(results[model][c]).time * 1e-9
    runtimes[c] = round(tm, digits=4)
end

for (i, c) in enumerate(cases)
    print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c])\n")
end

# ==============================================================================
# Plot
# ==============================================================================
#
