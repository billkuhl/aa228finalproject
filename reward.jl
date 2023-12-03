using("init.jl")
using("structure.jl")
using("transition.jl")

function dist2desired(state, desired::Float64)
    
    sat_rad = norm(state.x)
	# Will return a positive value if outside of the orbit and a negative value if inside of the orbit. 
	# Maybe a better way to design this is using keplerian elements? 
	# Like differential in eccentricity, RAAN, Perigree, anomaly, etc. Can use a covariance matrix to define these
	
	return sat_rad - desired
end

function get_state_R(s)
    x = s.x
	zero_radius = 1000 #m - further away from target path than this, we get 0 reward
	dist_from_desired = dist2desired(target_state,desired_orbit_radius)
	reward(dist) = 1e-6*(abs(dist)-zero_radius)^3 
	
	if abs(dist_from_desired) > zero_radius
		return 0
	else
		return reward(dist_from_desired)
	end
end

function dists2intruders(state, intruder_states::Array)
# need to iterate through all of the intruders 
    intruder_dists = []
	for i_intruder in intruder_states
		int_dist = norm(state.x-i_intruder.x)
		intruder_dists = vcat(intruder_dists,int_dist)
	end
	return intruder_dists
end

function get_collision_R(target_state,intruder_states)
    intruder_dists = dists2intruders(target_state,intruder_states)
	penalty(dist) = 1e-6*(abs(dist))^3
	max_penalty = maximum([penalty(d) for d in intruder_dists])

	if max_penalty < 0
		max_penalty = 0
	end
	return -max_penalty
end 

function reward(s,a)
    if a == 0
        r_action = 0
    else 
        r_action = -10
    end 

    r_orbit = get_state_R(s)
    total_reward = r_action + r_orbit +r_intruder 
    return total_reward
end 


function get_R(s, a, sp, env)
	
	intruder_list_orbp, desired_orbit = env #Env is a list of these two things.
	intruder_states = [get_S(intruder_orbp,s[3]) for intruder_orbp in intruder_list_orbp]
	
	intuder_weight = 2
	desired_orbit_weight = 1
	
	orbit_reward = get_state_R(s, desired_orbit #=rn just a distance=# ) 
	collision_penalty = get_collision_R(s, intruder_states)
	
end