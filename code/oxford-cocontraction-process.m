%%  Step-1 Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''1-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% Step-2 sort trials
% 1) static trisla were removed
% 2) all turning and straight conditions were sort in the subfolders
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-sort_trilas''');
end
turninggait_sortbycondition(fld);

%% step 3: delete trials
% 1) all conditions except straight are removed
% 2) organize the straight trials
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-delete-trials''');
end
sfld={'LSpin';'RSpin';'LStep';'RStep'};
bmech_removefolder(fld,sfld);

%% STEP-4: clean channels
% removing channels that are not important for this project
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''4-clean-channels''');
end
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


%% step 5- rename emg channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-rename-emg''');
end
% muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior
och={'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};
nch={'LRF';'RRF';'LHam';'RHam';'LGM';'RGM';'LTibAnt';'RTibAnt'};
 
 bmech_renamechannel(fld,och,nch);
 
 %% step-6: remove files with missing channels

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''6-remove-channels''');
end

% chns  ... cell array of strings. Channels to check
chns = {'LRF';'RRF';'LHam';'RHam';'LGM';'RGM';'LTibAnt';'RTibAnt'};

bmech_remove_files_missing_channels(fld, chns);  % 0 files deleted

  %% step-8: process emg signal
% first check raw signals and remove the bad ones before processing
% removerd files: DH047A,EB053A,HC002D,HC003B,HC004B,HC013A,HC015A,HC019A,HC021A...
%HC022A,HC023A,HC031A,HC033A,HC035A,HC037A,HC038A,HC040A,HC042A,HC044A,HC046A,HC048A
%HC050A,HC054A,HC055A,HC057A,HC060A,IL052A,JB054A   
 mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''8-process-emg''');
end

ch={'LRF';'RRF';'LHam';'RHam';'LGM';'RGM';'LTibAnt';'RTibAnt'};
bmech_emgprocess_test(fld,ch,450);

%% step-9:dynamic Normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-dynamic-normalize''');
end
ch={'LTibAnt';'LGM';'LHam';'LRF';'RTibAnt';'RGM';'RHam';'RRF'};
before_str= '';
after_str='A';

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);

%% step-10 explode data

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''10-explode''')
end
bmech_explode(fld);

%%  step-11 add kinematic gait event
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''11-addevent''');
end
bmech_addevent(fld, 'SACR_x','RFS', 'RFS') 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS') 

%% step-12-1 choose correct side
% check  trials (from step 12) for the total number of missing left side

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-1-missing-left''');
end
 
bmech_choose_side_L(fld); % total trials missing LFS2 0

%% step-12-2 choose correct side
% check  trials (from step 12) for the total number of missing right side
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-2-missing-right''');
end
 
bmech_choose_side_R(fld) % total trials missing RFS2 0

%% step-13: resample Video channels 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''13-resample''');
end
%removed files to run the function: HC039A18.zoo, HC041A09.zoo
bmech_resample(fld,'Video')

%% step 14: organize sides
% CP subjects have emg for both legs
% TD subjects have left/right/both emg legs -----> in this step they 
% were categorized in to left and right gruops
% files for right sides are not processed

%% step-15: Partition to one gait cycle
% copy files from step 14( left)
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-partition''');
end
% Left side
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step-16: time_normalize
% copy files from step 15
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''16-time-normalize''');
end
bmech_normalize(fld);

%% step-17: plot data
% use ensembler to graph dynamic normaliaed signals
% remove outliers manually 
% check all normalized signals and remove zeros
% becuase it is possible that signals were normalized to the rong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires
% Thus, steps 9,10,11,13,15,16 were repeated again

%% step-18: compute muscle co-contraction

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''18-cocontraction''');
end
pairs={'RF_Ham','GM_TibAnt'};

bmech_cocontraction_test(fld,pairs,{'L'},'Lo2017');

%% step-19: Statistical analysis

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''19-stats''');
end
type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';
bonf = 1;

%  Group comparison for anthro (CP/TD)
anthro = {'Age','Bodymass','Height'};
group = {'CP', 'TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%% step-20: Exporting to spreadsheet 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''19-stats''');
end

[~, subjects] = extract_filestruct(fld);
groups = GetSubDirsFirstLevelOnly(fld);

anthro_evts = {'Height','Bodymass', 'Sex', 'Age', 'GMFCS'};
chns = {''};

evalFile = eventval('fld', fld, 'dim1', groups, 'dim2', subjects, 'ch', chns, ...
    'localevents', 'none', 'globalevents','none', 'anthroevts', anthro_evts);

% eventval2mixedANOVA('eventvalFile', evalFile)

%%

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''19-stats''');
end
excelserver = 'off';                                                        % switch to 'off' 
ext = '.xlsx';                                                              % if java error

levts = {' co_contraction_value_entire_gait'};                              % local evts                              % local evts
gevts = {'RFO'};                                                            % global evts                                                          % global evts
aevts = {'Bodymass', 'Height','Age','Sex','GMFCS'};                                             % anthro evts
ch    = {'LRF_Ham','LGM_TibAnt'};                            % to export
dim1  = {'CP'};                                                % conditions
dim2  = {'C1268A','C1270A','C1313A','C1314A','C1318A','C1320A',...          % subjects
         'C1393A','C1423A','C1424A','C1495A','C1499A','C1500A'};
    
eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
         'anthroevts', aevts, 'ch',ch,'excelserver',excelserver,'ext',ext);