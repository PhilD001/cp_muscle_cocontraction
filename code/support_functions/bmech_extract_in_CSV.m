function bmech_extract_in_CSV(fld,anthro)

% EXTRACT_IN_MFT(fld, anthro)
% Batch process extraction of anthro data in the mft sheet
%
% ARGUMENTS
% fld       ...  Folder to batch process (string)
% anthro    ...  Anthro(s) to extract from the mft sheet
%
% Created 2021
%
% Set defaults/Error check

if nargin==0
    fld = uigetfolder;
    anthro = 'Age';
end

if ~iscell(anthro)
    anthro = {anthro};
end

cd(fld);
fl = engine('fld',fld,'extension','zoo');
for i = 1:length(fl)
    batchdisp(fl{i}, 'extracting csv')
    data = zload(fl{i});
    fld_sub = fileparts(fl{i});
    
    % a) Extract Age
    if strcmp(anthro,'Age')
        if ~isfield(data.zoosystem.Anthro,'Age') % Extract if not
            csv_path = [fld_sub, filesep, 'TD_trials.csv']; % Set path csv.csv
            C = readcell(csv_path);
            [row,col] = find(strcmp(C,'Age (yrs)'));
           
            for j=1:length(C)
                Age = C(row+1,col);
                data.zoosystem.Anthro.Age = Age{1}; % write to zoo
            end
        end
    end
    %b) Extract Sex
    if strcmp(anthro,'Sex')
        if ~isfield(data.zoosystem.Anthro,'Sex')
            csv_path = [fld_sub, filesep, 'TD_trials.csv']; % Set path csv.csv
            C = readcell(csv_path);
            [row,col] = find(strcmp(C,'sex'));
            Sex = C(row+1,col);
            data.zoosystem.Anthro.Sex = Sex{1}; % write to zoo (1=M, 2=F)
        end
    end
    %c) Extract GMFCS
    if strcmp(anthro,'GMFCS')
        if ~isfield(data.zoosystem.Anthro,'GMFCS')
            csv_path = [fld_sub, filesep, 'TD_trials.csv']; % Set path csv.csv
            C = readcell(csv_path);
            [row,col] = find(strcmp(C,'GMFCS'));
            if isempty(row)
                [row,col] = find(strcmp(C,'GMFCS'));
            end
            a = C(row+1,col);
            if isempty(a)
                GMFCS = 0;
            elseif strcmp(a,'-')
                GMFCS = 0;
            elseif strcmp(a,'I')
                GMFCS = 1;
            elseif strcmp(a,'II')
                GMFCS = 2;
            elseif strcmp(a,'III')
                GMFCS = 3;
            elseif ismissing(a{1})
                GMFCS = 0;
            else
                GMFCS = a{1};
            end
            data.zoosystem.Anthro.GMFCS = GMFCS; % write to zoo
        end
    end
                    
    zsave(fl{i}, data)
end