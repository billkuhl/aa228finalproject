function dists2intruders(s::MDPState)
# Calculates the distance between satellite and intruders
    state = s.sat # get satellite state 
    intruder_states = s.intruders # get intruder states as an array
    intruder_dists = []
	for i_intruder in intruder_states # find and add all distances
		int_dist = norm(state.x-i_intruder.x)
		intruder_dists = vcat(intruder_dists,int_dist)
	end

	return intruder_dists
end

function get_collision_R(s::MDPState)
# Calculates collision reward based on distance between satellite and intruders
    intruder_dists = dists2intruders(s)
	penalty(dist) = 1e-6*(abs(dist))^3 # applies a penalty proportional to intruder distance
	max_penalty = maximum([penalty(d) for d in intruder_dists])
	if max_penalty < 0
		max_penalty = 0
	end

	return -max_penalty
end 

function get_orbit_R(s::MDPState)
# Calculates reward for staying close to orbit 
    state = s.sat
    elements = rv_to_kepler(state.x,state.v) # converts to orbital elements

    # Sets desired orbital parameters (in a single orbital plane)
    desired = KeplerianElements(
                        date_to_jd(2023,01,01), # Epoch
                        7190.982e3, # Semi-Major Axis
                        0, # eccentricity
                        0 |> deg2rad, # Inclination
                        0    |> deg2rad, # Right Angle of Ascending Node
                        0     |> deg2rad, # Arg. of Perigree
                        0     |> deg2rad # True Anomaly
                        )

    a_diff = abs(elements.a-desired.a) # difference in semi-major axis
    e_diff = abs(elements.e-desired.e) # difference in eccentricity
    diff = a_diff + e_diff
    reward = -100*diff # calculates reward as a function of the differences

    return reward
end 

function get_action_R(a)
# Calculates the reward of taking an action 
    if a == 0
        r_action = 0
    else 
        r_action = -10
    end 
    
    return r_action
end 

function get_R(s::MDPState,a)
# Calculates the total reward of an action and state 
    r_action = get_action_R(a)
	r_intruder = get_collision_R(s)
    r_orbit = get_orbit_R(s)
    total_reward = r_action + r_orbit +r_intruder 

    return total_reward
end 