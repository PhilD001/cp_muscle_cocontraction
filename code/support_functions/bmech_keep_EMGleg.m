function bmech_keep_EMGleg(fld)
fld=uigetfolder;
cd(fld)

[~,subjects] = extract_filestruct(fld);

for i = 1:length(subjects)
    fl = engine('fld',fld,'extension','zoo', 'search path', subjects{i});
    data = zload(fl{1});
       if isfield(data.zoosystem.Header,'R')
         disp(['removing subject ', subjects{i},' because ', EMG_Leg, ' is ',not correct])
           bmech_removefolder(fld,subjects{i});
        end
end