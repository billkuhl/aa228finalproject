using("init.jl")
using("structure.jl")

function dists2intruders(s)


end 

function get_collision_R(s)
    intruder_dists = dists2intruders(target_state,intruder_states)
	penalty(dist) = 1e-6*(abs(dist))^3 # Not sure if I actually need the abs in this.
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
    


    total_reward = r_action + r_orbit +r_intruder 
    return total_reward
end 