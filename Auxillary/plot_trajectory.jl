using Plots 

function plot_trajectory(trajectory)
    state = trajectory.state # should be of type MDPState
    action = trajectory.action # should be 
    reward = trajectory.reward # reward at each time SuiteSparse

    position = state.sat.x
    x_orb = position[1]
    y_orb = position[2]
    # plot(x_orb,y_orb)

end 