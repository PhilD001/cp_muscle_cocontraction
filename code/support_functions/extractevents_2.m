function r = extractevents_2(fld,cons,subjects,ch,evt)

% R = EXTRACTEVENTS(fld,cons,subjects,ch,evt) extracts event data from zoo file
%
% ARGUMENTS
%  fld         ...    Folder to operate on as string
%  cons        ...    List of conditions (cell array of strings)
%  subjects    ...    List of subject names (cell array of strings)
%  ch          ...    Channel to analyse (string)
%  evt         ...    Event to analyse (string)
%
% RETURNS
%  r           ...    Event data by condition (structured array)

% Revision History
%
% Updated November 2017 by Philippe C. Dixon
% - improved output display
% updated to check negative values for MCo

if ~iscell(cons)
    cons = {cons};
end

r = struct;
s = filesep;                                                    % determines slash direction
file= {};

for i = 1:length(cons)
    estk={};
    file =   engine('path',[fld,s,cons{i},s],'extension','zoo');
    
    for j = 1:length(file)
        % disp(['loading files for ',subjects{j},' ',cons{i}])
        
        if ~isempty(file)
            data = zload(file{j});                              % load zoo file
            evtval = findfield(data.(ch),evt);                  % searches for local event
            
            if isempty(evtval)                                  % searches for global event
                evtval = findfield(data,evt);                   % if local event is not
                evtval(2) = data.(ch).line(evtval(1));          % found
            end
            
            if evtval(2)==999                                   % check for outlier
                evtval(2) = NaN;
            end
            filename=extractBetween(file{j},[cons{i},'\'],'.zoo');
            estk(j,1) = filename;                                % add to event stk
            estk(j,2) = {evtval};
        end
        
    end
    r= estk;                                          % save to struct
end




