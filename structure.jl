mutable struct SatMDP
    # includes all things needed to run the QuickPOMDP Solver
	S_init #structure that defines the state object
	A::Array # [forward, no_change, backwards] step size small
	R::Function # Reward function
	T::Function # Transition model, orbit propogator
	gamma::Float64 # discount factor
	deltaT::Int # Time step
end

mutable struct SatState
	x::Array # contains x, y z for position
	v::Array # contains x', y', z' for velocity
end

mutable struct MDPState
	sat # SatState object (has position and velocity for satellite)
	intruders::Array # Array of satstate objects (array of positions and velocities for intruders)
end

