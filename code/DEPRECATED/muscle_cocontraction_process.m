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

%% Step-2 Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% STEP-3 extract Anthro data of participants

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-exctract-Anthro''');
end
% extract age
bmech_extract_in_mft(fld,'Age');
% extract cp type
bmech_extract_in_mft(fld,'GMFCS');
% extract gender 
bmech_extract_in_mft(fld,'Sex');   %(1=M, 2=F)

%% step 4: remove empty folders
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''4-remove-empty''');
end
[~,subjects] = extract_filestruct(fld);
for i = 1:length(subjects)
    fl = engine('fld',fld, 'search path', subjects{i}, 'extension','zoo'); 
    if isempty(fl)                                                         
    bmech_removefolder(fld,subjects{i});
    disp(['removing subject ', subjects{i},' because he has no files'])
    end
end

%% step-5 remove ADULTS (-18 YEARS OLD)

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-remove-adults''');
end

bmech_remove_by_anthro(fld,'Age',18,'>=');

%%step 6: remove empty GMFCS score
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''6-no-GMFCS''');
end
bmech_remove_by_anthro(fld,'GMFCS',0,'=');

%% STEP-7: clean channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-clean-channels''');
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
% only one trial was removed
    
 %% step9- rename emg channels
 mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-rename-emg''');
end

och={'VoltageLVM';'VoltageLTibAnt';'VoltageLGM';'VoltageLHam';'VoltageLRF';'VoltageLGLUTMED';...
    'VoltageRVM';'VoltageRTibAnt';'VoltageRGM';'VoltageRHam';'VoltageRRF';'VoltageRGLUTMED',};
nch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'LGLUTMED';'RVM';'RTibAnt';'RGM';'RHam';'RRF';'RGLUTMED',};
 
 bmech_renamechannel(fld,och,nch);
 %% step-10: remove files with missing channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''10-remove_missing_channel''');
end

% Channels to check: required emg channels & SACR for addevenet step
chns = {'SACR';'LVM';'LTibAnt';'LGM';'LHam';'LRF';'RVM';'RTibAnt';'RGM';'RHam';'RRF'};

bmech_remove_files_missing_channels(fld, chns);  % 11 files was removed with this function
  
 %% step-11: process emg signal
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''11-process-emg''');
end

ch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'RVM';'RTibAnt';'RGM';'RHam';'RRF'};

bmech_emgprocess_test(fld,ch,450);


%% step-12:dynamic Normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-dynamic-normalize''');
end
ch={'LTibAnt';'LGM';'LHam';'LRF';'RTibAnt';'RGM';'RHam';'RRF'};
before_str= '';
after_str='_g';

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);

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
             % 3. Aschau_CP\1989_1\1989_1_g_03.zoo
             % 4. Aschau_CP\2190_1\2190_1_g_23.zoo
             % 5. Aschau_CP\2235_1\2235_1_g_09.zoo
             % 6. Aschau_CP\4136_1\4136_1_g_01.zoo
%% step-15-1 choose correct side
% check  trials (from step 14) for the total number of missing left side

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-side-L''');
end
 
bmech_choose_side_L(fld); % total trials missing LFS2: 170
                          % for the oxford cp : 49
                          % for the oxford TD : 96


%% step-15-2 choose correct side
% check  trials (from step 14) for the total number of missing right side
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''15-side-R''');
end
 
bmech_choose_side_R(fld); % total trials missing RFS2: 177
                          % for the oxford cp : 49
                          % for the oxford TD : 96

%% step16: resample analog channels
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''16-resample''');
end

bmech_resample(fld,'Video')
% Aschau_CP\1989_1\1989_1_g_01.zoo
% Aschau_CP\2513_1\2513_1_g_24.zoo
% Aschau_CP\2524_1\2524_1_g_27.zoo
% Aschau_CP\2524_1\2524_1_g_28.zoo
% Aschau_CP\3158_1\3158_1_g_07.zoo
% Aschau_CP\3249_1\3249_1_g_06.zoo
% Aschau_CP\3249_1\3249_1_g_09.zoo
% Aschau_CP\3249_1\3249_1_g_10.zoo
% Aschau_CP\3249_1\3249_1_g_11.zoo
% Aschau_CP\3249_1\3249_1_g_12.zoo
% Aschau_CP\3249_1\3249_1_g_13.zoo
% Aschau_CP\3249_1\3249_1_g_14.zoo
% Aschau_CP\3339_1\3339_1_g_09.zoo


%% step-17: Partition the data
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''17-partition''');
end
% based on two previous steps: selected side ---> Left
% copy files from step 14

evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

%% step-18: time_normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''18-time-normalize''');
end

bmech_normalize(fld);
% removed files:
               %Aschau_CP\2524_1\2524_1_g_31.zoo
               
% Aftre this step subjects with bad Hams and RF were removed               
% Then they were graphed on ensembler

%% step-16: compute muscle co-contraction

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''18-cocontraction''');
end
pairs={'VM_Ham','GM_TibAnt'};


bmech_cocontraction_test(fld,pairs,'Lo2017');
