% Model         :   PMSM Field Oriented Control
% Description   :   Set Parameters for Motor, Inverter and Controllers
%               :   for simulating the FOC control algorithm for PMSM
% File name     :   mcb_pmsm_foc_sim_data.m

% Copyright 2020-2021 The MathWorks, Inc.

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

%% Target & Inverter Parameters

target = mcb_SetProcessorDetails('F28379D',PWM_frequency);
inverter = mcb_SetInverterParameters('BoostXL-DRV8305');

% Update ISenseMax that is measurable by target ADC
inverter.ISenseMax = inverter.ISenseMax * target.ADC_Vref / inverter.ISenseVref;

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
disp(pmsm);
disp(inverter);
disp(target);
disp(PU_System);

