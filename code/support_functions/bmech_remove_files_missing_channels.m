function bmech_remove_files_missing_channels(fld, chns)

% BMECH_REMOVE_FILES_MISSING_CHANNELS removes any files in fld that do not
% contain all channels listed in chns
%
% ARGUMENTS
% fld   ... str, path to folder to operate on.
% chns  ... cell array of strings. Channels to check

if nargin == 0
    fld = uigetfolder;
    chns = {'LVM','LTibAnt', 'LGM', 'LHam', 'RVM', 'RTibAnt','RGM','RHam'};
end


fl = engine('fld',fld,'extension','zoo');
n_del_files = 0;
for i = 1:length(fl)
    disp(' ')
    batchdisp(fl{i}, 'checking channels')
    data = zload(fl{i});
    [~, fname, ext] = fileparts(fl{i});
    
    del = false;
    for j = 1:length(chns)
        if ~isfield(data, chns{j})
            disp(['file ', fname, ext, ' does not contain channel ', chns{j}])
            del=true;
        end
    end
    
    if del
        disp('deleting file ...')
        delete(fl{i})
        n_del_files = n_del_files + 1;

    end
end


disp(' ')
disp([num2str(n_del_files), ' files deleted'])







