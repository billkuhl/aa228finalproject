function prop_to_S(orbp::SatelliteToolboxPropagators.OrbitPropagatorTwoBody,t)
	# Turns propogators into state at a particular point.
	# t is a specific timestamp in seconds relative to the initialized date (Jan 1 2023)
	
	x, v  = Propagators.propagate!(orbp,t)
	return SatState(x,v)
end

function gen_orbp(state::SatState)
	
	kep = rv_to_kepler(state.x,state.v)
	prop = Propagators.init(Val(:TwoBody),kep)
	return prop
	
end

function prop_state(state::SatState,dt)
	orbp = gen_orbp(state)
	new_x,new_v = Propagators.propagate!(orbp,dt)
	new_state = SatState(new_x,new_v)
	return new_state
end

function next_state(state::MDPState, a)

	dt = 100 #randomly chosen, can change later
	unit_dV = 200.0 #m/s^2
    if a == 0
        new_sat = state.sat
    else
        dV_mag = unit_dV*a
        u_vel = state.sat.v/norm(state.sat.v)
        sat_changed_vel = SatState(state.sat.x, state.sat.v + dV_mag*u_vel)
        new_sat = prop_state(sat_changed_vel, dt)
    end

    new_intruders = []
    for intruder in state.intruders
        next_pos = prop_state(intruder, dt)
        new_intruders = vcat(new_intruders,next_pos)
    end

    new_MDPState = MDPState(new_sat,new_intruders)
    return new_MDPState
end 