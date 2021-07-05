function bmech_remove_no_mft(fld)
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