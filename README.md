# Learn PMSM Control

Permanent Magnet Synchronous Motor (PMSM) control in MATLAB is well described in the  
👉 [**MATLAB Motor Control Blockset**](https://kr.mathworks.com/help/mcb/index.html?s_tid=CRUX_lftnav).

If you're not sure where to start, follow this order to go from traditional speed control to reinforcement learning.

### Step 1: Learn the Basics

Start with the MATLAB Academy tutorial:  
👉 [**Introduction to Motor Control**](https://matlabacademy.mathworks.com/kr/details/introduction-to-motor-control/otslimc)

All example codes are located in the [simulation/tutorial/](simulation/tutorial/)
 directory so you can run them directly.



### Step 2: Using Reinforcement Learning

The **Twin Delayed Deep Deterministic Policy Gradient (TD3)** implementation for PMSM control is in [simulation/rl/](simulation/rl/).  
Learn more here:  
👉 [**TD3 Reinforcement Learning for PMSM Control**](https://kr.mathworks.com/help/reinforcement-learning/ug/train-td3-agent-for-pmsm-control.html)



### Step 3: Deploy in Hardware
Deployment of FOC (Field-Oriented Control) speed control can be found under the [deploy/](deploy/) directory.

#### Hardware Setup
- **Controller:** TI LAUNCHXL-F28379D  
- **Driver:** TI BOOSTXL-DRV8305  
- **Motor:** Teknic M-2310P  




All tests were conducted using **MATLAB 2024b**.