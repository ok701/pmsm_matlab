# PMSM Simulation with FOC Control (PI and Reinforcement Learning)

This project simulates a Permanent Magnet Synchronous Motor (PMSM) with Field-Oriented Control (FOC) using both PI control and Reinforcement Learning.

## How to Run

1. Open and execute `main.mlx` in MATLAB 2023a.
2. To modify motor parameters, edit the file `mcb_pmsm_foc_sim_RL_data.m`.

## Current Configuration

- **Motor**: Default Teknic motor data
- **Position Offset**: `0.0755`  

## Friction Modeling

- **Viscous Friction**: Included in the simulation
- **Static Friction**: Not accounted for in this version
