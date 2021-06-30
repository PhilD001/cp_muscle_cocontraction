% step-1 keep regular walking data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''1-regular walking''');
end

%only keep '_g_ ' data which are prefered gait speed
fl_gs=engine('fld', fld,'search file','_gs_');
fl_gl=engine('fld', fld,'search file','_gl_');
fl_st=engine('fld', fld,'search file','_st_');
delfile(fl_gs);
delfile(fl_gl);
delfile(fl_st);

%% Step-2 delete folder with no mft sheet

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-delete-no-mft''');
end

[~,subjects] = extract_filestruct(fld);
for i = 1:length(subjects)
    fl = engine('fld',fld, 'search path', subjects{i},'extension','csv');             % chek for only csv files
    if isempty(fl)                                                                    % if no csv file = no mft file
        bmech_removefolder(fld,subjects{i});
        disp(['removing subject ', subjects{i},' because he has no mft sheet'])           % remove subject because not enough info
    else
        disp(['keepoing subject ', subjects{i},' mft sheet found...'])           % remove subject because not enough info

    end
end

%% Step-3: Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% STEP-4: REMOVE ADULTS (-18 YEARS OLD)

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''4-remove_adults''');
end

% b) Extract age of participants
bmech_extract_in_mft(fld,'Age');

% c) Batch remove adults
bmech_remove_by_anthro(fld,'Age',18,'>=');

%% step-5: remove files with missing channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-remove-missing-channels''');
end

% chns  ... cell array of strings. Channels to check
chns = {'LVM','LTibAnt', 'LGM', 'LHam', 'RVM', 'RTibAnt','RGM','RHam'};

bmech_remove_files_missing_channels(fld, chns);

%% STEP-6: clean channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''6-clean-channels''');
end

% ??? are there other unnecessary channels
% PD: I added some, there may be more, not so important for now

ch={'LAnklePower','RAnklePower','LKneePower','RKneePower','LHipPower',...
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

%% step-7: process emg signal
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-emg-process''');
end

ch={'LVM';'LTibAnt';'LGM';'LHam';'RTibAnt';'RGM';'RVM';'RHam'};

bmech_emgprocess_test(fld,ch,450);

%% step-8 add kinematic gait event
bmech_explode(fld)
bmech_addevent(fld, 'SACR_x','RFS', 'RFS') 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS') 


% only keep trials that have at least 1 right or left gait cycle
% choose the side that has the most trials

fl = engine('fld', fld, 'extension', 'zoo');
missing_right = 0;
for i = 1:length(fl)
    data = zload(fl{i});
    if ~isfield(data.SACR_x.event, 'RFS2')
        disp(['missing RFS for ', fl{i}])
        delete(fl{i})
        missing_right = missing_right + 1;
    end
end
disp(['total trials missing RFS2 ', num2str(missing_right)])

missing_left = 0;
for i = 1:length(fl)
    data = zload(fl{i});
    if ~isfield(data.SACR_x.event, 'LFS2')
        disp(['missing LFS for ', fl{i}])
        delete(fl{i})
        missing_left = missing_left + 1;
    end
end
disp(['total trials missing LFS2 ', num2str(missing_left)])

%% step-9: Partitioning the data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-partition''');
end

evtn1 = 'RFS1';                                                              % start name
evtn2 = 'RFS2';                                                              % end name
bmech_partition(fld,evtn1,evtn2);                                                         % run function


%% step-10: Normalize EMG
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-partition''');
end

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);

%% step-11: compute muscle co-contraction

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-partition''');
end

bmech_cocontraction_test(fld,pairs,varargin);
