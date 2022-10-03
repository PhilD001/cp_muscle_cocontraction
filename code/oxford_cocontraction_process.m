%% Processing pipeline script for the analysis of muscle contraction in children
%  with cerebral palsy (CP) study 
%
% NOTES
% - requires biomechZoo (tested using v 1.9.1)
%
% Data
% - Two datasets are used 
% a) Oxford dataset from PhilD Phd "raw files (05.01.15)" contain TD, CP
% b) NJIT dataset from Saikat Pal "NJIT_CP_dataset" contains CP


%% STEP-0: Get data and set up
% - copies raw c3d files to new processed folder

% select path to raw c3d data folder 
fld_raw = uigetfolder;

% create folder for processed data
indx = strfind(fld_raw, filesep);
fld_root = fld_raw(1:indx(end));
fld = [fld_root, 'processed'];
if exist(fld, 'dir')
    disp('function previously run...overwritting previous run')
    rmdir(fld, 's')
end

% copy raw data to processed folder
mkdir(fld);
copyfile(fld_raw,fld)

% create folder for statistics (eventval sheet)
fld_stats = [fld_root, 'Statistics'];
if exist(fld_stats, 'dir')
    disp('removing old processed data folder...')
    rmdir(fld_stats, 's')
end

% create empty folder for statistics 
mkdir(fld_stats);


%%  Step-1 Convert to the Zoo format
%
del='yes';
c3d2zoo(fld,del);

%% Step-2 Add information for csv files
%
% - needs to be updated for the NJIT data set
turninggait_sub_char(fld,'CP_trials');  % modified from P.Dixon DPhil study code
turninggait_sub_char(fld,'TD_trials');  % modified from P.Dixon DPhil study cod

%% step-3 organize subjects
% remove all conditions except straight
% remove subjects with No Emg leg
% remove TD subject with R Emg leg
% CP(n=12) , TD(n=27)

bmech_remove_by_anthro(fld,'Age',5,'<=');     % remove children younger than 5 years
bmech_remove_by_anthro(fld,'EMG_L',0,'=');    % remove all files with EMG_L missing   % KEEP ALL EMG?
bmech_removebydescription(fld, 'static');     % remove static trials 
bmech_removebydescription(fld, 'Left');       % remove left turn trials
bmech_removebydescription(fld, 'Right');      % remove right turn trials

%% STEP RENAME CHANNELS FROM NJIT DATA SET TO MATCH OXFORD
% 


%% STEP-4 clean up
% remove channels that are not important for this project

ch={'L_Spare','R_Spare','L_Tib_Post','R_Tib_Post','LAnklePower','RAnklePower','LKneePower','RKneePower','LHipPower',...
    'RHipPower','LWaistPower','RWaistPower','LAnkleForce','RAnkleForce',...
    'LKneeForce', 'RKneeForce','LHipForce','RHipForce','LWaistForce',...
    'RWaistForce','LGroundReactionMoment','RGroundReactionMoment',...
    'LAnkleMoment','RAnkleMoment','LKneeMoment',' RKneeMoment',...
    'LHipMoment','RHipMoment','LWaistMoment','RWaistMoment',...
    'RArchHeight', 'LArchHeight', 'CentreOfMass', 'CentreOfMassFloor', ...
    'LArchHeightIndex','RArchHeightIndex', 'RAbsAnkleAngle', 'LAbsAnkleAngle',...
    'LSpineAngles', 'RSpineAngles', 'LThoraxAngles', 'RThoraxAngles',...
    'LFootProgressAngles', 'RFootProgressAngles', 'RNormalisedGRF',...
    'LNormalisedGRF', 'RHXFFA', 'RHFTBA','RFFTBA','RFETBA',...
    'LHXFFA', 'LHFTBA','LFFTBA','FETBA'};

bmech_removechannel(fld,ch,'remove');


 %% step-5 remove files with missing channels

% chns  ... cell array of strings. Channels to check
% muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior

chns = {'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};

bmech_remove_files_missing_channels(fld, chns);  % 1 file (C1423A13.zoo) was deleted 

%% step-6: Process emg signal
% first check raw signals and remove the bad ones using the function
% "bmech_find_good_emg"
% removerd files for TD: subjects: HC059A
% removed trials for CP: trials: C1268A03.zoo,C1268A15.zoo,C1318A03.zoo,C1500A14.zoo
% TD(n=26), CP (n=12)

% PhilD: are the above comments still relevant?

ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
bmech_emgprocess(fld,ch,450);

%% step-7 dynamic Normalize

% run function for dynamic normalization
ch={'L_Rect_filthigh_filtlow_rect_RMS','L_Hams_filthigh_filtlow_rect_RMS',...
    'L_Gast_filthigh_filtlow_rect_RMS','L_Tib_Ant_filthigh_filtlow_rect_RMS'};
before_str= '';
after_str={'A'};

bmech_emg_dynamic_normalization(fld,ch,before_str,after_str); % PhilD: this crashed for me % Sahar : it was OK for me

%% step-8 explode data
% - required for addevent
bmech_explode(fld);

%%  step-9 add kinematic gait event
% - add LFS event
bmech_addevent(fld, 'SACR_x','LFS', 'LFS'); 

%% step-10 resample Video channels 
%
% PD why do these two files fail ? HC039A18.zoo, HC041A09.zoo
delfile('HC039A18.zoo')
delfile('HC041A09.zoo')
bmech_resample(fld,'Video') % should befor runnig: HC039A18.zoo, HC041A09.zoo

%% step-11 Partition to a single gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step_12 remove events

% remove all other previous events added and just keep LFS1 and LFS2

% remove unnecessary gait eventsi

% Phild : This step seems unecessary

evt={'Left_FootStrike1','Left_FootStrike2','Left_FootStrike3','Left_FootStrike4','Right_FootStrike1'...
    'Right_FootStrike2', 'Right_FootStrike3','Left_FootOff1','Left_FootOff2','Left_FootOff3'...
    'Right_FootOff1','Right_FootOff2','Right_FootOff3','Right_FootOff4','LFS3','LFO1','LFO2','LFO3'};

bmech_removeevent(fld,evt)

%% step-13 add event LFO

bmech_addevent(fld, 'SACR_x','LFO','LFO'); 

%% step-14 time_normalize to 100% of the gait cycle

%  function for time normalizetion
bmech_normalize(fld);

%% step-15 plot data
% use ensembler to graph dynamic normalized signals
% make a list of outliers and delite them
% becuase it is possible that signals were normalized to the wrong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires:
% 1-Copy files from step 6 (process emg) 
% 2-run this step to remove the outliers from processed emg files
% 3-remove the empty folders

% outliesr
files = {'C1313A06.zoo','C1270A04.zoo','C1314A10.zoo','C1313A09.zoo','C1393A14.zoo','C1424A30.zoo',...
    'C1314A02.zoo','C1495A15.zoo','HC028A09.zoo','HC055A15.zoo','HC055A07.zoo','HC055A09.zoo',...
    'HC055A10.zoo','HC047A18.zoo','HC047A15.zoo','HC028A04.zoo','HC028A06.zoo','HC045A22.zoo',...
    'HC135A06.zoo','HC141A36.zoo','HC141A34.zoo','HC128A06.zoo','HC045A18.zoo','HC032A04.zoo',...
    'HC047A12.zoo','HC034A07.zoo','HC025A09.zoo','HC025A05.zoo','HC135A08.zoo','HC138A05.zoo',...
    'HC025A06.zoo'};  

% b) Delete trials that are not proper based on the trend seen in the graph
bmech_removefile(fld,files);

% C) remove empty folders
[~,subjects] = extract_filestruct(fld);
for i = 1:length(subjects)
    fl = engine('fld',fld, 'search path', subjects{i}, 'extension','zoo'); 
    if isempty(fl)                                                         
    bmech_removefolder(fld,subjects{i});
    disp(['removing subject ', subjects{i},' because he has no files'])
    end
end

% final good subjects: CP(n=12) , TD (n=24)

%% steps after removing outliers
%% step-16 dynamic Normalize 

% run function for dynamic normalization
ch={'L_Rect_filthigh_filtlow_rect_RMS','L_Hams_filthigh_filtlow_rect_RMS',...
    'L_Gast_filthigh_filtlow_rect_RMS','L_Tib_Ant_filthigh_filtlow_rect_RMS'};
before_str= '';
after_str={'A'};

bmech_emg_dynamic_normalization(fld,ch,before_str,after_str); % PhilD: this crashed for me % Sahar : it was OK for me


%% step-17 compute muscle co-contraction

% function for muscle co-contraction

% Phil D: if you find the channel names to long you can use
% bmech_renamechannel

ch_old = {'L_Rect_filthigh_filtlow_rect_RMS_normalized', 'L_Hams_filthigh_filtlow_rect_RMS_normalized',...
          'L_Tib_Ant_filthigh_filtlow_rect_RMS_normalized', 'L_Gast_filthigh_filtlow_rect_RMS_normalized'};
ch_new = {'L_Rect_normalized', 'L_Hams_normalized',...
          'L_Tib_Ant_normalized', 'L_Gast_normalized'};
bmech_renamechannel(fld, ch_old, ch_new)

pairs={'L_Rect_normalized-L_Hams_normalized',...
       'L_Tib_Ant_normalized-L_Gast_normalized'};

% -1)stride
bmech_cocontraction(fld,pairs,'method','Lo2017','events',{'LFS1','LFS2'});
%-------------------------------------------------------------------------------
% -2)stance
bmech_cocontraction(fld,pairs,'method','Lo2017','events',{'LFS1','LFO1'});
%------------------------------------------------------------------------------
% 3)swing
bmech_cocontraction(fld,pairs,'method','Lo2017','events',{'LFO1','LFS2'});


%% step-25: compare Anthro of CP/TD
% every Anthro should be run seperately

type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';
bonf = 1;

% Group comparison for Age (CP/TD)
anthro = {'Age'};
group = {'CP', 'TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)
 
%  Group comparison for Bodymass (CP/TD)
anthro = {'Bodymass'};
group = {'CP', 'TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%  Group comparison for Height (CP/TD)
anthro = {'Height'};
group = {'CP','TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%% step-26 statistics

%a) muscle pair: L_Rect-L_Hams
%a-1)extract events    

% sahar: I had this Warning (for the first part only): 
% P is greater than the % largest tabulated value,% returning 0.5. 
% > In lillietest (line 207)
%   In omni_ttest (line 134)    

% PhilD: I didn't get a warning

[cons,~] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld, filesep, cons{1}]);
[subjects2] = extract_filestruct([fld, filesep, cons{2}]);

ch= 'L_Rect_normalized_L_Hams_normalized_Lo2017';
evt= 'co_contraction_value_from_LFS1_to_LFS2'; 

r.(cons{1})=extractevents_3(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_3(fld,cons(2,1),subjects2,ch,evt); % TD

%a-2) t-test analysis
data1 = r.(cons{1});
data2 = r.(cons{2});
type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';

[P,t,df,e] = omni_ttest(data1,data2,type,alpha,thresh,tail);
 
 
%-----------------------------------------------------------------------

%a) L_Tib_Ant_L_Gast
%a-1)extract events  


ch= 'L_Tib_Ant_normalized_L_Gast_normalized_Lo2017';
evt= 'co_contraction_value_from_LFS1_to_LFS2'; 

r.(cons{1})=extractevents_3(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_3(fld,cons(2,1),subjects2,ch,evt); % TD

%a-2) t-test analysis
data1 = r.(cons{1});
data2 = r.(cons{2});
type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';

[P,t,df,e] = omni_ttest(data1,data2,type,alpha,thresh,tail);
 
