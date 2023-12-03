function prop_to_S(orbp::SatelliteToolboxPropagators.OrbitPropagatorTwoBody,t)
	# Turns propogators into state at a particular point.
	# t is a specific timestamp in seconds relative to the initialized date (Jan 1 2023)
	new_sat = SatState()
	new_sat.x, new_sat.v  = Propagators.propagate!(orbp,t)
	return new_sat
end

function gen_orbp(state)
	
	kep = rv_to_kepler(state.x,state.v)
	prop = Propagators.init(Val(:TwoBody),kep)
	return prop
	
end

function prop_state(state,dt)
	orbp = gen_orbp(state)
	new_x,new_v = Propagators.propagate!(orbp,dt)
	new_state = SatState(new_x,new_v)
	return new_state
end

function next_state(state, a, dt::Int)
	
	unit_dV = 200.0 #m/s^2
    if a == 0
    else
        dV_mag = unit_dV*a
        u_vel = vel/norm(vel)
        s_changed_vel = SatState(state.sat.x, vel + dV_mag*u_vel)
        new_orbp = gen_orbp()
        return get_S(new_orbp, t0 + dt)
    end
end 

