% Model         :   PMSM Field Oriented Control using MPC 
% Description   :   Set Parameters for PMSM Field Oriented Control using MPC
% File name     :   mcb_pmsm_foc_mpc_qep_f28379d_data.m

% Copyright 2021-2022 The MathWorks, Inc.

%% Set PWM Switching frequency
PWM_frequency 	= 20e3;             %Hz     // converter s/w freq
T_pwm           = 1/PWM_frequency;  %s      // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;            %sec    // Sample time for control system
Ts_simulink     = T_pwm/2;          %sec    // Simulation time step for model simulation
Ts_motor        = T_pwm/2;          %Sec    // Simulation time step for pmsm
Ts_inverter     = T_pwm/2;          %sec    // Simulation time step for inverter

% Speed controller uses PID controller
% Choose 'MPC' for Model predictive control and 'PID' for PID controller
% for current controller
currentcontrollervar = 'MPC'; %PID
switch currentcontrollervar
    case 'MPC'
        Ts_current          = 4*Ts;             %Sec    // Sample time for the Current Controller
        Ts_speed            = 5*Ts_current;     %Sec    // Sample time for speed controller
    case 'PID'
        Ts_current 			= Ts;
        Ts_speed            = 10*Ts;            %Sec    // Sample time for speed controller
end

%% Set data type for controller & code-gen
dataType = 'single';                % Floating point code-generation

%% System Parameters 
% Motor parameters
% pmsm = mcb_SetPMSMMotorParameters('Teknic2310P');
% pmsm.PositionOffset = 0.17;         % Per-Unit position offset

pmsm = mcb_SetPMSMMotorParameters('Teknic2310P');
pmsm.PositionOffset = 0.0755;

%% Target & Inverter Parameters
target = mcb_SetProcessorDetails('F28379D',PWM_frequency);
% target.comport = 'COM3';       % Uncomment and update the appropriate serial port
target.comport = 'COM5';
inverter = mcb_SetInverterParameters('BoostXL-DRV8305');

% Enable automatic calibration of ADC offset for current measurement
inverter.ADCOffsetCalibEnable = 1;  % Enable: 1, Disable:0 

% If automatic ADC offset calibration is disabled, uncomment and update the 
% offset values below manually
% inverter.CtSensAOffset = 2295;      % ADC Offset for phase current A 
% inverter.CtSensBOffset = 2286;      % ADC Offset for phase current B

% Update inverter.ISenseMax based for the chosen motor and target
inverter = mcb_updateInverterParameters(pmsm,inverter,target);

% Max and min ADC counts for current sense offsets
% inverter.CtSensOffsetMax = 2500;    % Maximum permitted ADC counts for current sense offset
% inverter.CtSensOffsetMin = 1500;    % Minimum permitted ADC counts for current sense offset

%% Derive Characteristics
pmsm.N_base = mcb_getBaseSpeed(pmsm,inverter); %rpm // Base speed of motor at given Vdc

% mcb_getCharacteristics(pmsm,inverter);

%% PU System details // Set base values for pu conversion

PU_System = mcb_SetPUSystem(pmsm,inverter);

%% Controller design // Get ballpark values!

PI_params = mcb_SetControllerParameters(pmsm,inverter,PU_System,T_pwm,Ts,Ts_speed);

%Updating delays for simulation
% PI_params.delay_Currents    = int32(Ts/Ts_simulink);
% PI_params.delay_Position    = int32(Ts/Ts_simulink);
% PI_params.delay_Speed       = int32(Ts_speed/Ts_simulink);
% PI_params.delay_Speed1      = (PI_params.delay_IIR + 0.5*Ts)/Ts_speed;
PI_params.delay_Currents    = 1;
PI_params.delay_Position    = 1;

% mcb_getControlAnalysis(pmsm,inverter,PU_System,PI_params,Ts,Ts_speed); 
%% Displaying model variables
disp(pmsm);
disp(inverter);
disp(target);
disp(PU_System);

%% Create MPC object and visualize constraints
% Use mcb_getMPCObject(pmsm,PU_System,Ts_current,T_pwm,1) to plot
% constraints
mpcobj = mcb_getMPCObject(pmsm,PU_System,Ts_current,T_pwm,0);
