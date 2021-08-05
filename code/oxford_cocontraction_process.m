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

fld = uigetfolder;

% a) create copy of data for conversion
indx = strfind(fld, filesep);
fld1 = [fld(1:indx(end)), filesep, '1-c3d2zoo'];

if exist(fld1, 'dir')
    disp('removing old data folder...')
    rmdir(fld1)
end

mkdir(fld1);
copyfile(fld,fld1);

% b) Convert c3d to zoo
del='yes';
c3d2zoo(fld1,del);

%% Step-2 Add information for csv files

fld1= uigetfolder;

% a) create copy of data step 1
indx = strfind(fld1, filesep);
fld2 = [fld1(1:indx(end)), filesep, '2-Add-CSV-info'];

if exist(fld2, 'dir')
    disp('removing old data folder...')
    rmdir(fld2)
end
mkdir(fld2);
copyfile(fld1,fld2);

% b)add csv information 
turninggait_sub_char(fld2,'CP_trials');
turninggait_sub_char(fld2,'TD_trials');

%% step-3 organize subjects
% remove all conditions except straight
% remove subjects with No Emg leg
% remove TD subject with R Emg leg
% CP(n=12) , TD(n=27)

fld2= uigetfolder;
% a) create copy of data step 2
indx = strfind(fld2, filesep);
fld3 = [fld2(1:indx(end)), filesep, '3-organize-subjects'];

if exist(fld3, 'dir')
    disp('removing old data folder...')
    rmdir(fld3)
end
mkdir(fld3);
copyfile(fld2,fld3);

% b)add csv information 

bmech_remove_by_anthro(fld3,'Age',5,'<=');     % remove children younger than 5 years
bmech_remove_by_anthro(fld3,'EMG_L',0,'=');    % remove all files with EMG_L missing
bmech_removebydescription(fld3, 'static');     % remove static trials
bmech_removebydescription(fld3, 'Left');
bmech_removebydescription(fld3, 'Right');



%% STEP-4 clean channels
% remove channels that are not important for this project

fld3= uigetfolder;

% a) create copy of data step 3
indx = strfind(fld3, filesep);
fld4 = [fld3(1:indx(end)), filesep, '4-clean-channels'];

if exist(fld4, 'dir')
    disp('removing old data folder...')
    rmdir(fld4)
end
mkdir(fld4);
copyfile(fld3,fld4);

% b)clean channels

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

bmech_removechannel(fld4,ch,'remove');


 %% step-5 remove files with missing channels

% chns  ... cell array of strings. Channels to check
% muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior

fld4= uigetfolder;

% a) create copy of data step 4
indx = strfind(fld4, filesep);
fld5 = [fld4(1:indx(end)), filesep, '5-remove-files'];

if exist(fld5, 'dir')
    disp('removing old data folder...')
    rmdir(fld5)
end
mkdir(fld5);
copyfile(fld4,fld5);

% b)remove files that do not have these channels
chns = {'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};

bmech_remove_files_missing_channels(fld5, chns);  % 1 file (C1423A13.zoo) was deleted 

%% step-6: Process emg signal
% first check raw signals and remove the bad ones using the function
% "bmech_find_good_emg"
% removerd files for TD: subjects: HC059A
% removed trials for CP: trials: C1268A03.zoo,C1268A15.zoo,C1318A03.zoo,C1500A14.zoo
% TD(n=26), CP (n=12)

fld5= uigetfolder;

% a) create copy of data step 5
indx = strfind(fld5, filesep);
fld6 = [fld5(1:indx(end)), filesep, '6-process-emg'];

if exist(fld6, 'dir')
    disp('removing old data folder...')
    rmdir(fld6)
end
mkdir(fld6);
copyfile(fld5,fld6);

% b)run function to process emg

ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
bmech_emgprocess_test(fld6,ch,450);

%% step-7 dynamic Normalize

fld6= uigetfolder;

% a) create copy of data step 6
indx = strfind(fld6, filesep);
fld7 = [fld6(1:indx(end)), filesep, '7-dynamic-normalize'];

if exist(fld7, 'dir')
    disp('removing old data folder...')
    rmdir(fld7)
end
mkdir(fld7);
copyfile(fld6,fld7);

% b)run function for dynamic normalization
ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
before_str= '';
after_str={'A'};

bmech_dynamic_normalization_test(fld7,ch,before_str,after_str); % PhilD: this crashed for me % Sahar : it was OK for me

%% step-8 explode data

fld7= uigetfolder;

% a) create copy of data step 7
indx = strfind(fld7, filesep);
fld8 = [fld7(1:indx(end)), filesep, '8-explode'];

if exist(fld8, 'dir')
    disp('removing old data folder...')
    rmdir(fld8)
end
mkdir(fld8);
copyfile(fld7,fld8);

% b)run function to explode data
bmech_explode(fld8);

%%  step-9 add kinematic gait event

fld8= uigetfolder;

% a) create copy of data step 8
indx = strfind(fld8, filesep);
fld9 = [fld8(1:indx(end)), filesep, '9-addevent-LFS'];

if exist(fld9, 'dir')
    disp('removing old data folder...')
    rmdir(fld9)
end
mkdir(fld9);
copyfile(fld8,fld9);

% b) add LFS event

bmech_addevent(fld9, 'SACR_x','LFS', 'LFS'); 

%% step-10 resample Video channels 

fld9= uigetfolder;

% a) create copy of data step 9
indx = strfind(fld9, filesep);
fld10 = [fld9(1:indx(end)), filesep, '10-resample'];

if exist(fld10, 'dir')
    disp('removing old data folder...')
    rmdir(fld10)
end
mkdir(fld10);
copyfile(fld9,fld10);

% b) run function to resample

bmech_resample(fld10,'Video') % should befor runnig: HC039A18.zoo, HC041A09.zoo

%% step-11 Partition 

fld10= uigetfolder;

% a) create copy of data step 10
indx = strfind(fld10, filesep);
fld11 = [fld10(1:indx(end)), filesep, '11-partition'];

if exist(fld11, 'dir')
    disp('removing old data folder...')
    rmdir(fld11)
end
mkdir(fld11);
copyfile(fld10,fld11);


% b) partition to the entire gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld11,evtn1,evtn2); 

%% step_12 remove events

% remove all other previous events added and just keep LFS1 and LFS2
fld11= uigetfolder;

% a) create copy of data step 11
indx = strfind(fld11, filesep);
fld12 = [fld11(1:indx(end)), filesep, '12-remove-events'];

if exist(fld12, 'dir')
    disp('removing old data folder...')
    rmdir(fld12)
end
mkdir(fld12);
copyfile(fld11,fld12);


% b) remove unnecessary gait events

evt={'Left_FootStrike1','Left_FootStrike2','Left_FootStrike3','Left_FootStrike4','Right_FootStrike1'...
    'Right_FootStrike2', 'Right_FootStrike3','Left_FootOff1','Left_FootOff2','Left_FootOff3'...
    'Right_FootOff1','Right_FootOff2','Right_FootOff3','Right_FootOff4','LFS3','LFO1','LFO2','LFO3'};

bmech_removeevent(fld12,evt)

%% step-13 add event LFO

fld12= uigetfolder;
% a) create copy of data step 12

indx = strfind(fld12, filesep);
fld13 = [fld12(1:indx(end)), filesep, '13-addevent-LFO'];

if exist(fld13, 'dir')
    disp('removing old data folder...')
    rmdir(fld13)
end
mkdir(fld13);
copyfile(fld12,fld13);


% b) add LFO event

bmech_addevent(fld13, 'SACR_x','LFO','LFO'); 

%% step-14 time_normalize

fld13= uigetfolder;

% a) create copy of data step 13

indx = strfind(fld13, filesep);
fld14 = [fld13(1:indx(end)), filesep, '14-time-normalize'];

if exist(fld14, 'dir')
    disp('removing old data folder...')
    rmdir(fld14)
end
mkdir(fld14);
copyfile(fld13,fld14);


% b) function for time normalizetion

bmech_normalize(fld14);

%% step-15 plot data
% use ensembler to graph dynamic normalized signals
% make a list of outliers and delite them
% becuase it is possible that signals were normalized to the wrong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires:
% 1-Copy files from step 6 (process emg) 
% 2-run this step to remove the outliers from processed emg files
% 3-remove the empty folders


fld6= uigetfolder;

% a) create copy of data step 6

indx = strfind(fld6, filesep);
fld15 = [fld6(1:indx(end)), filesep, '15-remove-outliers'];

if exist(fld15, 'dir')
    disp('removing old data folder...')
    rmdir(fld15)
end
mkdir(fld15);
copyfile(fld6,fld15);

% outliesr
files = {'C1313A06.zoo','C1270A04.zoo','C1314A10.zoo','C1313A09.zoo','C1393A14.zoo','C1424A30.zoo',...
    'C1314A02.zoo','C1495A15.zoo','HC028A09.zoo','HC055A15.zoo','HC055A07.zoo','HC055A09.zoo',...
    'HC055A10.zoo','HC047A18.zoo','HC047A15.zoo','HC028A04.zoo','HC028A06.zoo','HC045A22.zoo',...
    'HC135A06.zoo','HC141A36.zoo','HC141A34.zoo','HC128A06.zoo','HC045A18.zoo','HC032A04.zoo',...
    'HC047A12.zoo','HC034A07.zoo','HC025A09.zoo','HC025A05.zoo','HC135A08.zoo','HC138A05.zoo',...
    'HC025A06.zoo'};  

% b) Delete trials that are not proper based on the trend seen in the graph
bmech_removefile(fld15,files);

% C) remove empty folders
[~,subjects] = extract_filestruct(fld15);
for i = 1:length(subjects)
    fl = engine('fld',fld15, 'search path', subjects{i}, 'extension','zoo'); 
    if isempty(fl)                                                         
    bmech_removefolder(fld15,subjects{i});
    disp(['removing subject ', subjects{i},' because he has no files'])
    end
end

% final good subjects: CP(n=12) , TD (n=24)

%% steps after removing outliers
%% step-16 dynamic Normalize 

fld15= uigetfolder;

% a) create copy of data step 15
indx = strfind(fld15, filesep);
fld16 = [fld15(1:indx(end)), filesep, '16-normalized-emg'];

if exist(fld16, 'dir')
    disp('removing old data folder...')
    rmdir(fld16)
end
mkdir(fld16);
copyfile(fld15,fld16);

% b)run function for dynamic normalization
ch={'L_Rect';'L_Hams';'L_Gast';'L_Tib_Ant'};
before_str= '';
after_str={'A'};

bmech_dynamic_normalization_test(fld16,ch,before_str,after_str); % PhilD: this crashed for me % Sahar : it was OK for me

%% step-17 explode data

fld16= uigetfolder;

% a) create copy of data step 16
indx = strfind(fld16, filesep);
fld17 = [fld16(1:indx(end)), filesep, '17-explode'];

if exist(fld17, 'dir')
    disp('removing old data folder...')
    rmdir(fld17)
end
mkdir(fld17);
copyfile(fld16,fld17);

% b)run function to explode data
bmech_explode(fld17);

%%  step-18 add kinematic gait event

fld17= uigetfolder;

% a) create copy of data step 8
indx = strfind(fld17, filesep);
fld18 = [fld17(1:indx(end)), filesep, '18-addevent-LFS'];

if exist(fld18, 'dir')
    disp('removing old data folder...')
    rmdir(fld18)
end
mkdir(fld18);
copyfile(fld17,fld18);

% b) add LFS event

bmech_addevent(fld18, 'SACR_x','LFS', 'LFS'); 

%% step-19 resample Video channels 

fld18= uigetfolder;

% a) create copy of data step 9
indx = strfind(fld18, filesep);
fld19 = [fld18(1:indx(end)), filesep, '19-resample'];

if exist(fld19, 'dir')
    disp('removing old data folder...')
    rmdir(fld19)
end
mkdir(fld19);
copyfile(fld18,fld19);

% b) run function to resample

bmech_resample(fld19,'Video') % should remove before runnig: HC039A18.zoo, HC041A09.zoo

%% step-20 Partition 

fld19= uigetfolder;

% a) create copy of data step 19
indx = strfind(fld19, filesep);
fld20 = [fld19(1:indx(end)), filesep, '20-partition'];

if exist(fld20, 'dir')
    disp('removing old data folder...')
    rmdir(fld20)
end
mkdir(fld20);
copyfile(fld19,fld20);


% b) partition to the entire gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld20,evtn1,evtn2); 

%% step_21 remove events
% remove all other previous events added and just keep LFS1 and LFS2

fld20= uigetfolder;

% a) create copy of data step 20
indx = strfind(fld20, filesep);
fld21 = [fld20(1:indx(end)), filesep, '21-remove-events'];

if exist(fld21, 'dir')
    disp('removing old data folder...')
    rmdir(fld21)
end
mkdir(fld21);
copyfile(fld20,fld21);


% b) remove unnecessary gait events

evt={'Left_FootStrike1','Left_FootStrike2','Left_FootStrike3','Left_FootStrike4','Right_FootStrike1'...
    'Right_FootStrike2', 'Right_FootStrike3','Left_FootOff1','Left_FootOff2','Left_FootOff3'...
    'Right_FootOff1','Right_FootOff2','Right_FootOff3','Right_FootOff4','LFS3','LFO1','LFO2','LFO3'};

bmech_removeevent(fld21,evt)

%% step-22 add event LFO

fld21= uigetfolder;
% a) create copy of data step 21

indx = strfind(fld21, filesep);
fld22 = [fld21(1:indx(end)), filesep, '22-addevent-LFO'];

if exist(fld22, 'dir')
    disp('removing old data folder...')
    rmdir(fld22)
end
mkdir(fld22);
copyfile(fld21,fld22);


% b) add LFO event

bmech_addevent(fld22, 'SACR_x','LFO','LFO'); 

%% step-23 time_normalize

fld22= uigetfolder;

% a) create copy of data step 22

indx = strfind(fld22, filesep);
fld23 = [fld22(1:indx(end)), filesep, '23-time-normalize'];

if exist(fld23, 'dir')
    disp('removing old data folder...')
    rmdir(fld23)
end
mkdir(fld23);
copyfile(fld22,fld23);


% b) function for time normalizetion

bmech_normalize(fld23);


%% step-24 compute muscle co-contraction

fld22= uigetfolder;

% a) create copy of data step 23

indx = strfind(fld23, filesep);
fld24 = [fld23(1:indx(end)), filesep, '24-cocontraction'];

if exist(fld24, 'dir')
    disp('removing old data folder...')
    rmdir(fld24)
end
mkdir(fld24);
copyfile(fld23,fld24);


% b) function for muscle co-contraction

% b-1)stride
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld24,pairs,'method','Lo2017','events',{'LFS1','LFS2'});
%-------------------------------------------------------------------------------
% b-2)stance
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld24,pairs,'method','Lo2017','events',{'LFS1','LFO1'});
%------------------------------------------------------------------------------
% b-3)swing
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld24,pairs,'method','Lo2017','events',{'LFO1','LFS2'});


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
group_comparison(fld24,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)
 
%  Group comparison for Bodymass (CP/TD)
anthro = {'Bodymass'};
group = {'CP', 'TD'};
ch= 'zoosystem';
group_comparison(fld24,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%  Group comparison for Height (CP/TD)
anthro = {'Height'};
group = {'CP','TD'};
ch= 'zoosystem';
group_comparison(fld24,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%% step-26 statistics

%a) muscle pair: L_Rect-L_Hams
%a-1)extract events    

% sahar: I had this Warning (for the first part only): 
% P is greater than the % largest tabulated value,% returning 0.5. 
% > In lillietest (line 207)
%   In omni_ttest (line 134)    

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''24-cocontraction''');
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
%a-1)extract events  

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''24-cocontraction''');
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
 
