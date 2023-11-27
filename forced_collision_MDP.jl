# The goal of this one is using POMDP.jl to make a policy where we consier all states observable

using LinearAlgebra
using SatelliteToolbox
using Plots
using Distributions
import QuickPOMDPs: QuickPOMDP
import POMDPTools: ImplicitDistribution

function get_S(orbp::SatelliteToolboxPropagators.OrbitPropagatorJ4Osculating,t)
	# Turns propogators into state at a particular point.
	# t is a specific timestamp in seconds relative to the initialized date (Jan 1 2023)
	return [ Propagators.propagate!(orbp,t), t ]
end

function get_state_R(target_state, intruder_states, desired_orbit_radius)

	# Calculate the State Reward
	intuder_weight = 2
	desired_orbit_weight = 1
	danger_radius = 1000 #m - defines the radius from our target satellite where we start reducing 
	intruder_dists = dists2intruders(target_state,intruder_states)
	dist_from_desired = dist2desired(target_state,desired_orbit_radius)
	penalty(dist,desired_dist) = 1e-6*(desired_dist-dist)^3
	max_penalty = maximum([penalty(d,danger_radius) for d in intruder_dists])
	if max_penalty < 0
		max_penalty = 0
	elseif max_penalty > 0
		print("t ")
		print(t)
		print(" max penalty")
		println(max_penalty)
	end
	return minimum([abs(i) for i in intruder_dists])
end

function gen_orbp(state)
	# state = [[x],[v],t]
	kep = rv_to_kepler(state[1],state[2],state[3])
	prop = Propagators.propagate(Val(:J4osc),kep)
	
end


function next_state(state, a::Int, dt::Int)

	# As it is written now this is deterministic. If doing Monte Carlo we'll need to make sure this is randomised.
	
	pos, vel, t0 = state
	
	if (a in range(-5,5,step=1)) == false
		throw(DomainError(a,"This is not a valid action. Actions must be in the set [-5,5]."))
	end
	
	unit_dV = 200 #m/s^2
	dV_mag = unit_dV*a
	u_vel = vel/norm(vel)

	new_vel = vel + dV_mag*u_vel
	new_kep = rv_to_kepler(pos, new_vel,t0)
	new_orbp = Propagators.init(Val(:J4osc,), new_kep)
	return Propagators.step!(new_orbp,dt)
	
end 


function dist2desired(state, desired::Float64)
	# when I decide to make this usable for elliptical orbits will need to change desired
	pos, vel, t = state
	sat_rad = norm(pos)

	#will return a positive value if outside of the orbit and a negative value if inside of the orbit. Maybe a better way to design this is using keplerian elements? like differential in eccentricity, RAAN, Perigree, anomaly, etc. Can use a covariance matrix to define these
	return sat_rad - desired
end


function dists2intruders(state, intruder_states::Array)
	intruder_dists = []
	for i_intruder in intruder_vec
		int_dist = norm(state[1]-i_intruder[1])
		intruder_dists = vcat(intruder_dists,int_dist)
	end
	return intruder_dists
end


initial_orb_elements = KeplerianElements(
                        date_to_jd(2023,01,01), # Epoch
                        7190.982e3, # Semi-Major Axis
                        0.00, # eccentricity - Set to 0 for percfect circle in the ideal case
                        0 |> deg2rad, # Inclination - Set to 0 for 2D simplification
                        100    |> deg2rad, # Right Angle of Ascending Node
                        90     |> deg2rad, # Arg. of Perigree
                        19     |> deg2rad # True Anomaly
)

initial_orbp = Propagators.init(Val(:J4osc),target_orb_elements)

initial_state = get_S(initial_orbp, 0) # State at Time 0

begin
    # Create some test intruders to play with. Modify later to force a collision.

	intruders = []
	for ecc in range(0,.9,length=3)
		for raan in range(0,2*pi,length=10)
			for argp in range(0,2*pi,length=10)
				new_intruder_elements = KeplerianElements(
				                        date_to_jd(2023,01,01), # Epoch
				                        7190.982e3, # Semi-Major Axis
				                        ecc, # eccentricity
				                        0 |> deg2rad, # Inclination - Set to 0 for 2D simplification
				                        raan, # Right Angle of Ascending Node
				                        argp, # Arg. of Perigree
				                        19     |> deg2rad # True Anomaly
				)
				new_intruder_orb = Propagators.init(Val(:J4osc), new_intruder_elements)

				intruders = cat(dims=1,intruders,[get_S(new_intruder_orb,0)])
			end
		end
	end
end


satellite_control = QuickPOMDP(
	
	actions = range(-5,5,step=1),
    obstype = Array,
    discount = 0.95,

    transition = function (s, a, sp)        
        ImplicitDistribution() do rng
            x, v, t  = s

			xp,vp,t=[0,0,0]
            
            return (xp, vp, t)
        end
    end,

    observation = (a, sp) -> Normal(sp[1], 0.15),

    reward = function (s, a, sp)
        if sp[1] > 0.5
            return 100.0
        else
            return -1.0
        end
    end,

    initialstate = ImplicitDistribution(rng -> (-0.2*rand(rng), 0.0)),
    isterminal = s -> s[1] > 0.5
	
)