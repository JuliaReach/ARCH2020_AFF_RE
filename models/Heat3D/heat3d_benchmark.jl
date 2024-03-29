using Plots, Plots.PlotMeasures, LaTeXStrings

# We don't use BenchmarkTools for this model

model = "HEAT3D"
cases = ["HEAT01-discrete", "HEAT02-discrete"]
if TEST_LONG
    push!(cases, "HEAT03-discrete")
    push!(cases, "HEAT04-discrete")
end
push!(cases, "HEAT01-continuous")
push!(cases, "HEAT02-continuous")

results = Dict(model => Dict(c => -1.0 for c in cases))
max_temp = Dict()
validation = []
Tmax = [0.10369, 0.02966, 0.01716, 0.01161, 0.01005]

include("heat3d.jl")

Δ = 1e-4
NSTEPS = 2_000
recursive = Val(:false)
idx = 0 # index for the case considered

# ----------------------------------------
#  HEAT01 (discrete time)
# ----------------------------------------
idx += 1
A, _, Ω₀, ℓ = heat01(δ=0.02)
ivp = @ivp(x' = A * x, x ∈ Universe(size(A, 1)), x(0) ∈ Ω₀);
sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ], approx_model=NoBloating())) # warm-up run
results[model][cases[idx]] = @elapsed sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ], approx_model=NoBloating()))
max_out = ρ(ℓ, sol)
max_temp[cases[idx]] = max_out
property = max_out ∈ Tmax[1] .. Tmax[1] + Δ
push!(validation, Int(property))

sol = nothing
GC.gc()

# ----------------------------------------
#  HEAT02 (discrete time)
# ----------------------------------------
idx += 1
A, _, Ω₀, ℓ = heat02(δ=0.02)
ivp = @ivp(x' = A * x, x ∈ Universe(size(A, 1)), x(0) ∈ Ω₀);
sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ], approx_model=NoBloating())) # warm-up run
results[model][cases[idx]] = @elapsed sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ], approx_model=NoBloating()))
max_out = ρ(ℓ, sol)
max_temp[cases[idx]] = max_out
property = max_out ∈ Tmax[2] .. Tmax[2] + Δ
push!(validation, Int(property))

sol = nothing
GC.gc()

# ----------------------------------------
#  HEAT03 (discrete time)
# ----------------------------------------
if TEST_LONG
    idx += 1
    A, Aᵀδ, Ω₀, ℓ = heat03(δ=0.02)

    # warm-up run
    out = Vector{Float64}(undef, 1)
    reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ, sparse(ℓ), 1, recursive, m=94, tol=1e-8, hermitian=true)

    out = Vector{Float64}(undef, NSTEPS)
    results[model][cases[idx]] = @elapsed reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ,
                            sparse(ℓ), NSTEPS, recursive, m=94, tol=1e-8, hermitian=true)
    max_out = maximum(out)
    max_temp[cases[idx]] = max_out
    property = max_out ∈ Tmax[3] .. Tmax[3] + Δ
    push!(validation, Int(property))

    out = nothing
    GC.gc()
end

# ----------------------------------------
#  HEAT04 (discrete time)
# ----------------------------------------
if TEST_LONG
    idx += 1
    A, Aᵀδ, Ω₀, ℓ = heat04(δ=0.02)
    out = Vector{Float64}(undef, NSTEPS)
    results[model][cases[idx]] = @elapsed reach_homog_dir_LGG09_expv_pk2!(out, Ω₀, Aᵀδ,
                            sparse(ℓ), NSTEPS, recursive, m=211, tol=1e-8, hermitian=true)
    max_out = maximum(out)
    max_temp[cases[idx]] = max_out
    property = max_out ∈ Tmax[4] .. Tmax[4] + Δ
    push!(validation, Int(property))

    out = nothing
    GC.gc()
end

# ----------------------------------------
#  HEAT01 (continuous time)
# ----------------------------------------
idx += 1
A, _, Ω₀, ℓ = heat01(δ=0.02)
ivp = @ivp(x' = A * x, x ∈ Universe(size(A, 1)), x(0) ∈ Ω₀);
sol = solve(ivp, T=1.0, alg=LGG09(δ=0.02, template=[ℓ])) # warm-up run
results[model][cases[idx]] = @elapsed sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ]))
max_out = ρ(ℓ, sol)
max_temp[cases[idx]] = max_out
property = Tmax[1] ≤ max_out
push!(validation, Int(property))

sol = nothing
GC.gc()

# ----------------------------------------
#  HEAT02 (continuous time)
# ----------------------------------------
idx += 1
A, _, Ω₀, ℓ = heat02(δ=0.02)
ivp = @ivp(x' = A * x, x ∈ Universe(size(A, 1)), x(0) ∈ Ω₀)
results[model][cases[idx]] = @elapsed sol = solve(ivp, T=40.0, alg=LGG09(δ=0.02, template=[ℓ]))
max_out = ρ(ℓ, sol)
max_temp[cases[idx]] = max_out
property = Tmax[2] ≤ max_out
push!(validation, Int(property))

sol = nothing
GC.gc()

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

# ==============================================================================
# Plot
# ==============================================================================

function flowpipe_HEAT01()
    δ = 0.02
    NSTEPS = 2000
    recursive = Val(:false)
    A, Aᵀδ, Ω₀, ℓ = heat01(δ=δ)

    out_plus = Vector{Float64}(undef, NSTEPS)
    reach_homog_dir_LGG09_expv_pk2!(out_plus, Ω₀, Aᵀδ, sparse(ℓ), NSTEPS, recursive, hermitian=true)

    out_minus = Vector{Float64}(undef, NSTEPS)
    reach_homog_dir_LGG09_expv_pk2!(out_minus, Ω₀, Aᵀδ, sparse(-ℓ), NSTEPS, recursive, hermitian=true)

    [Interval(i*δ, (i+1)*δ) × Interval(-out_minus[i+1], out_plus[i+1]) for i in 0:NSTEPS-1]
end

sol = flowpipe_HEAT01()
fig = Plots.plot()

Plots.plot!(fig, sol, linecolor=:blue, color=:blue, alpha=0.8,
    tickfont=font(30, "Times"), guidefontsize=45,
    xlab=L"t",
    ylab=L"x_{62}", # in the original model this is called x62
    xtick=[0., 10., 20., 30., 40.], ytick=[0, 0.025, 0.05, 0.075, 0.1],
    xlims=(0., 40.), ylims=(0.0, 0.11),
    bottom_margin=6mm, left_margin=2mm, right_margin=4mm, top_margin=3mm,
    size=(1000, 1000))

savefig("ARCH-COMP20-JuliaReach-Heat3D.pdf")

sol = nothing
GC.gc()
