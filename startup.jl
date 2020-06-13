# deactivate plot GUI, which is not available in Docker
ENV["GKSwstype"] = "100"

# instantiate project
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

function main()
    println("Running AFF benchmarks...")

#=
    println("###\nRunning Van der Pol benchmark\n###")
    include("VanDerPol/vanderpol_benchmark.jl")
    GC.gc()

    println("###\nRunning Laub-Loomis benchmark\n###")
    include("LaubLoomis/laubloomis_benchmark.jl")
    GC.gc()

    println("###\nRunning Quadrotor benchmark\n###")
    include("Quadrotor/quadrotor_benchmark.jl")
    GC.gc()

    println("###\nRunning production-destruction benchmark\n###")
    include("ProductionDestruction/production_destruction_benchmark.jl")
    GC.gc()

    println("###\nRunning Lotka-Volterra benchmark\n###")
    include("LotkaVolterra/lotka_volterra_benchmark.jl")
    GC.gc()

    println("###\nRunning Spacecraft benchmark\n###")
    include("Spacecraft/spaccraft_benchmark.jl")
    GC.gc()
=#

    println("Finished running benchmarks.")
    nothing

end

main()
