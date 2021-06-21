function bmech_remove_by_anthro(fld, anthro, value, condition)

% BMECH_REMOVE_BY_ANTHRO(fld, anthro, value, condition)
% Batch process removal of unwanted participants (data) based on anthro
%
% ARGUMENTS
% fld       ...  Folder to batch process (string)
% anthro    ...  Anthro to operate on. Single string. ex. 'Age'
% value     ...  Value to remove (i.e. 18 to remove adult participants)
% condition ...  Condition to remove (string): '>=','<=','<','>','='
%
% Created 2021
%
% Set defaults/Error check

if nargin==0
    fld = uigetfolder;
    anthro = 'Age';
end

if iscell(anthro)
    anthro = anthro{1};
end

% Batch process

cd(fld)

[~,subjects] = extract_filestruct(fld);

for i = 1:length(subjects)
    fl = engine('fld',fld,'extension','zoo', 'search path', subjects{i});
    data = zload(fl{1});
    r = data.zoosystem.Anthro.(anthro);
    if strcmp(condition,'>=')
        if r >= value
           disp(['removing subject ', subjects{i},' because ', anthro, ' is ',condition, num2str(value)])
           bmech_removefolder(fld,subjects{i});
        end
    end
    
    if strcmp(condition,'<=')
        if r <= value
            disp(['removing subject ', subjects{i},' because ', anthro, ' is ',condition, num2str(value)])
            bmech_removefolder(fld,subjects{i})
        end
    end
    if strcmp(condition,'<')
        if r < value
            disp(['removing subject ', subjects{i},' because ', anthro, ' is ',condition, num2str(value)])
            bmech_removefolder(fld,subjects{i})
        end
    end
    if strcmp(condition,'>')
        if r > value
            disp(['removing subject ', subjects{i},' because ', anthro, ' is ',condition, num2str(value)])
            bmech_removefolder(fld,subjects{i})
        end
    end
    if strcmp(condition,'=')
        if r == value
            disp(['removing subject ', subjects{i},' because ', anthro, ' is ',condition, num2str(value)])
            bmech_removefolder(fld,subjects{i})
        end
    end
end

