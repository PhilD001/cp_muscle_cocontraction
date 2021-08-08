function bmech_choose_side_R(fld)

% only keep trials that have at least 1 right gait cycle

fl = engine('fld', fld, 'extension', 'zoo');
missing_right = 0;
for i = 1:length(fl)
    data = zload(fl{i});
    if ~isfield(data.SACR_x.event, 'RFS2')
        disp(['missing RFS for ', fl{i}])
        delete(fl{i})
        missing_right = missing_right + 1;
    end
end
disp(['total trials missing RFS2 ', num2str(missing_right)])