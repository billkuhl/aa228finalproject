using POMDPs
using POMDPModels
using MCTS
using StaticArrays
using Markdown
using InteractiveUtils
using Plots
using Random
using Distributions
using SatelliteToolbox
using LinearAlgebra
import QuickPOMDPs: QuickPOMDP, QuickMDP
import POMDPTools: ImplicitDistribution, Deterministic
include("transition.jl")
include("structure.jl")
include("reward.jl")

# Initialize the keplarian elements of our orbit
initial_kep_pos = KeplerianElements(
                        date_to_jd(2023,01,01), # Epoch
                        7190.982e3, # Semi-Major Axis
                        0.00, # eccentricity
                        0 |> deg2rad, # Inclination
                        0    |> deg2rad, # Right Angle of Ascending Node
                        0     |> deg2rad, # Arg. of Perigree
                        0     |> deg2rad # True Anomaly
                        )

x_initial, v_initial = kepler_to_rv(initial_kep_pos) # convert to position and velocity
initial_sat_state = SatState(x_initial, v_initial) # create a SatState structure 

x_5k,v_5k = Propagators.propagate!(gen_orbp(initial_sat_state),10000) # propogate our intruder orbit (does this need to be in the reverse direction?)

Random.seed!(123)
intruder_v_noise = rand(MvNormal([0,0,0],Diagonal([500,500,0]))) # noise related to the intruder position
intruder_collide_state = SatState(x_5k,v_5k+intruder_v_noise) 
intruder_initial_state = prop_state(intruder_collide_state,-10000) # creating a SatState structure with the noise for intruder
initial_state = MDPState(initial_sat_state,[intruder_initial_state]) # Creates the initial state for our MDP

satellite = QuickMDP(
    gen = function(s,a)
        sp = next_state(s,a) # propogates to next state 
        r = get_R(sp,a) # gets reward for current state 
        return (sp = sp, r = r)
    end, 
    actions = [-1.,0,1], # forward, nothing, and backward
    discount = 0.95,
    transition = function(s,a) # transition function
        Deterministic(next_state(s,a))
    end, 
    initialstate = Deterministic(initial_state)
    # not implementing terminal state for now? 
)

# Initialize and run solver
solver = MCTSSolver(n_iterations = 10, depth = 20, exploration_constant = 5.0)
# a = action(planner, initial_state)
planner = solve(solver,satellite) # provides actions up to the specified depth(?)
trajectory = simulate(planner,satellite,initial_state) # gets the trjectory for the planner implemented with the MDP
plot_trajectory(trajectory)
# look at the tree itself, make sure it makes sense 