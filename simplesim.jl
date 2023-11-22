using Plots
using LinearAlgebra
using SatelliteToolbox

orb = KeplerianElements(
                        date_to_jd(2023,01,01),
                        7190.982e3,
                        0.001111,
                        98.405 |> deg2rad,
                        100    |> deg2rad,
                        90     |> deg2rad,
                        19     |> deg2rad
                        )

orbp = Propagators.init(Val(:TwoBody), orb)
orbp