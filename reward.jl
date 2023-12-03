using("init.jl")
using("structure.jl")
using("transition.jl")

function dists2intruders(s::MDPState)
# need to iterate through all of the intruders 
    state = s.sat
    intruder_states = s.intruders
    intruder_dists = []
	for i_intruder in intruder_states
		int_dist = norm(state.x-i_intruder.x)
		intruder_dists = vcat(intruder_dists,int_dist)
	end

	return intruder_dists
end

function get_collision_R(s::MDPState)
    intruder_dists = dists2intruders(s)
	penalty(dist) = 1e-6*(abs(dist))^3
	max_penalty = maximum([penalty(d) for d in intruder_dists])
	if max_penalty < 0
		max_penalty = 0
	end

	return -max_penalty
end 

function get_orbit_R(s::MDPState)
    state = s.sat
    elements = rv_to_kepler(state.x,state.v)

    desired = KeplerianElements(
                        date_to_jd(2023,01,01), # Epoch
                        7190.982e3, # Semi-Major Axis
                        0, # eccentricity
                        0 |> deg2rad, # Inclination
                        0    |> deg2rad, # Right Angle of Ascending Node
                        0     |> deg2rad, # Arg. of Perigree
                        0     |> deg2rad # True Anomaly
                        )

    a_diff = abs(elements.a-desired.a)
    e_diff = abs(elements.e-desired.e)
    diff = a_diff + e_diff
    reward = -100*diff

    return reward
end 

function get_R(s::MDPState,a)

    if a == 0
        r_action = 0
    else 
        r_action = -10
    end 
	r_intruder = get_collision_R(s)
    r_orbit = get_orbit_R(s)
    total_reward = r_action + r_orbit +r_intruder 
    
    return total_reward
end 