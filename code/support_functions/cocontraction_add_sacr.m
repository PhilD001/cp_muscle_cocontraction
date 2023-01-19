function cocontraction_add_sacr(fld)


cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'Adding SACR channel(s)');
    data = add_sacr_data(data);
    zsave(fl{i},data);
end


function data = add_sacr_data(data)

RPSI = data.RPSI.line;                                  % marker was not used
LPSI = data.LPSI.line;                                  % it can be computed
SACR = (RPSI+LPSI)/2;                                   % from RPSI and LPSI
data = addchannel_data(data,'SACR',SACR,'video');