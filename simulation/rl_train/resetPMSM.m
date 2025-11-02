function in = resetPMSM(in)
% Reset function for PMSM control using RL example

% Copyright 2020-2021 The MathWorks, Inc.

    % randomize reference signal
    blk = 'mcb_pmsm_foc_sim_RL/SpeedRef';
    refSpeedValues = [-0.2,-0.4,-0.6,-0.8,0.2,0.4,0.6,0.8];
    idx = randperm(length(refSpeedValues),1);
    refspeed = refSpeedValues(idx);
    in = setBlockParameter(in,blk,'Time','0');
    in = setBlockParameter(in,blk,'Before','0');
    in = setBlockParameter(in,blk,'After',num2str(refspeed));

    % added block for random inertia
    rng('shuffle'); 
    rand_val = rand()*0.0001;
    assignin('base', 'disturbance', rand_val);
    
    % set train flag for is done signal
    in = setBlockParameter(in,'mcb_pmsm_foc_sim_RL/Current Control/Control_System/Closed Loop Control/Reinforcement Learning/IsDone/TrainFlag','Value','1');
end