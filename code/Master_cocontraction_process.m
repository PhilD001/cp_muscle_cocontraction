%% MASTER CODE FOR HEALTHY/CP CO-CONTRACTION GAIT STUDY

% Processing pipeline example script for the manuscript: " MUSCLE COACTIVATION 
% DURING GAIT IN CHILDREN WITH AND WITHOUT CEREBRAL PALSY" 
% (under review May 2nd 2023)

% Dataset : As we are unable to share the patient dataset associated with the 
% paper, here we demonstrate the code with a subset of control data 
% (typically developping children) included in this repository
% -
% NOTES:
% - Requires biomechZoo repo (tested using v 1.9.8): https://github.com/PhilD001/biomechZoo
% - This repo is stored at https://github.com/PhilD001/cp_muscle_cocontraction
% - Path : Need to add biomechZoo and cp_muscle_cocontraction folders to path
%  (biomechZoo in bottom of path) before running
% 

%% PART 1: Clean and prep dataset

%% Step 1.1: Get data and set up
% Copies raw c3d files to new processed folder
% When prompted, select the raw c3d subfolder in the data folder

% Select path to raw c3d data folder 
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
 
get_sub_char(fld,'TD_trials');  

%% PART 2: PROCESSING FOR CO-CONTRACTION ANALYSIS

%% Step 2.1: Process EMG signal
%  1- High pass filter @ 20Hz
%  2- Low-pass filter  @ 450 Hz
%  3- Rectify signal
%  4- Root mean square (50 frames)
%  Uses a 4th order filter
ch={'VoltageL_Rect';'VoltageL_Hams';'VoltageL_Gast';'VoltageL_Tib_Ant'};
lp_cut = 450;
hp_cut = 20;
bmech_emgprocess(fld, ch, lp_cut, hp_cut);

%% Step 2.2 Dynamic Normalization
% Run function for dynamic normalization

ch={'VoltageL_Rect_filthigh_filtlow_rect_RMS','VoltageL_Hams_filthigh_filtlow_rect_RMS',...
    'VoltageL_Gast_filthigh_filtlow_rect_RMS','VoltageL_Tib_Ant_filthigh_filtlow_rect_RMS'};
before_str= '';
after_str={'A'};

bmech_emg_dynamic_normalization(fld,ch,before_str,after_str); 


%% Step 2.3: Add kinematic gait event
% Add LFS event
bmech_explode(fld);
offset = 10; % for gait event identification
bmech_addevent(fld, 'SACR_x','LFS', 'LFS', '', offset); 

%% Step 2.4: Resample Video channels 
% - upsamples video to analog frequency to make sure the partition aligns

bmech_resample(fld,'Video')

%% Step 2.5: Partition to a single gait cycle

evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% Step 2.6: Add LFO event

offset = 10; % for gait event identification
bmech_addevent(fld, 'SACR_x','LFO','LFO', '', offset); 

%% Step 2.7: Rename channels

ch_old = {'VoltageL_Rect_filthigh_filtlow_rect_RMS_normalized', 'VoltageL_Hams_filthigh_filtlow_rect_RMS_normalized',...
    'VoltageL_Tib_Ant_filthigh_filtlow_rect_RMS_normalized', 'VoltageL_Gast_filthigh_filtlow_rect_RMS_normalized'...
    'VoltageL_Rect_filthigh_filtlow_rect_RMS','VoltageL_Hams_filthigh_filtlow_rect_RMS',...
    'VoltageL_Tib_Ant_filthigh_filtlow_rect_RMS','VoltageL_Gast_filthigh_filtlow_rect_RMS'};

ch_new = {'L_Rect_normalized', 'L_Hams_normalized','L_Tib_Ant_normalized', 'L_Gast_normalized'...
    'L_Rect_Notnormalized', 'L_Hams_Notnormalized','L_Tib_Ant_Notnormalized', 'L_Gast_Notnormalized'};
      
bmech_renamechannel(fld, ch_old, ch_new)

%% Step 2.8: Calculate muscle co-contraction
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
 
%% Step 2.9: Rename channels

ch_old = {'L_Tib_Ant_normalized_L_Gast_normalized_Lo2017','L_Rect_normalized_L_Hams_normalized_Lo2017',...
'L_Tib_Ant_Notnormalized_L_Gast_Notnormalized_Lo2017','L_Rect_Notnormalized_L_Hams_Notnormalized_Lo2017'};

ch_new = {'L_TA_G_cc_Norm', 'L_RF_HS_cc_Norm', 'L_TA_G_cc_NotNorm', 'L_RF_HS_cc_NotNorm'};...
  
bmech_renamechannel(fld, ch_old, ch_new)


%% PART 3: Extract data to spreadsheet

%% Step 3.1: Output datasheet for stats

subjects = extract_filestruct(fld);
chns = {'L_TA_G_cc_Norm', 'L_RF_HS_cc_Norm', 'L_TA_G_cc_NotNorm', 'L_RF_HS_cc_NotNorm'};
lcl_evts = {'co_contraction_value_from_LFS1_to_LFO1'...
            'co_contraction_value_from_LFO1_to_LFS2'}; 

eventval('fld', fld, 'dim1', '', 'dim2', subjects, 'ch', chns, ...
         'localevents', lcl_evts, 'globalevents', 'none');