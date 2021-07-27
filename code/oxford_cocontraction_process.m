%%  Step-1 Convert to the Zoo format
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''1-c3d2zoo''');
end
%  del='yes';
c3d2zoo(fld,'yes');

%% Step-2 sort trials
% 1) remove static trials
% 2) organize all turning and straight conditions in the subfolders
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''2-sort_trilas''');
end

turninggait_sortbycondition(fld);

%% step-3 delete trials
% 1) remove all conditions except straight 
% 2) organize the straight trials
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''3-delete-trials''');
end

sfld={'LSpin';'RSpin';'LStep';'RStep'};
bmech_removefolder(fld,sfld);

%% STEP-4 clean channels
% remove channels that are not important for this project
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


 %% step-5 remove files with missing channels

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-remove-files''');
end

% chns  ... cell array of strings. Channels to check
% muscles: rectus femoris, semitendinosus, lateral gastrocnemius and tibialis anterior
chns = {'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};

bmech_remove_files_missing_channels(fld, chns);  % 0 files deleted 

%% step-6: process emg signal
% first check raw signals and remove the bad ones before processing
% removerd files for TD: subjects: DH047A,EB053A,HC002D,HC003B,HC004B,HC013A,HC015A,HC019A,HC021A...
%HC022A,HC023A,HC031A,HC033A,HC035A,HC037A,HC038A,HC040A,HC042A,HC044A,HC046A,HC048A
%HC050A,HC054A,HC055A,HC057A,HC060A,IL052A,JB054A  
%removed files for CP: trials: C1268A03.zoo,C1268A15.zoo,C1318A03.zoo,C1500A14.zoo
% TD(n-27) CP (n=12)
 mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select''6-process-emg''');
end

ch={'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};
bmech_emgprocess_test(fld,ch,450);

%% step-7dynamic Normalize
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-dynamic-normalize''');
end
ch={'L_Rect';'R_Rect';'L_Hams';'R_Hams';'L_Gast';'R_Gast';'L_Tib_Ant';'R_Tib_Ant'};
before_str= '';
after_str={'A'};

bmech_dynamic_normalization_test(fld,ch,before_str,after_str);

%% step-8 explode data

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''8-explode''');
end
bmech_explode(fld);

%%  step-9 add kinematic gait event
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-addevent''');
end
bmech_addevent(fld, 'SACR_x','RFS', 'RFS'); 
bmech_addevent(fld, 'SACR_x','LFS', 'LFS'); 
bmech_addevent(fld, 'SACR_x','LFO', 'LFO'); 
bmech_addevent(fld, 'SACR_x','RFO', 'RFO');

%% step 9-1 extract events
% LFS1
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-addevent''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'SACR_x';
evt= 'LFS1'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD
% LFO1
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-addevent''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'SACR_x';
evt= 'LFO1'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD

% LFS2 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-addevent''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'SACR_x';
evt= 'LFS2'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD

% LFO2 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''9-addevent''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'SACR_x';
evt= 'LFO2'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD


%% step-10 resample Video channels 
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''10-resample''');
end
bmech_resample(fld,'Video') %removing: HC039A18.zoo, HC041A09.zoo

%% step-11 Partition 

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''11-partition''');
end
% 1)entire gait cycle
evtn1 = 'LFS1';          % start name
evtn2 = 'LFS2';          % end name
bmech_partition(fld,evtn1,evtn2); 

% % 2) stance
% mode = 'manual';
% if strfind(mode,'manual')
%     fld = uigetfolder('select ''15-partition''');
% end
% evtn1 = 'LFS1';          % start name
% evtn2 = 'LFO1';          % end name
% bmech_partition(fld,evtn1,evtn2); 
% 
% %3)swing
% mode = 'manual';
% if strfind(mode,'manual')
%     fld = uigetfolder('select ''15-partition''');
% end   
% 
% evtn1 = 'LFO1';          % start name
% evtn2 = 'LFS2';          % end name
% bmech_partition(fld,evtn1,evtn2); 

%% step-12 time_normalize

mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''12-time-normalize''');
end
bmech_normalize(fld);

%% step-13 plot data
% use ensembler to graph dynamic normaliaed signals
% remove outliers manually: CP: C1313A06,C1500A07,C1270A04,C139A14,
% C1320A07,C1499A13,C1270A06,C1313A09, C1495A15,C1314A10,C1423A40,C1268A16,C1424A33,C1268A12,C1268A14,C1423A13,C1500A09,C1270A08,C1270A09,C1314A02,C1313A07
% TD: HC059A,HC028A09,HC028A06,HC020A14,HC135A04,HC128A06,HC018A05,HC136A06,HC047A18,HC135A06,HC047A12,HC138A05,HC045A18,
% HC137A09,HC138A04,HC139A04,HC041A08,
% HC045A22,HC014A02,HC028A04,HC141A36,HC141A34,HC135A08,HC047A15,HC018A02,HC032A04,HC138A08,HC016A12
% check all normalized signals and remove zeros
% becuase it is possible that signals were normalized to the wrong signal 
% dynamic normalization and following steps should be repeated again after 
% removing outlires. Copy files from step "process emg" and remove

%% step-14 compute muscle co-contraction

% 1)stride
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFS1','LFS2'});

% 1)stance
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFS1','LFO1'});

% 1)swing
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end
pairs={'L_Rect-L_Hams','L_Tib_Ant-L_Gast'};
bmech_cocontraction_test(fld,pairs,'method','Lo2017','events',{'LFO1','LFS2'});

%% step-19: compare Anthro

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
group = {'CP','TD'};
ch= 'zoosystem';
group_comparison(fld,group,anthro,ch,type,alpha,thresh,tail,mode,bonf)

%% step-20 statistics

%a)LRF_Ham
%a-1)extract events     % just for stride
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'LRF_Ham';
evt= 'co_contraction_value'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD

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

%a) LGM_TibAnt
%a-1)extract events     % just for stride
mode = 'manual';
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-cocontraction''');
end

[cons,subjects] = extract_filestruct(fld);
[subjects1] = extract_filestruct([fld '\' cons{1}]);
[subjects2] = extract_filestruct([fld '\' cons{2}]);

ch= 'LGM_TibAnt';
evt= 'co_contraction_value'; 

r.(cons{1})=extractevents_2(fld,cons(1,1),subjects1,ch,evt); % CP
r.(cons{2})=extractevents_2(fld,cons(2,1),subjects2,ch,evt); % TD

%a-2) t-test analysis
data1 = r.(cons{1});
data2 = r.(cons{2});
type = 'unpaired';
alpha = 0.05;
thresh = 0.05;
tail = 'both';
mode = 'full';

 [P,t,df,e] = omni_ttest(data1,data2,type,alpha,thresh,tail);
 
 