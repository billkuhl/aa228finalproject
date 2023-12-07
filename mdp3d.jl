using POMDPs
using POMDPModels
using POMDPTools
using MCTS
using StaticArrays
using Markdown
using InteractiveUtils
using Plots
using Random
using Distributions
using SatelliteToolbox
using LinearAlgebra
using D3Trees
using ProgressBars
using JSON
import QuickPOMDPs: QuickPOMDP, QuickMDP

include("transition.jl")
include("structure.jl")
include("reward.jl")

# Initialize the keplarian elements of our orbit
initial_kep_pos = KeplerianElements(
                                    date_to_jd(2023,01,01), # Epoch
                                    7190.982e3, # Semi-Major Axis
                                    0, # eccentricity
                                    30 |> deg2rad, # Inclination
                                    0    |> deg2rad, # Right Angle of Ascending Node
                                    0     |> deg2rad, # Arg. of Perigree
                                    0     |> deg2rad # True Anomaly
                                    )

x_initial, v_initial = kepler_to_rv(initial_kep_pos) # convert to position and velocity

initial_sat_state = SatState(x_initial, v_initial) # create a SatState structure 

# x_5k,v_5k = Propagators.propagate!(gen_orbp(initial_sat_state),10000) 
set_impact_time = 1000
x_5k,v_5k = Propagators.propagate!(gen_orbp(initial_sat_state),set_impact_time) 

Random.seed!(123)
intruder_v_noise = rand(MvNormal([0,0,0],Diagonal([500,500,500]))) # noise related to the intruder position
intruder_collide_state = SatState(x_5k,v_5k+intruder_v_noise) 
# intruder_initial_state = prop_state(intruder_collide_state,-10000) # creating a SatState structure with the noise for intruder
intruder_initial_state = prop_state(intruder_collide_state,-set_impact_time)
initial_state = MDPState(initial_sat_state,[intruder_initial_state]) # Creates the initial state for our MDP

println("0. Initialize MDP")
satellite = QuickMDP(
    gen = function(s,a, rng)

        sp = next_state(s,a) # propogates to next state 
        if sp == "InvOrbit"
            sp = s
            r = -Inf # If we are going to throw 
            println("Invalid Orbit Tested")
        else
            
            r = get_R(sp,a) # gets reward for current state 

            
        end
        return (sp = sp, r = r)
    end, 
    actions = [-1.,0,1], # forward, nothing, and backward
    discount = 0.95, 
    initialstate = Deterministic(initial_state),
    isterminal = r -> r == -Inf
    # not implementing terminal state for now? 
)


# Initialize and run solver
println("1. Creating Solver")
solver = MCTSSolver(n_iterations = 5000, depth = 10, exploration_constant = 5.0, enable_tree_vis=true)
println("2. Creating Policy")
policy = solve(solver, satellite) # provides actions up to the specified depth(?)
#criteria = evaluate(satellite, policy) # evaluates the given policy
# value = value(policy,s) # returns expected sum of rewards if the policy is executed
a = action(policy, initial_state)
println(a)
# trajectory = simulate(p=policy,m=satellite,s0=initial_state) # gets the trjectory for the policy implemented with the MDP

println("3. Generate Trajectory")
states = []
rewards = []
actions = []
for (s,a,r) in ProgressBar(stepthrough(satellite,policy,"s,a,r", max_steps=100))
    append!(states,[s])
	append!(actions,[a])
	append!(rewards,[r])
end

intruder_x = []
target_x = []
for s in states
    push!(target_x,s.sat.x)
    for intruder in s.intruders
        push!(intruder_x,intruder.x)
    end
end

data = Dict("sat"=>target_x, "intruder"=>intruder_x, "actions" => actions, "rewards" => rewards)
json_string = JSON.json(data)

open("data\\3d_1k.json","w") do f
  JSON.print(f, json_string)
end





# plot_trajectory(trajectory)
# look at the tree itself, make sure it makes sense 
# look at individual trees to make sure its doing ok 
# increase number of n_iterations

# a, info = POMDPTools.action_info(planner, satellite, initial_state)
# tree = info[:tree]

# inchrome(D3Tree(tree)) # assumes you have the tree, using D3Tree

# if its spending a lot of time at suboptimal actions, then turn up exploration constant 
# look at shorter depth, a lot of iterations, make sure the tree makes sense 
# use the commands in Julia for the MCTS to investigate the tree (might be something liek above or might not)
# Look at POMDP tools