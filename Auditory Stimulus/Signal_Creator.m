function [adjustment_factor, CAM_1, CAM_2] = Signal_Creator(CAM,dB_value)
    %SIGNAL_CREATOR Summary of this function goes here
    
    %Inputs:
    % CAM       -- the input signal from makeCAM function
    % db_value	-- the expected dB maximum for the signal to ramp from/to
    
    %Output:
    % adjustment_factor -- adjustment factor for the base signal, in order
    %                      to adjust dB level of the stimulus 
    
    %% Need to resample because the RX8 has a higher sample rate
    FS_old = 44100; %old FS
    FS_new = 24414*2; %sampling rate of RZ processor
    
    [p, q] = rat(FS_new/FS_old);
    
    arr1 = resample(CAM(:,1), p, q);
    arr2 = resample(CAM(:,2), p, q);
    CAM_1 = arr1; 
    CAM_2 = arr2; 
    
    %%  This is for the signal adjustment factor, based on dB values from the
    % speaker calibration test. Excel file with equations is found in C:\Jackson\Adriana Stuff\Speaker Calibration Room 027.xlsx
    
    %voltage = exp((dB_value-83.615)./(8.0053)); %Based on average logrithimic trendline fit equation
 
    voltage = ((1000.*dB_value)-61879)./(42954);
    %Given the required max voltage we can calculate the adjustment factor to send to the .rcx circuit,
    %because the non adjusted max value = +-3 V (1.0 adjustment factor)
    
    adjustment_factor = voltage./3; 
    
%     %% Writes the CAM signals into f32 file for reading on the RX8
%     
%     
%     filename = 'C:\Jackson\Adriana Stuff\Auditory_Experiment_Jack_060722\Auditory Stimulus\CAM_1.f32';
%     filename2 = 'C:\Jackson\Adriana Stuff\Auditory_Experiment_Jack_060722\Auditory Stimulus\CAM_2.f32';
%     
%     fid = fopen(filename, 'wb');
%     fid2 = fopen(filename2, 'wb');
%     fwrite(fid, arr1, 'float32');
%     fwrite(fid2, arr2, 'float32');
%     fclose(fid);
%     fclose(fid2);
%     
%     %PLOT
%     fid = fopen(filename, 'r');
%     yy = fread(fid, inf, '*float32');
%     fclose(fid);
%     figure; plot(yy);
%     
%     fid = fopen(filename2, 'r');
%     yy2 = fread(fid, inf, '*float32');
%     fclose(fid);
%     figure(2); plot(yy2);

end

