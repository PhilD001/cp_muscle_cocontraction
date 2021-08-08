function bmech_choose_side_L(fld)

% only keep trials that have at least 1 left gait cycle
% choose the side that has the most trials
fl = engine('fld', fld, 'extension', 'zoo');
missing_left = 0;
for i = 1:length(fl)
    data = zload(fl{i});
    if ~isfield(data.SACR_x.event, 'LFS2')
        disp(['missing LFS for ', fl{i}])
        delete(fl{i})
        missing_left = missing_left + 1;
    end
end
disp(['total trials missing LFS2 ', num2str(missing_left)])