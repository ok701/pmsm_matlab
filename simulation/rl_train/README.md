# PMSM Reinforcement Learning Agents

This  contains information on three different agents used for PMSM (Permanent Magnet Synchronous Motor) control via reinforcement learning.

## Agents and Configurations

### 1. **rlPMSMAgent.mat**
- **Description**: MATLAB-provided default RL agent for PMSM.
- **Reference Speed Values**: `[0.2, 0.4, 0.6, 0.8]`
- **Motor Parameters**: 
  ```matlab
  pmsm = mcb_SetPMSMMotorParameters('Maxon_EC_Speedgoat');
  pmsm.PositionOffset = 0.165;
  ```
- **Load Condition**: No load

---

### 2. **teknic_baseline.mat**
- **Description**: Baseline agent based on Teknic motor datasheet.
- **Reference Speed Values**: `[-0.2, -0.4, -0.6, -0.8, 0.2, 0.4, 0.6, 0.8]`
- **Motor Parameters**:
  ```matlab
  pmsm = mcb_SetPMSMMotorParameters('Teknic2310P');
  pmsm.PositionOffset = 0.0755;
  ```
- **Load Condition**: No load

---

### 3. **teknic_error_focused.mat**
- **Description**: A variation of `teknic_baseline.mat` with increased emphasis on rewards for error minimization.
- **Adjustments**:
  - Increased rewards for Q1 and Q2 to `10`.
- **Reference Speed Values**: Same as `teknic_baseline.mat`
- **Motor Parameters**: Same as `teknic_baseline.mat`
- **Load Condition**: Same as `teknic_baseline.mat`

---

## Notes
- Ensure to load the appropriate `.mat` file for the specific agent.
- The reference speed values determine the operating conditions under which the agents are tested.
- The motor parameters are set using MATLAB's PMSM configuration functions.
- When using `teknic_error_focused.mat`, consider the implications of increasing the reward for Q1 and Q2 on agent performance and training stability.
