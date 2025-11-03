% Model         :   Reinforcement learning example for PMSM
% Description   :   Set Parameters for Motor, Inverter and Controllers
%               :   for demonstrating the reinforcement learning for PMSM
%               :   and compare the results with PI controller
% File name     :   mcb_pmsm_foc_sim_RL_data.m

% Copyright 2021 The MathWorks, Inc.

%% Set PWM Switching frequency
PWM_frequency 	= 5e3;              %Hz // converter s/w freq  5e3
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // simulation time step for controller
Ts_simulink     = T_pwm/2;      %sec        // simulation time step for model simulation
Ts_motor        = T_pwm/2;      %sec        // Simulation sample time
Ts_inverter     = T_pwm/2;      %sec        // simulation time step for average value inverter
Ts_speed        = 10*Ts;        %Sec        // Sample time for speed controller

%% Set data type for controller & code-gen
dataType = 'single';            % Floating point code-generation

%% System Parameters // Hardware parameters 

% pmsm = mcb_SetPMSMMotorParameters('Maxon_EC_Speedgoat');
% pmsm.PositionOffset = 0.165;
pmsm = mcb_SetPMSMMotorParameters('Teknic2310P');
pmsm.PositionOffset = 0.0755;

target = mcb_SetProcessorDetails('F28379D',PWM_frequency);

%% Target & Inverter Parameters

inverter = mcb_SetInverterParameters('BoostXL-DRV8305');

% Update inverter.ISenseMax based for the chosen motor and target
inverter = mcb_updateInverterParameters(pmsm,inverter,target);

%% Derive Characteristics

pmsm.N_base = mcb_getBaseSpeed(pmsm,inverter); %rpm // Base speed of motor at given Vdc

%% PU System details // Set base values for pu conversion

PU_System = mcb_SetPUSystem(pmsm,inverter);

%% Controller design // Get ballpark values!

PI_params = mcb.internal.SetControllerParameters(pmsm,inverter,PU_System,T_pwm,Ts,Ts_speed);

%Updating delays for simulation
PI_params.delay_Currents    = 1;
PI_params.delay_Position    = 1;

%% Displaying model variables
% disp(pmsm);
% disp(inverter);
% disp(target);
% disp(PU_System);

%%
rng('shuffle'); % 현재 시간 기반으로 Seed 설정
randVal = rand(); % 랜덤 값 생성
gain = 0.0001;
assignin('base', 'rand_val', gain*randVal); % Simulink에서 사용할 수 있도록 워크스페이스에 저장
