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

bmech_remove_files_missing_channels(fld, chns);  % 0 files deleted for both L& R

  %% step-7: process emg signal
% first check raw signals and remove the bad ones before processing
% removerd files for left: DH047A,EB053A,HC002D,HC003B,HC004B,HC013A,HC015A,HC019A,HC021A...
%HC022A,HC023A,HC031A,HC033A,HC035A,HC037A,HC038A,HC040A,HC042A,HC044A,HC046A,HC048A
%HC050A,HC054A,HC055A,HC057A,HC060A,IL052A,JB054A  
% removerd files for right: all of them

 mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''7-process-emg''');
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
    fld = uigetfolder('select ''10-explode''');
end
bmech_explode(fld);

%%  step-11 add kinematic gait event
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''11-addevent''');
end
bmech_addevent(fld, 'SACR_x','RFS', 'RFS'); 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS'); 
bmech_addevent(fld, 'SACR_x','LFO', 'LFO'); 
bmech_addevent(fld, 'SACR_x','RFO', 'RFO');

%% step-13: resample Video channels 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''13-resample''');
end
bmech_resample(fld,'Video')

%% step-15: Partition 

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-partition''');
end
% 1)entire gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

% 2) stance
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-partition''');
end
evtn1 = 'LFS1';          % start name
evtn2 = 'LFO1';          % end name
bmech_partition(fld,evtn1,evtn2); 

%3)swing
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-partition''');
end   

evtn1 = 'LFO1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step-16: time_normalize

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''16-time-normalize''');
end
bmech_normalize(fld);

%% step-17: plot data
% use ensembler to graph dynamic normaliaed signals
% remove outliers manually 
% check all normalized signals and remove zeros
% becuase it is possible that signals were normalized to the wrong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires
% Thus, steps from dynamic normalization were repeated again
%%%%%%%%% C1268A\C1268A15.zoo' should be removed from step 17-9

%% step-18: compute muscle co-contraction

% 1)stride
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'RF_Ham','GM_TibAnt'};
bmech_cocontraction_test(fld,pairs,{'L'},'Lo2017');

% 2)stance
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'RF_Ham','GM_TibAnt'};
bmech_cocontraction_test(fld,pairs,{'L'},'Lo2017');

% 3)swing
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'RF_Ham','GM_TibAnt'};
bmech_cocontraction_test(fld,pairs,{'L'},'Lo2017');

%% step-19: Statistical analysis

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';
bonf = 1;

%  Group comparison for Age (CP/TD)
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
group = {'CP', 'TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%% step-20: Exporting to spreadsheet 

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end

[dim1,dim2]= extract_filestruct(fld);

excelserver = 'off';                                                        % switch to 'off' 
ext = '.xlsx';                                                              % if java error

levts = {'co_contraction_value'};                                           % local evts                              % local evts
gevts = {'none'};                                                            % global evts                                                          % global evts
aevts = {'Bodymass','Height','Age','Sex','GMFCS'};                         % anthro evts
ch    = {'LRF_Ham','LGM_TibAnt'};                                           % to export
                                                                            % conditions 
       
    
eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,'globalevts',gevts,...
         'anthroevts', aevts, 'ch',ch,'excelserver',excelserver,'ext',ext);

extrcatevents
