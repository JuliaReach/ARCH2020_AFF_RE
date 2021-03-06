using ReachabilityAnalysis, JLD2

LazySets.set_ztol(Float64, 1e-14)

const x25 = [zeros(24); 1.0; zeros(23)]
const x25e = vcat(x25, 0.0);
building_path = joinpath(@__DIR__, "building.jld2")

function building_BLDF01()
    @load building_path H
    vars = collect(keys(H.ext[:variables]))
    A = state_matrix(mode(H, 1))
    n = size(A, 1) - 1
    A = A[1:n, 1:n]
    B = input_matrix(mode(H, 1))[1:n, 1]
    U = Hyperrectangle(low=[0.8], high=[1.0])
    S = @system(x' = Ax + Bu, u ∈ U, x ∈ Universe(n));

    # initial states
    center_X0 = [fill(0.000225, 10); fill(0.0, 38)]
    radius_X0 = [fill(0.000025, 10); fill(0.0, 14); 0.0001; fill(0.0, 23)]
    X0 = Hyperrectangle(center_X0, radius_X0)

    prob_BLDF01 = InitialValueProblem(S, X0)
end

function building_BLDC01()
    @load building_path H
    vars = collect(keys(H.ext[:variables]))
    A = state_matrix(mode(H, 1))
    n = size(A, 1) - 1
    A = A[1:n, 1:n]
    Ae = copy(transpose(hcat(transpose(hcat(A, zeros(48))), zeros(49))))
    S = LinearContinuousSystem(Ae)

    # initial states
    center_X0 = [fill(0.000225, 10); fill(0.0, 38)]
    radius_X0 = [fill(0.000025, 10); fill(0.0, 14); 0.0001; fill(0.0, 23)]
    X0 = Hyperrectangle(center_X0, radius_X0)
    U = Hyperrectangle(low=[0.8], high=[1.0])
    X0 = X0 * U

    prob_BLDC01 = InitialValueProblem(S, X0)
end
