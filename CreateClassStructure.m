function  [ExpInfo, dstruct, dotInfo, audInfo]= CreateClassStructure(data, monWidth, viewDist, xCenter, yCenter) %Puts all data input into structure for neatness
%% Jack Mayfield 4/22/22

%% GUI Input Parameters 

ExpInfo.t_angle = data(1,1); % Fixation Dot and Target Dots Visual Angle in Degrees
ExpInfo.rew_angle = data(2,1);% Reward Window Visual Angle in Degrees
ExpInfo.num_trials = data(3,1); % Number of Trials for 1 block
ExpInfo.stim_time = data(4,1); %Time of stimulus(RDK) presentaiton (ms)
ExpInfo.iti = data(5,1);%Intertrial Interval (ms)
ExpInfo.fixation_time = data(6,1);% Time to fixate on fixation point before RDK Starts presenting == time of presenting fixation point 
ExpInfo.positions = data(7:15,:); % Binary List of ON(1)/OFF(0) for position 1-9
ExpInfo.possible_pos = find(ExpInfo.positions == 1); %Corresponding Number Position available for use
ExpInfo.fail_timeout = data(16,1); %Failure of trial timeout in (ms)
ExpInfo.rdk_angle = data(17,1); %RDK stimulus visual angle
ExpInfo.target_fixation_time = data(18,1);% Time to fixate inside the target point window in order to get Reward

%% This is the random position number generator

%It takes all possible positions given above and produces a list with the
%length of num_trials for use in the .rcx circuit
ExpInfo.random_list = zeros(1,ExpInfo.num_trials);
    for i = 1:ExpInfo.num_trials
      r_index = randi(length(ExpInfo.possible_pos));
      ExpInfo.random_list(i) = ExpInfo.possible_pos(r_index);
    end
    
%% Display Settings 

dstruct.res = [1280 1024];    % screen resolution x y
dstruct.siz = [40 30];        % screen size in cm W,H 
dstruct.dis = 55;             % viewing distance in cm

%% Other Parameters
ExpInfo.time_wait = [0.7, 1]; % Default waiting times (seconds) for each frame [fixation, targets] 042522-AS: changed from 4 vals to 2 bc dont have cue and delay time

%ExpInfo.time_wait = [0.7, 3]; % Default waiting times (seconds) for each frame [fixation, targets] 042522-AS: changed from 4 vals to 2 bc dont have cue and delay time
ExpInfo.fixpoint_size_pix = angle2pixels(ExpInfo.t_angle); %Fixation Dot Stimulus Size pixels 
ExpInfo.targpoint_size_pix = ExpInfo.fixpoint_size_pix; %Target Dot Size, same as fixation point for now 
ExpInfo.rew_radius_volts = angle2volts(ExpInfo.rew_angle); %Reward window radius value in volts 
ExpInfo.target_rew_radius_volts = angle2volts(10.5);
ExpInfo.ppd = 30;%pi * xCenter / atan(monWidth/viewDist/2) / 360;

%% RDK Parameters
dotInfo.rdk_size_pix = angle2pixels(ExpInfo.rdk_angle); %RDK window size in pixels
dotInfo.cohSet = [data(19,1)]; % Coherence % Value 0.0-1.0, Right now only 1 coherence in the set
dotInfo.apXYD = [0 90 (ExpInfo.rdk_angle*10)]; % Location x,y pixels (0,0 is center of screen) and diameter of the aperature, currently in visual degrees - MULTPLIED by 10 because of Shadlen dots code, needed to be an integer
dotInfo.speed = data(20,1); %Degrees per second?
%dotInfo.dotSize = 4; %RDK Field Dots
dotInfo.dotSize = 9; %RDK Field Dots
%dotInfo.dotSize = 8; %RDK Field Dots
dotInfo.numDotField = 1; %Do not change 
dotInfo.dotColor = [255 255 255]; %Dot field Color
dotInfo.maxDotTime = ExpInfo.stim_time/1000; %Puts this in seconds from ms 
dotInfo.Incorrect_Opacity = data(25,1); %OPacity for the incorrect target, this for training purposes - eventually will be the same opacity as correct 
dotInfo.maxDotsPerFrame = 400; %Maximum number of dots per frame of the RDK aperture drawing, DO NOT CHANGE - Graphics Card Specific
%dotInfo.maxDotsPerFrame = 200; %Maximum number of dots per frame of the RDK aperture drawing, DO NOT CHANGE - Graphics Card Specific

%% Auditory Parameters 
audInfo.coherence = data(26,1); 
audInfo.dirSet = data(30:33,1)'; % 0 -- means CAM1 to CAM2 , 1 -- CAM2 to CAM1
audInfo.dur = data(27,1); % In seconds
audInfo.silence = data(28,1); %Preceding silence period in seconds
audInfo.dB = data(29,1); %Max dB value
audInfo.muxSet = [0]; %Set to zero for now which only includes LR and RL directions
audInfo.random_mux_list = zeros(1,(ExpInfo.num_trials)); %Set to zeros for now which only includes LR and RL directions
audInfo.Incorrect_Opacity = 0.5;    

% This explains the inputs for each direction of auditory motion
% dir | mux
% 1       0  = L to R 
% 0       1  = D to U
% 1       1  = U to D
% 0       0  = R to L 

    %Make a list of random directions with and equal amount of each
    %direction from audInfo.dirSet, Currently only works for LR and RL
    %directions, need to adapt for UD and DU directions 
    audInfo.random_dir_list = zeros(1,ExpInfo.num_trials);
    
    if length(audInfo.dirSet) > 1 
        numberOfElements = ExpInfo.num_trials; 
        per_R = 50; % the percentage of LR Directions, 50% will make an even number of LR and RL trials
        numberOfOnes = round(numberOfElements * per_R / 100); 
        % Make initial signal with proper number of 0's and 1's.
        signal = [ones(1, numberOfOnes), zeros(1, numberOfElements - numberOfOnes)];
        % Scramble them up with randperm
        signal = signal(randperm(length(signal)));

        for i = 1:ExpInfo.num_trials
          r_index = signal(i);
          if signal(i) == 0
              audInfo.random_dir_list(i) = audInfo.dirSet(r_index+1);
          elseif signal(i) == 1
              audInfo.random_dir_list(i) = audInfo.dirSet(r_index+2);
          end
        end
    else
        audInfo.random_dir_list(:) = dotInfo.dirSet; 
    end
%%
dir_bin = data(21:24,1)'; %U L D R 
    if dir_bin == [1 1 1 1]% For the GUI State buttons corresponding to direction of RDK Motion
        dotInfo.dirSet = [90 180 270 0];
    elseif dir_bin == [1 1 1 0]
        dotInfo.dirSet = [90 180 270];
    elseif dir_bin == [1 1 0 1]
        dotInfo.dirSet = [90 180 0];
    elseif dir_bin == [1 1 0 0]
        dotInfo.dirSet = [90 180];
    elseif dir_bin == [1 0 1 1]
        dotInfo.dirSet = [90 270 0];
    elseif dir_bin == [1 0 1 0]
        dotInfo.dirSet = [90 270];
    elseif dir_bin == [1 0 0 1]
        dotInfo.dirSet = [90 0];
    elseif dir_bin == [1 0 0 0]
        dotInfo.dirSet = [90];
    elseif dir_bin == [0 1 1 1]
        dotInfo.dirSet = [180 270 0];
    elseif dir_bin == [0 1 1 0]
        dotInfo.dirSet = [180 270];
    elseif dir_bin == [0 1 0 1]
        dotInfo.dirSet = [180 0];
    elseif dir_bin == [0 1 0 0]
        dotInfo.dirSet = [180];
    elseif dir_bin == [0 0 1 1]
        dotInfo.dirSet = [270 0];
    elseif dir_bin == [0 0 1 0]
        dotInfo.dirSet = [270];
    elseif dir_bin == [0 0 0 1]
        dotInfo.dirSet = [0];
    elseif dir_bin == [0 0 0 0]
        dotInfo.dirSet = [];
    end

    %Make a list of random directions with and equal amount of each
    %direction from dotInfo.dir_set, Currently only works for L and R
    %directions, need to adapt for U and D directions 
    dotInfo.random_dir_list = zeros(1,ExpInfo.num_trials);
    
    if length(dotInfo.dirSet) > 1 
        numberOfElements = ExpInfo.num_trials; 
        per_R = 50; % the percentage of Right Targets, 50% will make an even number of L and R trials
        numberOfOnes = round(numberOfElements * per_R / 100); 
        % Make initial signal with proper number of 0's and 1's.
        signal = [ones(1, numberOfOnes), zeros(1, numberOfElements - numberOfOnes)];
        % Scramble them up with randperm
        signal = signal(randperm(length(signal)));

        for i = 1:ExpInfo.num_trials
          r_index = signal(i);
          if signal(i) == 0
              dotInfo.random_dir_list(i) = dotInfo.dirSet(r_index+1);
          elseif signal(i) == 1
              dotInfo.random_dir_list(i) = dotInfo.dirSet(r_index+1);
          end
        end
    else
        dotInfo.random_dir_list(:) = dotInfo.dirSet; 
    end
    
    %% Make sure that the opposing directions of aud and visual only occur a certain percentage of trials 
    wanted_per_congruent = 0.9; % Wanted percentage of congruent Trials
    current_per_congruent = 0; 
    
    while current_per_congruent <= wanted_per_congruent  %Change the aud directions until the percentage of congruent trials has met the requirement
    
    good = zeros(1,ExpInfo.num_trials); 
    bad = zeros(1,ExpInfo.num_trials);  
    congruent = 0; 
    opposing = 0; 
    finder = 1; 
%     
%     current_per_congruent = congruent/ExpInfo.num_trials;
%     if current_per_congruent  >= wanted_per_congruent
%         break
%     end
    
    aud_LtoR = audInfo.random_dir_list == 1;%Binary of where aud == L to R 
    aud_RtoL = audInfo.random_dir_list == 0; 
    rdk_LtoR = dotInfo.random_dir_list == 0; %binary of visual == L to R
    rdk_RtoL = dotInfo.random_dir_list == 180; 
        
        for f = 1:ExpInfo.num_trials
            
            if (aud_LtoR(f) == 1 && rdk_LtoR(f) == 1) || (aud_RtoL(f) == 1 && rdk_RtoL(f) == 1)%Congruent Trials
                congruent = congruent + 1;
                good(finder) = 1;
                 
                
            elseif (aud_LtoR(f) == 1 && rdk_LtoR(f) == 0) || (aud_RtoL(f) == 0 && rdk_RtoL(f) == 1)%Opposing Trials
                opposing = opposing + 1;
                bad(finder) = 1; 
                
            end
            
            finder = finder+1;
        end
        
        rand_index = randi([1 ExpInfo.num_trials]);
        rand_index2 = randi([1 ExpInfo.num_trials]);
        
        if (good(rand_index) == 0)
            audInfo.random_dir_list(rand_index) = 1;
            dotInfo.random_dir_list(rand_index) = 0; 
        elseif (good(rand_index2) == 0)
            audInfo.random_dir_list(rand_index) = 0;
            dotInfo.random_dir_list(rand_index) = 180; 
        end
        current_per_congruent = congruent/ExpInfo.num_trials;
        
    end
audInfo.congruentList = good; 
end
