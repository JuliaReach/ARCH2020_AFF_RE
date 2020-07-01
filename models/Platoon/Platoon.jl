using ReachabilityAnalysis, SparseArrays

LazySets.set_ztol(Float64, 1e-14)

function platoon_connected(; deterministic_switching::Bool=true,
                             c1=5.0)  # clock constraints
    n = 10 # 9 dimensions + time
    # x' = Ax + Bu + c
    A = Matrix{Float64}(undef, n, n)
    A[1, :] = [0, 1.0, 0, 0, 0, 0, 0, 0, 0, 0]
    A[2, :] = [0, 0, -1.0, 0, 0, 0, 0, 0, 0, 0]
    A[3, :] = [1.6050, 4.8680, -3.5754, -0.8198, 0.4270, -0.0450, -0.1942,  0.3626, -0.0946, 0.]
    A[4, :] = [0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0,]
    A[5, :] = [0, 0, 1.0, 0, 0, -1.0, 0, 0, 0, 0]
    A[6, :] = [0.8718, 3.8140, -0.0754,  1.1936, 3.6258, -3.2396, -0.5950,  0.1294, -0.0796, 0.]
    A[7, :] = [0, 0, 0, 0, 0, 0, 0, 1.0, 0, 0]
    A[8, :] = [0, 0, 0, 0, 0, 1.0, 0, 0, -1.0, 0]
    A[9, :] = [0.7132, 3.5730, -0.0964,  0.8472, 3.2568, -0.0876,  1.2726,  3.0720, -3.1356, 0.]
    A[10, :] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0]; # t' = 1

    if deterministic_switching
        invariant = HalfSpace(sparsevec([n], [1.], n), c1) # t <= c1
    else
        invariant = Universe(n)
        # ? HalfSpace(sparsevec([n], [1.], n), tb) # t <= tb
    end

    # acceleration of the lead vehicle + time
    B = sparse([2], [1], [1.0], n, 1)
    U = Hyperrectangle(low=[-9.], high=[1.])
    c = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0]
    @system(x' = Ax + Bu + c, x ∈ invariant, u ∈ U)
end

function platoon_disconnected(; deterministic_switching::Bool=true,
                                c2=5.0)  # clock constraints
    n = 10 # 9 dimensions + time
    # x' = Ax + Bu + c
    A = Matrix{Float64}(undef, n, n)
    A[1, :] = [0, 1.0, 0, 0, 0, 0, 0, 0, 0, 0]
    A[2, :] = [0, 0, -1.0, 0, 0, 0, 0, 0, 0, 0]
    A[3, :] = [1.6050, 4.8680, -3.5754, 0, 0, 0, 0, 0, 0, 0]
    A[4, :] = [0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0,]
    A[5, :] = [0, 0, 1.0, 0, 0, -1.0, 0, 0, 0, 0]
    A[6, :] = [0, 0, 0,  1.1936, 3.6258, -3.2396, 0, 0, 0, 0.]
    A[7, :] = [0, 0, 0, 0, 0, 0, 0, 1.0, 0, 0]
    A[8, :] = [0, 0, 0, 0, 0, 1.0, 0, 0, -1.0, 0]
    A[9, :] = [0.7132, 3.5730, -0.0964,  0.8472, 3.2568, -0.0876,  1.2726,  3.0720, -3.1356, 0.]
    A[10, :] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0]; # t' = 1

    if deterministic_switching
        invariant = HalfSpace(sparsevec([n], [1.], n), c2) # t <= c2
    else
        invariant = Universe(n) # t is not constrained
    end

    # acceleration of the lead vehicle + time
    B = sparse([2], [1], [1.0], n, 1)
    U = Hyperrectangle(low=[-9.], high=[1.])
    c = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1.0]
    @system(x' = Ax + Bu + c, x ∈ invariant, u ∈ U)
end

#=
function platoon_continuous()

    m1 = platoon_connected()
    m2 = platoon_disconnected();

    # remove the time variable
    Ac = state_matrix(m1)[1:9, 1:9]
    An = state_matrix(m2)[1:9, 1:9]
    Aint = IntervalMatrix(An + interval(0.0, 1.0) .* (Ac - An));

    # acceleration of the lead vehicle + time
    B = sparse([2], [1], [1.0], 9, 1)
    U = Hyperrectangle(low=[-9.], high=[1.])
    invariant = Universe(9)

    @system(x' = Aint*x + B*u, x ∈ invariant, u ∈ U)
end

function platoon_continuous_split()

    m1 = platoon_connected()
    m2 = platoon_disconnected()

    # remove the time variable
    Ac = state_matrix(m1)[1:9, 1:9]
    An = state_matrix(m2)[1:9, 1:9]

    B = sparse([2], [1], [1.0], 9, 1)
    U = Hyperrectangle(low=[-9.], high=[1.])
    invariant = Universe(9)

    Svec = []
    for α in [interval(0.0, 0.5), interval(0.5, 1.0)]
        Aint = IntervalMatrix(An + α .* (Ac - An));
        Sx = @system(x' = Aint*x + B*u, x ∈ invariant, u ∈ U)
        push!(Svec, Sx)
    end
    return Svec
end

function platoon_continuous_split_largest()

    m1 = platoon_connected()
    m2 = platoon_disconnected()

    # remove the time variable
    Ac = state_matrix(m1)[1:9, 1:9]
    An = state_matrix(m2)[1:9, 1:9]

    B = sparse([2], [1], [1.0], 9, 1)
    U = Hyperrectangle(low=[-9.], high=[1.])
    invariant = Universe(9)

    # difference matrix
    X = Ac - An
    Xint = rand(IntervalMatrix, size(X)...)
    for i in 1:size(X, 1)
        for j in 1:size(X, 2)
            Xint[i, j] = interval(0, 1) * X[i, j]
        end
    end

    Dvec = []
    for α in mince(interval(0.0, 1.0), 5)
        Xint_α = copy(Xint)
        Xint_α[6, 2] = X[6, 2] * α
        push!(Dvec, Xint_α)
    end

    Svec = []
    for Di in Dvec
        Aint = An + Di
        Sx = @system(x' = Aint*x + B*u, x ∈ invariant, u ∈ U)
        push!(Svec, Sx)
    end
    return Svec
end
=#

function platoon(; deterministic_switching::Bool=true,
                   c1=5.0,  # clock constraints
                   c2=5.0,  # clock constraints
                   tb=10.0,  # lower bound for loss of communication
                   tc=20.0, tr=20.0) # upper bound for loss of communication (tc) and reset time (tr)

    # three variables for each vehicle, (ei, d(et)/dt, ai) for
    # (spacing error, relative velocity, speed), and the last dimension is time
    n = 9 + 1

    # transition graph
    automaton = LightAutomaton(2)
    add_transition!(automaton, 1, 2, 1)
    add_transition!(automaton, 2, 1, 2)

    # modes
    mode1 = platoon_connected(deterministic_switching=deterministic_switching, c1=c1)
    mode2 = platoon_disconnected(deterministic_switching=deterministic_switching, c2=c2)
    modes = [mode1, mode2]

    # common reset
    reset = Dict(n => 0.)

    # transition l1 -> l2
    if deterministic_switching
        guard = Hyperplane(sparsevec([n], [1.], n), c1) # t == c1
    else
        # tb <= t <= tc
        guard = HPolyhedron([HalfSpace(sparsevec([n], [-1.], n), -tb),
                             HalfSpace(sparsevec([n], [1.], n), tc)])
    end
    t1 = ConstrainedResetMap(n, guard, reset)

    # transition l2 -> l1
    if deterministic_switching
        guard = Hyperplane(sparsevec([n], [1.], n), c2) # t == c2
    else
        guard = HalfSpace(sparsevec([n], [1.], n), tr) # t <= tr
    end
    t2 = ConstrainedResetMap(n, guard, reset)
    resetmaps = [t1, t2]

    H = HybridSystem(automaton, modes, resetmaps, [AutonomousSwitching()])

    # initial condition is at the orgin in mode 1
    X0 = BallInf(zeros(n), 0.0)
    initial_condition = [(1, X0)]

    return IVP(H, initial_condition)
end

#=
function solve_platoon_continuous_split(δ, max_order)
    X0 = BallInf(zeros(9), 0.0)
    Svec = platoon_continuous_split_largest()
    alg = ASB07(δ=δ, max_order=max_order, approx_model=CorrectionHull(order=10))
    sol = []
    for Si in Svec
        ivpx = IVP(Si, X0)
        si = solve(IVP(Si, X0), T=20.0, alg=alg)
        #ivpx = @ivp(Si, x(0) ∈ X0)
        #si = solve(@ivp(Si, x(0) ∈ X0), T=20.0, alg=alg)
        push!(sol, si)
    end
    MixedFlowpipe([sol[i].F for i in 1:length(sol)])
end
=#

function dmin_specification(sol, dmin)
    return (-ρ(sparsevec([1], [-1.0], 10), sol)>dmin) &&
           (-ρ(sparsevec([4], [-1.0], 10), sol)>dmin) &&
           (-ρ(sparsevec([7], [-1.0], 10), sol)>dmin)
end
