function bmech_remove_negative_events_2(fld)

 

cd(fld)
fl = engine('path',fld,'extension','zoo');

 

for i = 1:length(fl)
    data = zload(fl{i});
    events =data.SACR.event;
    events_new =events;
    
    start_frame = data.zoosystem.Video.CURRENT_START_FRAME(1);
    end_frame = data.zoosystem.Video.CURRENT_END_FRAME(1);
    
    event_names  =fieldnames(events);
    
    % removing events outside the start and end frames
    for i=1: length(event_names)
        event_index = events.(event_names{i})(1,1);
        
        if event_index >end_frame || event_index<start_frame
            events_new = rmfield(events_new,event_names{i});
        end
        
    end
    
    % removing invalid leg
    event_names_new  =fieldnames(events_new);
    
    idx_LFS= find(cellfun(@(x) contains(x,'Left_FootStrike'), event_names_new));
    idx_LFO= find(cellfun(@(x) contains(x,'Left_FootOff'), event_names_new));
    
    
    idx_RFS= find(cellfun(@(x) contains(x,'Right_FootStrike'), event_names_new));
    idx_RFO= find(cellfun(@(x) contains(x,'Right_FootOff'), event_names_new));
    
    
    if length(idx_LFS)<2
        idx_to_remove = [idx_LFS;idx_LFO];
        for i =1: length(idx_to_remove)
            events_new = rmfield(events_new,event_names_new{idx_to_remove(i)});
        end
    elseif length(idx_RFS)<2
        idx_to_remove = [idx_RFS;idx_RFO];
        for i =1: length(idx_to_remove)
            events_new = rmfield(events_new,event_names_new{idx_to_remove(i)});
        end
    end
  start_frame
  end_frame
    events
   events_new 
end
end