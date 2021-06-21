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
    end
end
 
%% Step-3: Convet to the Zoo format
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

ch={'LAnklePower','RAnklePower','LKneePower','RKneePower','LHipPower',...
     'RHipPower','LWaistPower','RWaistPower','LAnkleForce','RAnkleForce',...
      'LKneeForce', 'RKneeForce','LHipForce','RHipForce','LWaistForce',...
      'RWaistForce','LGroundReactionMoment','RGroundReactionMoment',...
      'LAnkleMoment','RAnkleMoment','LKneeMoment',' RKneeMoment',...
      'LHipMoment','RHipMoment','LWaistMoment','RWaistMoment'};
         
 bmech_removechannel(fld,ch,'remove');            

%% step-7: process emg signal
mode = 'manual'; 
if strfind(mode,'manual')
    fld = uigetfolder('select ''7-emg-process''');
end

ch={'LVM';'LTibAnt';'LGM';'LHam';'RTibAnt';'RGM';'RVM';'RHam'};
 
bmech_emgprocess_test(fld,ch,450);

%% step-8: delete nagative events
mode = 'manual'; 
if strfind(mode,'manual')
    fld = uigetfolder('select ''8-delete-short-trials''');
end

bmech_remove_negative_events(fld);
%% 
mode = 'manual'; 
if strfind(mode,'manual')
    fld = uigetfolder('select ''8-delete-short-trials''');
end

bmech_remove_negative_events_2(fld)


%% step-9: Partitioning the data
mode = 'manual'; 
if strfind(mode,'manual')
    fld = uigetfolder('select ''5-partition''');
end
                                                       
evtn1 = 'Left_FootStrike1';                                                              % start name
evtn2 = 'Left_FootStrike2';                                                              % end name
bmech_partition(fld,evtn1,evtn2);                                                         % run function


%% step-10: Normalize
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
