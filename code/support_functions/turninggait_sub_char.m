function turninggait_sub_char(fld,file)

% extracts extra information from main excel files and adds to zoosystem
%
% ARGUMENTS
% fld   ...  folder of zoo data
% file  ...  suffix name of excel file containing info. Example prefixes
%            are 'TD_','CP_','FF_'
%
% NOTES
% - currently extracts: 
%   age
%   sex
%   GMFCS level (0 for TD children)
%   MidFoot Break (yes = 1, no=0)
%   Ability to dorsiflex ((yes = 1, no=0)
%
% - additinal characteristics can be added at will
%
%
% Created December 3rd 2013 based on turninggait_age_sex.m
%
% Updated December 10th 2013
% -added more cases
%
% Updated May 2014
% - file made more general. Function can process any group data as long as 
%   oganised as existing groups


if nargin==1
    file = [];
end

cd(fld)
fl = engine('path',fld,'extension','zoo');

s = filesep;

if ~isempty(file)
    
    raw = struct;
    s = filesep;
    indx =strfind(fld,s);
    root = fld(1:indx(end));
    
    files = engine('path',root,'extension','csv','search file','_trials');

    for i = 1:length(files)
        [~,pre] = fileparts(files{i});
        pre = strrep(pre,'_trials','');
        raw.(pre) = readtext(files{i});
    end
        
  
    
else
    error('no sheet found')
end



for i=1:length(fl)
    batchdisp(fl{i},'getting anthro')
    data = zload(fl{i});
    data = add_anthro(data,fl{i},raw);
    save(fl{i},'data');
end


function data = add_anthro(data,fl,raw)

indx = strfind(fl,filesep);
child = fl(indx(end-2)+1:indx(end-1)-1);
raw = raw.(child);
        
 
line1 = raw(1,:);

for i = 1:length(line1)
    if  isnan(line1{i})
        line1{i} = '';
    end
end

line1(cellfun(@isempty,line1)) = [];   % That's some hot programming

% subject characteristics 
Subindx =  ismember(line1,'subject')==1;
Sindx = ismember(line1,'Sex')==1;
Ayindx = ismember(line1,'Age (yrs)')==1;
EMGindx = ismember(line1,'EMG leg')==1;
GMFCSindx = ismember(line1,'GMFCS')==1 ; 
MFootBreakRindx = ismember(line1,'MidFootBreakR');
MFootBreakLindx = ismember(line1,'MidFootBreakL');
DorsiRindx = ismember(line1,'CanDorsiflexR');
DorsiLindx = ismember(line1,'CanDorsiflexL');


s=filesep;
indx = strfind(fl,s);
subject = fl(indx(end-1)+1:indx(end)-1);

if isin(subject,'HC22A')
    subject = 'HC022A';
end

subjects = raw(:,Subindx);

stk = zeros(size(subjects));
for i = 1:length(subjects)
    
    if isin(subjects{i},subject)
        stk(i) = 1;
    end
    
end

indx = find(stk==1); % row for appropriate subjecct

% Format subject characteristics
%
Sex = raw(indx,Sindx);
AgeY= raw(indx,Ayindx);
EMG= raw(indx,EMGindx) ;
% Age = AgeY{1}+AgeM{1}/12;
GMFCS = raw(indx,GMFCSindx);
MBreakR = raw(indx,MFootBreakRindx);
MBreakL = raw(indx,MFootBreakLindx);
DorsiR = raw(indx,DorsiRindx);
DorsiL = raw(indx,DorsiLindx);


% add EMG information 
if strcmpi(EMG{1}, 'n/a') || strcmpi(EMG{1}, 'no')
    EMG_R = 0;
    EMG_L = 0;
elseif strcmpi(EMG{1}, 'both')
    EMG_R = 1;
    EMG_L = 1;
elseif strcmpi(EMG{1}, 'r')
    EMG_R = 1;
    EMG_L = 0;
elseif strcmpi(EMG{1}, 'l')
    EMG_R = 0;
    EMG_L = 1;
elseif strcmp(subject, 'HC137A')  % there is an error in the sheet
    EMG_R = 1;
    EMG_L = 1;
else
    error('unknown EMG leg')
end

% add trial specific information
[~, trial] = fileparts(fl);
trial_line = find(ismember(raw(:, 2), trial)==1);
description = raw(trial_line, 3);

% Add to zoosystem
%
data.zoosystem.Anthro.Sex = Sex{1};
data.zoosystem.Anthro.Age = AgeY{1};
data.zoosystem.Anthro.GMFCS = GMFCS{1};
data.zoosystem.Anthro.MBreakR = MBreakR{1};
data.zoosystem.Anthro.MBreakL = MBreakL{1};
data.zoosystem.Anthro.DorsiR = DorsiR{1};
data.zoosystem.Anthro.DorsiL = DorsiL{1};
data.zoosystem.Anthro.EMG_R = EMG_R;
data.zoosystem.Anthro.EMG_L = EMG_L;

data.zoosystem.Header.EMG_Leg = EMG{1};


data.zoosystem.Header.Description = description{1};






