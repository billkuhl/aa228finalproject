using POMDPs
using POMDPModels
using MCTS
using StaticArrays

initial_state = 

satellite = QuickMDP(
    gen = function(s,a)
        r = get_R(s,a)
        sp = next_state(s,a)
        return {sp = sp, r = r}
    end, 
    actions = [-1.,0,1],
    discount = 0.95,
    transition = function(s,a)
        Deterministic(next_state(s,a))
    end, 
    initialstate = Deterministic(initial_state)

)

solver = MCTSSolver(n_iterations = 20, depth = 20, exploration_constant = 5.0)
planner = solve(solver,satellite)
trajectory = simulate(planner,satellite,initial_state)
# look at the tree itself, make sure it makes sense 