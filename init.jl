using Random
initial_kep_pos = KeplerianElements(
                        date_to_jd(2023,01,01), # Epoch
                        7190.982e3, # Semi-Major Axis
                        0.001111, # eccentricity
                        0 |> deg2rad, # Inclination
                        0    |> deg2rad, # Right Angle of Ascending Node
                        0     |> deg2rad, # Arg. of Perigree
                        0     |> deg2rad # True Anomaly
                        )

x_initial, v_initial = kepler_to_rv(initial_kep_pos)

initial_state = SatState(x_initial, v_initial)

# find the position of our satellite at T = 5000s
x_5k,v_5k = Propagators.propagate!(gen_orbp(initial_state),10000)

#create noise for the velocity so it isn't the same orbit as our initial state

Random.seed!(123)
intruder_v_noise = rand(MvNormal([0,0,0],Diagonal([500,500,0])))

