# deactivate plot GUI, which is not available in Docker
ENV["GKSwstype"] = "100"

# instantiate project
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

function main()
    global io = open("runtimes.csv", "w")

    println("Running AFF benchmarks...")

    # Electromechanic break benchmark
    println("###\nRunning electromechanic-break benchmark\n###")
    include("models/EMBrake/embrake_benchmark.jl")

    # Building benchmark
    println("###\nRunning building benchmark\n###")
    include("models/Building/building_benchmark.jl")

    print(io, "\n")
    println("Finished running benchmarks.")
    close(io)
    nothing
end

main()
