%%  Step-1 Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''1-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% STEP 2: sort trials
%
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-sort_trilas''');
end
turninggait_sortbycondition(fld);

%% step 3: remove all conditions except straight
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-delete-trials''');
end
sfld={'LSpin';'RSpin';'LStep';'RStep'};
bmech_removefolder(fld,sfld);

% LStraight,RStraight,Straight??
%% STEP-4: clean channels
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

  %% step-7: process emg signal
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''7-process-emg''');
end

ch={'LRF';'RRF';'LHam';'RHam';'LGM';'RGM';'LTibAnt';'RTibAnt'};
bmech_emgprocess_test(fld,ch,450);

%% step-8:dynamic Normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''8-dynamic-normalize''');
end
ch={'LTibAnt';'LGM';'LHam';'LRF';'RTibAnt';'RGM';'RHam';'RRF';};
before_str= '';
after_str='';

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);

%% step-9 explode data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-explode''')
end

bmech_explode(fld);
%%  step-10 add kinematic gait event
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''10-addevent''');
end
bmech_addevent(fld, 'SACR_x','RFS', 'RFS') 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS') 
%% step-11: Partition to one gait cycle
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''11-partition''');
end
% Left side
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step-12: time_normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-time_normalize''');
end

bmech_normalize(fld);

%% step-13:  plot to find bad emg signals

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-time_normalize''');
end

bmech_find_good_emg(fld);

%% step-14: compute muscle co-contraction

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''13-cocontraction''');
end
pairs={'VM_Ham','GM_TibAnt'};


bmech_cocontraction_test(fld,pairs,'Lo2017');