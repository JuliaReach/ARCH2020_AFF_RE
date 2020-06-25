using BenchmarkTools, Plots, Plots.PlotMeasures, LaTeXStrings
using BenchmarkTools: minimum, median

SUITE = BenchmarkGroup()
model = "EMBRAKE"
cases = ["BRKDC01", "BRKDC01-D", "BRKNC01", "BRKNC01-D", "BRKNP01", "BRKNP01-D"]
SUITE[model] = BenchmarkGroup()

include("embrake.jl")
validation = []
time = []

# ----------------------------------------
#  BRKDC01
# ----------------------------------------

prob_no_pv_no_jit = embrake_no_pv(ζ=0., Tsample=1e-4)
alg = GLGM06(δ=1e-7, max_order=1, static=true, dim=4, ngens=4)
@btime sol_no_pv_no_jit = solve(prob_no_pv_no_jit, max_jumps=1001, alg=alg)


# verify that specification holds
property = ρ(eₓ, sol_no_pv_no_jit) < x0
push!(validation, Int(property))

GC.gc()

t = max_time(sol)
push!(times, trunc(t, digits=4))
println("maximum time than x < x0 , case $(cases[1]) : $t")

# benchmark
SUITE[model][cases[1]] = @benchmarkable solve($prob_no_pv_no_jit, max_jumps=1001, alg=$alg)

# ----------------------------------------
#  BRKDC01 (discrete-time)
# ----------------------------------------

# ----------------------------------------
#  BRKNC01
# ----------------------------------------

# ----------------------------------------
#  BRKNC01 (discrete-time)
# ----------------------------------------


# ----------------------------------------
#  BRKNP01
# ----------------------------------------


# ----------------------------------------
#  BRKNP01 (discrete-time)
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
    print(io, "JuliaReach, $model, $c, $(validation[i]), $(runtimes[c]), $(time[i])\n")
end

# ==============================================================================
# Plot
# ==============================================================================

sfpos = []
sfneg = []
times = []

polys = [VPolygon([ [inf(times[i]), sfpos[i]],
                  [inf(times[i]), -sfneg[i]],
                  [sup(times[i]), sfpos[i]],
                  [sup(times[i]), -sfneg[i]]]) for i in 1:length(sfpos)]

fig = Plots.plot()

plot!(fig, [X for X in polys[1:500:end]], color=:black, lw=1.0, linecolor=:black,
        tickfont=font(30, "Times"), guidefontsize=45,
        xlab=L"t",
        ylab=L"x",
        xtick=[0.025, 0.05, 0.075, 0.1], ytick=[0.0, 0.01, 0.02, 0.03, 0.04, 0.05],
        xlims=(0.0, 0.1), ylims=(0.0, 0.05),
        bottom_margin=6mm, left_margin=2mm, right_margin=12mm, top_margin=3mm,
        size=(1000, 1000))

savefig(fig, "ARCH-COMP20-JuliaReach-EMBrake.png")
savefig(fig, "ARCH-COMP20-JuliaReach-EMBrake.pdf")
