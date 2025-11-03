function mpcobj = mcb_getMPCObject(pmsm,PU_System,Ts_mpc,T_pwm,plotConstraints)


% mcb_getMPCObject Creates Model predictive controller object for PMSM FOC
% Current control
%
% mcb_getMPCObject reads PMSM motor parameters and Per unit system values as
% input
%
% mcb_getMPCObject computes the below
% a. The per-unit state space plant model from motor parameters and base
% values
% b. Generating and plotting the Voltage constraint (Circle approximation
% with 6 faces) and Current constraint (Half circle approximation with 4
% faces)
% Creates the MPC object with specified weights
%
% Ts_mpc: The sample rate of the MPC controller subsystem
% T_pwm: The sample rate at which the predictive model of the plant is
%        discretized
% mcb_getMPCObject(pmsm,PU_System,Ts_current,T_pwm,1) plots the Voltage
% and current constraints
% mcb_getMPCObject(pmsm,PU_System,Ts_current,T_pwm,0) does not plot 
% the constraints 
%
% The Non-linear circle current and voltage constraints used in FOC can be
% made to linear with the help of polytopic approximation in order to 
% reduce the complexity.
%
% Since the Id is always very close to zero in Constant Torque region, only
% half circle approximation has been taken as Current constraint
% to reduce the computation burden on online MPC problem
%
% The Circle constraint can be approximated in below ways
% a. 6 faces
% b. 8 faces
% c. half circle approximated with 4 faces


% Copyright 2021 The MathWorks, Inc.


% Per-unit state space predictive model of the PMSM 
N_base_omega = PU_System.N_base*2*pi/60*pmsm.p;
A = N_base_omega*[-pmsm.Rs/pmsm.Ld 0;0 -pmsm.Rs/pmsm.Lq];
B = N_base_omega*[1/pmsm.Ld 0; 0 1/pmsm.Lq];
C = [1 0 ;0 1];
D = 0;
plant = ss(A,B,C,D);
plantd = c2d(plant,T_pwm);

%% Voltage Constraints
angle = 15;

% Points on Coordinate axis that forms as basis of the polytop
p1 = [1 0];
p2 = [cos(deg2rad(90-angle)) sin(deg2rad(90-angle))];
p3 = [cos(deg2rad(90+angle)) sin(deg2rad(90+angle))];
p4 = [-1 0];
p5 = [cos(deg2rad(270-angle)) sin(deg2rad(270-angle))];
p6 = [cos(deg2rad(270+angle)) sin(deg2rad(270+angle))];

% Two point line equations for each face of the polytop
VolatgeConstraints.constr1 = polyfit([p1(1) p2(1)],[p1(2) p2(2)],1);
VolatgeConstraints.constr2 = polyfit([p2(1) p3(1)],[p2(2) p3(2)],1);
VolatgeConstraints.constr3 = polyfit([p3(1) p4(1)],[p3(2) p4(2)],1);
VolatgeConstraints.constr4 = polyfit([p4(1) p5(1)],[p4(2) p5(2)],1);
VolatgeConstraints.constr5 = polyfit([p5(1) p6(1)],[p5(2) p6(2)],1);
VolatgeConstraints.constr6 = polyfit([p6(1) p1(1)],[p6(2) p1(2)],1);

E_voltage = [-VolatgeConstraints.constr1(1) 1;
    -VolatgeConstraints.constr2(1) 1;
    -VolatgeConstraints.constr3(1) 1;
    VolatgeConstraints.constr4(1) -1;
    VolatgeConstraints.constr5(1) -1;
    VolatgeConstraints.constr6(1) -1;
    ];

F_voltage = zeros(6,2);

G_voltage = [VolatgeConstraints.constr1(2), VolatgeConstraints.constr2(2), VolatgeConstraints.constr3(2), -VolatgeConstraints.constr4(2), -VolatgeConstraints.constr5(2), -VolatgeConstraints.constr6(2)]';
V_voltage = [0.1 0.1 0.1 0.1 0.1 0.1]';

%% Current constraints

% Points on Coordinate axis that forms as basis of the polytop
p1 = [0 1];
p2 = [cos(deg2rad(135)) sin(deg2rad(135))];
p3 = [-1 0];
p4 = [cos(deg2rad(225)) sin(deg2rad(225))];
p5 = [0 -1];

% Two point line equations for each face of the polytop
CurrentConstraints.constr1 = polyfit([p1(1) p2(1)],[p1(2) p2(2)],1);
CurrentConstraints.constr2 = polyfit([p2(1) p3(1)],[p2(2) p3(2)],1);
CurrentConstraints.constr3 = polyfit([p3(1) p4(1)],[p3(2) p4(2)],1);
CurrentConstraints.constr4 = polyfit([p4(1) p5(1)],[p4(2) p5(2)],1);

E_current = zeros(4,2);

F_current = [-CurrentConstraints.constr1(1) 1;
    -CurrentConstraints.constr2(1) 1;
    CurrentConstraints.constr3(1) -1;
    CurrentConstraints.constr4(1) -1;
    ];

G_current = [CurrentConstraints.constr1(2), CurrentConstraints.constr2(2), -CurrentConstraints.constr3(2), -CurrentConstraints.constr4(2)]';
V_current = [1 1 1 1]';


E_complete = [E_voltage; E_current];
F_complete = [F_voltage; F_current];
G_complete = [G_voltage; G_current];
V_complete = [V_voltage; V_current];

%% Creating mpc object
mpcverbosity off;
mpcobj = mpc(plantd); % MPC object
% Specifying the horizons
mpcobj.PredictionHorizon =2;
mpcobj.ControlHorizon =1;
% Specifying the output disturbance rejection model
setoutdist(mpcobj,'Model', eye(2)*tf(0.05,[1 -1],'Ts',Ts_mpc) );  % default

% Specifying the sample time of the Model predictive controller
mpcobj.Ts = Ts_mpc;
% Setting the upper and lower limits for the MV and OV
mpcobj.ManipulatedVariables = struct('Max',{1,1},'Min',{-1, -1},'MinECR',[0 0],'MaxECR',[0 0]);  % default
% mpcobj.ManipulatedVariables = struct('Max',{Inf,Inf},'Min',{-Inf,-Inf},'MinECR',[0 0],'MaxECR',[0 0]);

mpcobj.OutputVariables = struct('Max',{0.1,1},'Min',{-0.1,-1},'MinECR',[1 1],'MaxECR',[1 1]);  % default
% mpcobj.OutputVariables = struct('Max',{Inf,Inf},'Min',{-Inf,-Inf},'MinECR',[0 0],'MaxECR',[0 0]);

% Setting the Weights of the optimization problem used in MPC
mpcobj.Weights.OutputVariables = [1 1];
mpcobj.Weights.ManipulatedVariablesRate = [0.01 0.01];
setconstraint(mpcobj,E_complete,F_complete,G_complete,V_complete);
% Plotting the constraints based on plotConstraints
if plotConstraints==1
    mcb_visualizeMpcConstraints(VolatgeConstraints,CurrentConstraints,F_current,E_voltage,G_current,G_voltage);
end
end

%% Function to plot the Voltage and current constraints

function  mcb_visualizeMpcConstraints(VolatgeConstraints,CurrentConstraints,F_current,E_voltage,G_current,G_voltage)
ud = -1:0.05:1;
uq = -1:0.1:1;

%% Plot Voltage constraints
figure('Name','MPC Constraints')
subplot(1,2,1)
plot(ud, VolatgeConstraints.constr1(1)*ud + VolatgeConstraints.constr1(2),'b')
title('Voltage Constraints -Circle Approximation with 6 faces')
xlabel('Vd');
ylabel('Vq');
hold on
plot(ud, VolatgeConstraints.constr2(1)*ud + VolatgeConstraints.constr2(2),'b')
plot(ud, VolatgeConstraints.constr3(1)*ud + VolatgeConstraints.constr3(2),'b')
plot(ud, VolatgeConstraints.constr4(1)*ud + VolatgeConstraints.constr4(2),'b')
plot(ud, VolatgeConstraints.constr5(1)*ud + VolatgeConstraints.constr5(2),'b')
plot(ud, VolatgeConstraints.constr6(1)*ud + VolatgeConstraints.constr6(2),'b')

circle2(0,0,1);
xlim([-1.5 1.5])
ylim([-1.5 1.5])
subplot(1,2,1)

for ii=1:length(ud)
    for jj=1:length(uq)
        b = E_voltage*[ud(ii),uq(jj)]' <= G_voltage;
        if all(b)
            plot(ud(ii),uq(jj),'.b')
        else
            plot(ud(ii),uq(jj),'.r')
        end
    end
end

hold off

%% Plot Current constraints
subplot(1,2,2)
plot(ud, CurrentConstraints.constr1(1)*ud + CurrentConstraints.constr1(2),'b')
title('Current Constraints -Half circle approximation with 4 faces')
xlabel('Id');
ylabel('Iq');
hold on
plot(ud, CurrentConstraints.constr2(1)*ud + CurrentConstraints.constr2(2),'b')
plot(ud, CurrentConstraints.constr3(1)*ud + CurrentConstraints.constr3(2),'b')
plot(ud, CurrentConstraints.constr4(1)*ud + CurrentConstraints.constr4(2),'b')

circle2(0,0,1);
xlim([-1.5 1.5])
ylim([-1.5 1.5])

for ii=1:length(ud)
    for jj=1:length(uq)
        b = F_current*[ud(ii),uq(jj)]' <= G_current;
        if all(b)
            plot(ud(ii),uq(jj),'.b')
        else
            plot(ud(ii),uq(jj),'.r')
        end
    end
end
hold off

end
%% Plotting the circle in the background
function h = circle2(x,y,r)
    d = r*2;
    px = x-r;
    py = y-r;
    h = rectangle('Position',[px py d d],'Curvature',[1,1],'EdgeColor', 'r');    
end