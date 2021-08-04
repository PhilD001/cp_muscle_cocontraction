%% 

% 
%
% NOTES
% - tested using v 1.8.1 of the biomechZoo toolbox


%% STEP-0: Set defaults 
%
% - copy raw c3d files to new processed folder

% initial path to raw c3d data folder -------------------------------------------------------
fld_raw = uigetfolder;

% create copy of data for processing ------------------------------------------------
indx = strfind(fld_raw, filesep);
fld = [fld_raw(1:indx(end)), filesep, 'processed'];

if exist(fld, 'dir')
    disp('function previously run...overwritting previous run')
    rmdir(fld, 's')
end

mkdir(fld);
copyfile(fld_raw,fld)


%%  Step-1 Convert to the Zoo format

del='yes';
c3d2zoo(fld,del);

%% Step-2 Add information for csv files
turninggait_sub_char(fld,'CP_trials');
turninggait_sub_char(fld,'TD_trials');

%% step-3 organize subjects
% remove all conditions except straight
% remove subjects with No Emg leg
% remove TD subject with R Emg leg
% CP(n=12) , TD(n=27)
bmech_remove_by_anthro(fld,'Age',5,'<=');     % remove children younger than 5 years
bmech_remove_by_anthro(fld,'EMG_L',0,'=');    % remove all files with EMG_L missing
bmech_removebydescription(fld, 'static');     % remove static trials
bmech_removebydescription(fld, 'Left Turn');
bmech_removebydescription(fld, 'Right Turn');



%% STEP-3 clean channels
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


 %% step-4 remove files with missing channels


% chns  ... cell array of strings. Channels to check
% muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior
chns = {'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};

bmech_remove_files_missing_channels(fld, chns);  % 1 files deleted 

%% step-5: process emg signal
% first check raw signals and remove the bad ones before processing
% removerd files for TD: subjects: HC059A
% removed trials for CP: trials: C1268A03.zoo,C1268A15.zoo,C1318A03.zoo,C1500A14.zoo
% TD(n=26), CP (n=12)

ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
bmech_emgprocess_test(fld,ch,450);

%% step-6 dynamic Normalize
ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
before_str= '';
after_str={'A'};

bmech_dynamic_normalization_test(fld,ch,before_str,after_str); % PhilD: this crashed for me

%% step-7 explode data

bmech_explode(fld);

%%  step-8 add kinematic gait event
% add LFS event

bmech_addevent(fld, 'SACR_x','LFS', 'LFS'); 


%% step-9 resample Video channels 

bmech_resample(fld,'Video') %removing: HC039A18.zoo, HC041A09.zoo

%% step-10 Partition 

% 1)entire gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step_11 remove events
% remove all other previous events added and just keep LFS1 and LFS2

evt={'Left_FootStrike1','Left_FootStrike2','Left_FootStrike3','Left_FootStrike4','Right_FootStrike1'...
    'Right_FootStrike2', 'Right_FootStrike3','Left_FootOff1','Left_FootOff2','Left_FootOff3'...
    'Right_FootOff1','Right_FootOff2','Right_FootOff3','Right_FootOff4','LFS3','LFO1','LFO2','LFO3'};
bmech_removeevent(fld,evt)

%% step-12 add event LFO
% add LFO event


bmech_addevent(fld, 'SACR_x','LFO','LFO'); 

%% step-13 time_normalize

bmech_normalize(fld);

%% step-14 plot data
% use ensembler to graph dynamic normalized signals
% remove outliers manually:
%cp:C1313A06,C1500A07,C11393A14,C1320A07,C1268A12,,C1424A30,C1314A10,C1500A09,
%C11313A09,C1495A15,,C1314A02,C11270A04,C1268A16

%TD:%HC028A,HC047A18,HC047A15,HC135A06,HC045A22,HC141A36,HC141A34,HC128A06,HC138A05,HC047A12,
%HC045A18,,HC032A04,HC034A07 ,HC020A14,HC135A08,HC141A06,HC025A06,HC136A10,HC025A09

% after that check all normalized signals and remove zeros
% becuase it is possible that signals were normalized to the wrong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires. Copy files from step "process emg" and repeat steps 5
% to 13 then continue with step 14

% CP(n=12) , TD (n=25)
delfile
outliers = {''}; % PhilD : make a list of outlier files then use delfiles to remove

%% step-14 compute muscle co-contraction

% 1)stride
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFS1','LFS2'});
%-------------------------------------------------------------------------------
% 2)stance
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFS1','LFO1'});
%------------------------------------------------------------------------------
% 3)swing
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFO1','LFS2'});



%% step-15: compare Anthro of CP/TD
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

%% step-16 statistics

%a) muscle pair: L_Rect-L_Hams
%a-1)extract events    
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-cocontraction''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'L_Rect_L_Hams_Lo2017';
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
%a-1)extract events     % just for stride
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-cocontraction''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'L_Tib_Ant_L_Gast_Lo2017';
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
 
