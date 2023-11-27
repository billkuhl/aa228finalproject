# The goal of this one is using POMDP.jl to make a policy where we consier all states observable

using LinearAlgebra
using SatelliteToolbox
using Plots
using Distributions
import QuickPOMDPs: QuickPOMDP
import POMDPTools: ImplicitDistribution

