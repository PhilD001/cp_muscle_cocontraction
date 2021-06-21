function bmech_remove_negative_events(fld)

cd(fld)
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
     events =fieldnames(data.SACR.event); 
         for j=1:length(events)
             if isfield(data.SACR.event,'Left_FootStrike1')&& data.SACR.event.Left_FootStrike1(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Left_FootStrike1');
           batchdisp('deleting negative Left_FootStrike1');
            elseif isfield(data.SACR.event,'Left_FootStrike2')&& data.SACR.event.Left_FootStrike2(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Left_FootStrike2');
           batchdisp('deleting negative Left_FootStrike2');
           elseif isfield(data.SACR.event,'Right_FootStrike1')&& data.SACR.event.Right_FootStrike1(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Right_FootStrike1');
           batchdisp('deleting negative Right_FootStrike1');
           elseif isfield(data.SACR.event,'Right_FootStrike2')&& data.SACR.event.Right_FootStrike2(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Right_FootStrike2');
           batchdisp('deleting negative Right_FootStrike2');
           elseif isfield(data.SACR.event,'Left_FootOff1')&& data.SACR.event.Left_FootOff1(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Left_FootOff1');
           batchdisp('deleting negative Left_FootOff1');
           elseif isfield(data.SACR.event,'Left_FootOff2')&& data.SACR.event.Left_FootOff2(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Left_FootOff2');
           batchdisp('deleting negative Left_FootOff2');
           elseif isfield(data.SACR.event,'Right_FootOff1')&& data.SACR.event.Right_FootOff1(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Right_FootOff1');
           batchdisp('deleting negative Right_FootOff1');
           elseif isfield(data.SACR.event,'Right_FootOff2')&& data.SACR.event.Right_FootOff2(1) <= 0
           data.SACR.event = rmfield(data.SACR.event,'Right_FootOff2');
           batchdisp('deleting negative Right_FootOff2');
            else
           batchdisp('NO negative event');      
                 
             end
            zsave(fl{i},data);
        end
end
end