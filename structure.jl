include("init.jl")
struct SatMDP
    # includes all things needed to run the QuickPOMDP Solver
	S_init::MDPState #structure that defines the state object
	A::Array # [forward, no_change, backwards] step size small
	R::Function # kep_diff
	T::Function
	gamma::Float64
	deltaT::Int 
end
struct SatState
	x::Array
	v::Array
end
struct MDPState
	sat # SatState object
	intruders::Array # Array of satstate objects
end

