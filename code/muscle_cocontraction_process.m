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

%% Step-3 Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% STEP-4 extract Anthro data of participants

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''4-ectract-age''');
end
% extract age
bmech_extract_in_mft(fld,'Age');

bmech_extract_in_mft(fld,'GMFCS');
%% step-5 REMOVE ADULTS (-18 YEARS OLD)

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-remove_adults''');
end

bmech_remove_by_anthro(fld,'Age',18,'>=');

%% STEP-7: clean channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''6-clean-channels''');
end

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

%% step-8 remove trials with empty channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''8-remove-trials''');
end

fl=engine('fld',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    fields= fieldnames(data);
    if length(fields)<= 1
        disp(['removing', fl{i},' because the number of fields is ',num2str(length(fields))] );
        delfile(fl{i});
        
    end

end
% We removed manually file because they became empty: 1. Aschau_NORM\32_1
                                                   %  2. Aschau_cp\2044_2
    
 %% step9- rename emg channels
 mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-rename-emg''');
end

och={'VoltageLVM';'VoltageLTibAnt';'VoltageLGM';'VoltageLHam';'VoltageLRF';'VoltageLGLUTMED';...
    'VoltageRVM';'VoltageRTibAnt';'VoltageRGM';'VoltageRHam';'VoltageRRF';'VoltageRGLUTMED',};
nch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'LGLUTMED';'RVM';'RTibAnt';'RGM';'RHam';'RRF';'RGLUTMED',};
 
 bmech_renamechannel(fld,och,nch);
  
 %% step-10: process emg signal
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''10-process-emg''');
end

ch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'LGLUTMED';'RVM';'RTibAnt';'RGM';'RHam';'RRF';'RGLUTMED',};

bmech_emgprocess_test(fld,ch,450);


%% step-11: Normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''11-normalize''');
end
ch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'LGLUTMED';'RVM';'RTibAnt';'RGM';'RHam';'RRF';'RGLUTMED',};
before_str= '';
after_str='_g';

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);


%% step-6: remove files with missing channels

% added this section because of error in addevent section
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-remove_missing_channel''');
end

% chns  ... cell array of strings. Channels to check
chns = {'SACR'};

bmech_remove_files_missing_channels(fld, chns);  % 11 files was removed with this function


%% step-13 explode data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''13-explode''')
end

bmech_explode(fld);

%%  step-14 add kinematic gait event
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''14-addevent''');
end
bmech_addevent(fld, 'SACR_x','RFS', 'RFS') 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS') 

% In this step before runing function we removed this trials to run the function: 
             % 1. Aschau_CP\2337_1\2337_1_g_15.zoo
             % 2. Aschau_NORM\56_5\56_5_g_07.zoo
             % 3. Aschau_CP\1807_1\1807_1_g_11.zoo
             % 4. Aschau_CP\1989_1\1989_1_g_03.zoo
             % 5. Aschau_CP\2190_1\2190_1_g_23.zoo
             % 6. Aschau_CP\2235_1\2235_1_g_09.zoo
             % 7. Aschau_NORM\10_1\128_1_g_05.zoo
%% step-15-1 choose correct side
% check  trials (from step 14) for the total number of missing left side

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-choose-side-L''');
end
 
bmech_choose_side_L(fld); % total trials missing LFS2 349


%% step-15-2 choose correct side
% check  trials (from step 14) for the total number of missing right side
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-choose-side-R''');
end
 
bmech_choose_side_R(fld); % total trials missing RFS2 319


%% step-16: Partition the data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''16-partition''');
end
% based on two previous steps: selected side ---> Right
% copy files from step 14

evtn1 = 'RFS1';          % start name
evtn2 = 'RFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step-17: time_normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''17-time_normalize''');
end

bmech_normalize(fld);
% removed files:Aschau_CP\2524_1\2524_1_g_27.zoo
               %Aschau_CP\2524_1\2524_1_g_31.zoo
               %Aschau_CP\2671_1\2671_1_g_11.zoo
              % Aschau_NORM\23_1\23_1_g_02.zoo
%% STEP-18 extract cp type
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''4-ectract-age''');
end
% use file for step 17
bmech_extract_in_mft(fld,'GMFCS');

%% step:  plot to find bad emg signals

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''??''');
end

bmech_find_good_emg(fld);  %run this function for every folder of cp and norm

%coment for bad signals: in excel sheet

%% step-16: compute muscle co-contraction

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''16-cocontraction''');
end
pairs={'VM_Ham','GM_TibAnt'};


bmech_cocontraction_test(fld,pairs,'Lo2017');
