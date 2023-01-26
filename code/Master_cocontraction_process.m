%% MASTER CODE FOR HEALTHY/CP CO-CONTRACTION GAIT STUDY

% Processing pipeline script for the analysis of muscle contraction in children
% with cerebral palsy (CP) and typically developping (TD) controls 

% Datasets : 
% - Oxford CP + TD dataset: 'raw files (05.01.15)' from Phil Dixon DPhil research
% - NJIT CP dataset: 'NJIT raw' From Saikat Pal's lab at NJIT with names modified 
%   for compatibilty with the Oxford dataset
%
% NOTES:
% - Requires biomechZoo repo (tested using v 1.9.7): https://github.com/PhilD001/biomechZoo
% - This repo is stored at https://github.com/PhilD001/cp_muscle_cocontraction
% - Path : Need to add biomechZoo and cp_muscle_cocontraction folders to path
%  (biomechZoo in bottom of path) before running
% 

%% PART 1: Clean and prep Oxford dataset
% Involves Steps 1.1 - 1.6 

%% Step 1.1: Get data and set up
% Copies raw c3d files of Oxford dataset to new processed_ox folder
% When prompted, select the Raw Oxford folder

% Select path to raw c3d data folder (Raw Oxford) 
fld_raw = uigetfolder;

% Create folder for processed data
indx = strfind(fld_raw, filesep);
fld_root = fld_raw(1:indx(end));
fld = [fld_root, 'processed'];
if exist(fld, 'dir')
   disp('function previously run...overwritting previous run')
   rmdir(fld, 's')
end

% Copy raw data to processed folder
mkdir(fld);
copyfile(fld_raw,fld)

% Create folder for statistics (eventval sheet)
fld_stats = [fld_root, 'Statistics'];
if exist(fld_stats, 'dir')
    disp('removing old processed data folder...')
    rmdir(fld_stats, 's')
end

% Create empty folder for statistics 
mkdir(fld_stats);

%% Step 1.2: Convert to the Zoo format
% Converts raw c3d files to .zoo files

del='yes';
c3d2zoo(fld,del);

%% Step 1.3: Extract anthro information from csv files
 
turninggait_sub_char(fld,'CP_trials'); 
turninggait_sub_char(fld,'TD_trials');  

%% Step 1.4: Check for empty folders

[~,subjects] = extract_filestruct(fld);
for i = 1:length(subjects)
    fl = engine('fld',fld, 'search path', subjects{i}, 'extension','zoo'); 
    if isempty(fl)                                                         
    bmech_removefolder(fld,subjects{i});
    disp(['removing subject ', subjects{i},' because there are no files'])
    end
end

%% Step 1.5: Organize subjects
% Removes data and conditions were are not interested in

bmech_remove_by_anthro(fld,'Age',5,'<=');     % remove children younger than 5 years
bmech_remove_by_anthro(fld,'EMG_L',0,'=');    % remove all files with EMG_L missing
bmech_removebydescription(fld, 'static');     % remove static trials 
bmech_removebydescription(fld, 'Left');       % remove left turn trials
bmech_removebydescription(fld, 'Right');      % remove right turn trials

%% PART 2: Clean and prep NJIT dataset
% Involves Steps 2.1 - 2.6

%% Step 2.1: Get data and set up
% Copies raw c3d files to new processed_nj folder
% When prompted, select the Raw NJIT folder

% Select path to raw c3d data folder (Raw NJIT)
fld_raw = uigetfolder;

% Create folder for processed data
indx = strfind(fld_raw, filesep);
fld_root = fld_raw(1:indx(end));
fld_nj = [fld_root, 'processed_nj'];
if exist(fld_nj, 'dir')
   disp('function previously run...overwritting previous run')
   rmdir(fld_nj, 's')
end

% Copy raw data to processed folder
mkdir(fld_nj);
copyfile(fld_raw,fld_nj)

%% Step 2.2: Convert to the Zoo format
% Converts raw c3d files to .zoo files

del='yes';
c3d2zoo(fld_nj,del);

%% Step 2.3: Rename channels 
% Rename NJIT channels to align with corresponding muscle and Oxford
% dataset nomenclature

ch_old = {'Sensor_1IM_EMG1', 'Sensor_4IM_EMG4', 'Sensor_5IM_EMG5', 'Sensor_7IM_EMG7',...
    'Sensor_9IM_EMG9','Sensor_12IM_EMG12', 'Sensor_13IM_EMG13', 'Sensor_15IM_EMG15'};

ch_new = {'R_Rect','R_Tib_Ant','R_Hams','R_Gast','L_Rect','L_Tib_Ant','L_Hams','L_Gast'};

bmech_renamechannel(fld_nj, ch_old, ch_new)

%% Step 2.4: Add SACR variable
% NJIT dataset was missing SACR variable, this step adds it as a channel 

cocontraction_add_sacr(fld_nj)

%% Step 2.5: Combine NJIT and Oxford datasets into one folder
cd(fld)
copyfile(fld_nj, [fld, filesep, 'CP'])
rmdir(fld_nj); % removes the processed_nj folder
%% PART 3: Perform processing and analyses on full dataset
% This involves steps 3.1 to 3.x

%% Step 3.1: Clean up
% Remove channels that are not important for this project

ch_kp = {'L_Rect','R_Rect','L_Hams','R_Hams','L_Gast','R_Gast','L_Tib_Ant','R_Tib_Ant',...
        'LTOE', 'LHEE', 'RTOE', 'RHEE', 'LPSI', 'RPSI', 'SACR',...
        'RHipAngles', 'RKneeAngles', 'RAnkleAngles', ...
        'LHipAngles', 'LKneeAngles', 'LAnkleAngles'};

bmech_removechannel(fld, ch_kp, 'keep');

%% Step 3.2 Remove files with missing channels
% Required muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior

chns = {'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};
bmech_remove_files_missing_channels(fld, chns);

%% Step 3.3: Process EMG signal
%  1- High pass filter @ 20Hz
%  2- Low-pass filter  @ 450 Hz
%  3- Rectify signal
%  4- Root mean square (50 frames)
%  Uses a 4th order filter

ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
lp_cut = 450;
hp_cut = 20;
bmech_emgprocess(fld, ch, lp_cut, hp_cut);

%% Step 3.4 Dynamic Normalization
% Run function for dynamic normalization

ch={'L_Rect_filthigh_filtlow_rect_RMS','L_Hams_filthigh_filtlow_rect_RMS',...
    'L_Gast_filthigh_filtlow_rect_RMS','L_Tib_Ant_filthigh_filtlow_rect_RMS'};
before_str= '';
after_str={'A'};

bmech_emg_dynamic_normalization(fld,ch,before_str,after_str); 

%% Step 3.5: Explode data
% Required for addevent (step 3.6)

bmech_explode(fld);

%% Step 3.5: Add kinematic gait event
% Add LFS event

bmech_addevent(fld, 'SACR_x','LFS', 'LFS'); 

%% Step 3.6: Resample Video channels 
% - upsamples video to analog frequency to make sure the partition aligns

bmech_resample(fld,'Video')

%% Step 3.7: Partition to a single gait cycle

evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step 3.8: Add LFO event

bmech_addevent(fld, 'SACR_x','LFO','LFO'); 

%% Step 3.9: Delete outliers 

% manually identified outliers
files = {'C1313A08.zoo','C1314A06.zoo','C1424A31.zoo','C1495A06.zoo',...
'C1495A09.zoo','C1495A11.zoo','C1499A14.zoo','C1500A11.zoo','CP031A01.zoo',...
'CP031A03.zoo','CP046A18.zoo','HC020A05.zoo','HC026A10.zoo','HC026A07.zoo',...
'HC028A09.zoo','HC030A04.zoo','HC032A02.zoo','HC032A05.zoo','HC039A16.zoo',...
'HC055A15.zoo','HC059A19.zoo'};

% Delete outlier trials
bmech_removefile(fld,files);

% Remove empty folders
[~,subjects] = extract_filestruct(fld);
for i = 1:length(subjects)
    fl = engine('fld',fld, 'search path', subjects{i}, 'extension','zoo'); 
    if isempty(fl)                                                         
    bmech_removefolder(fld,subjects{i});
    disp(['removing subject ', subjects{i},' because he has no files'])
    end
end

%% Step 3.10: Re-run Dynamic Normalization 
% This step needs to be repeated following removal of outliers

ch={'L_Rect_filthigh_filtlow_rect_RMS','L_Hams_filthigh_filtlow_rect_RMS',...
    'L_Gast_filthigh_filtlow_rect_RMS','L_Tib_Ant_filthigh_filtlow_rect_RMS'};

before_str= '';
after_str={'A'};

bmech_emg_dynamic_normalization(fld,ch,before_str,after_str);

%% Step 3.11: Rename channels

ch_old = {'L_Rect_filthigh_filtlow_rect_RMS_normalized', 'L_Hams_filthigh_filtlow_rect_RMS_normalized',...
    'L_Tib_Ant_filthigh_filtlow_rect_RMS_normalized', 'L_Gast_filthigh_filtlow_rect_RMS_normalized'...
    'L_Rect_filthigh_filtlow_rect_RMS','L_Hams_filthigh_filtlow_rect_RMS',...
    'L_Gast_filthigh_filtlow_rect_RMS','L_Tib_Ant_filthigh_filtlow_rect_RMS'};

ch_new = {'L_Rect_normalized', 'L_Hams_normalized','L_Tib_Ant_normalized', 'L_Gast_normalized'...
    'L_Rect_Notnormalized', 'L_Hams_Notnormalized','L_Tib_Ant_Notnormalized', 'L_Gast_Notnormalized'};
      
bmech_renamechannel(fld, ch_old, ch_new)

%% Step 3.12: Calculate muscle co-contraction
% Calculates co-contraction based on Lo et al. (2017) approach
% function for muscle co-contraction using both dynamically normalized and
% non-nomralized EMG data.

pairs={'L_Rect_normalized-L_Hams_normalized',...
       'L_Tib_Ant_normalized-L_Gast_normalized'...
       'L_Rect_Notnormalized-L_Hams_Notnormalized',...
       'L_Tib_Ant_Notnormalized-L_Gast_Notnormalized'};

% Stance
bmech_cocontraction(fld,pairs,'method','Lo2017','events',{'LFS1','LFO1'});

% Swing
bmech_cocontraction(fld,pairs,'method','Lo2017','events',{'LFO1','LFS2'});
 
%% Step 3.13: Rename channels

ch_old = {'L_Tib_Ant_normalized_L_Gast_normalized_Lo2017','L_Rect_normalized_L_Hams_normalized_Lo2017',...
'L_Tib_Ant_Notnormalized_L_Gast_Notnormalized_Lo2017','L_Rect_Notnormalized_L_Hams_Notnormalized_Lo2017'};

ch_new = {'L_TA_G_cc_Norm', 'L_RF_HS_cc_Norm', 'L_TA_G_cc_NotNorm', 'L_RF_HS_cc_NotNorm'};...
  
bmech_renamechannel(fld, ch_old, ch_new)

%% Step 3.14: Determine represetative trial
% Determines representative trial for each participant 

ch = {'L_TA_G_cc_Norm', 'L_RF_HS_cc_Norm', 'L_TA_G_cc_NotNorm', 'L_RF_HS_cc_NotNorm'};
method = 'RMSE';
bmech_reptrial(fld,ch,method);

%% Step 3.15: Output datasheet for stats


[cons,subjects] = extract_filestruct(fld);
chns = {'L_TA_G_cc_Norm', 'L_RF_HS_cc_Norm', 'L_TA_G_cc_NotNorm', 'L_RF_HS_cc_NotNorm'};
lcl_evts = {'co_contraction_value_from_LFS1_to_LFO1'...
            'co_contraction_value_from_LFO1_to_LFS2'}; 

eventval('fld', fld, 'dim1', cons, 'dim2', subjects, 'ch', chns, ...
         'localevents', lcl_evts, 'globalevents', 'none');
     
% End