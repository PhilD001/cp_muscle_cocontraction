function data = cocontraction_data_test(data,muscle_pairs,varargin)

% COCONTRACTION_DATA(data,muscle_pairs) computes co-contraction indices
%
% ARGUMENTS
%  data     ...   zoo struct
%  pairs    ...   Names of muscle pairs (cell array of strings).
% OPTIONAL ARGUMENTS
%  sides    ...   Prefix for limb side. Default = {'R','L'}
%  method     ...   Choice of algorithm to use.
%                   Default :'Rudolph',
%                   Other choices :'Falconer' and 'Lo2017'.
% RETURNS
%  data     ...  updated zoo struct
%
% NOTES
% - See cocontraction_line for co-contraction computational approach
%
% See also bmech_cocontraction, cocontraction_line

%if nargin==2
%     sides = {'R','L'};
% end

n= nargin; % number of input argument
method_exists =false;
events_exists =false;

switch n
    case 3
        sides = varargin{1};
        
    case 4
        sides = varargin{1};
        if ischar(varargin{2})
            method = varargin{2};
            method_exists =true;
        elseif iscell(varargin{2})
            evts =varargin{2};
            if length(evts)==2
                events_exists =true;
                evts_tag = [evts{1, 1} '_to_' evts{1, 2}];
                
                evt1 = evts{1, 1};
                evt2 = evts{1, 2};
                
                if ~isempty(findfield(data,evt1)) && ~isempty(findfield(data,evt2))
                    data_prt = partition_data(data,evt1,evt2);
                else
                    disp('Invalid Event(s) provided: Ignoring event(s) and considering complete signal')
                    events_exists =false;
                end
                
            else
                disp('Event(s) not provided: Ignoring event(s) and considering complete signal')
                events_exists =false;
            end
        end
        
    case 5
        sides = varargin{1};
        method = varargin{2};
        method_exists =true;
        evts =varargin{3};
        
        if length(evts)==2
            events_exists =true;
            evts_tag = [evts{1, 1} '_to_' evts{1, 2}];
            
            evt1 = evts{1, 1};
            evt2 = evts{1, 2};
            
            if ~isempty(findfield(data,evt1)) && ~isempty(findfield(data,evt2))
                data_prt = partition_data(data,evt1,evt2);
            else
                disp('Invalid Event(s) provided: Ignoring event(s) and considering complete signal')
                events_exists =false;
            end
            
        else
            disp('Event(s) not provided: Ignoring event(s) and considering complete signal')
            events_exists =false;
        end
        
    otherwise
        disp('Error: check input arguments/ not all input arguments have to provided')
end


for i = 1:length(muscle_pairs)
    muscles = strsplit(muscle_pairs{i},'_');
    
    for j = 1:length(sides)
        %         muscle1 = data.([sides{j},muscles{1}]).line;                       %       lines need to be uncommented in a normal work flow
        %         muscle2 = data.([sides{j},muscles{2}]).line;
        
        if ~isfield(data,[sides{j},muscles{1}])||~isfield(data,[sides{j},muscles{2}])
            error('Invaid muscle(s) / muscle(s) do not exist')
        end
        
        if ~isfield(data,[sides{j},muscles{1},'_normalized'])||~isfield(data,[sides{j},muscles{2},'_normalized'])
            error('EMG channel not normalized')
        end
        
        if events_exists
            muscle1 = data.([sides{j},muscles{1},'_normalized']).line;
            muscle2 = data.([sides{j},muscles{2},'_normalized']).line;
            
            muscle1_prt = data_prt.([sides{j},muscles{1},'_normalized']).line;
            muscle2_prt = data_prt.([sides{j},muscles{2},'_normalized']).line;
            
            ch_name = [sides{j},muscles{1},'_',muscles{2}];
            
        else
            muscle1 = data.([sides{j},muscles{1},'_normalized']).line;
            muscle2 = data.([sides{j},muscles{2},'_normalized']).line;
            
            ch_name = [sides{j},muscles{1},'_',muscles{2}];
            
        end
        
        if method_exists
            disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2},' using ',method])
            
            [r,r_val] = cocontraction_line_test(muscle1,muscle2,method);
            
            if ~isfield(data,[ch_name '_' method])
                data = addchannel_data(data,[ch_name '_' method],r,'Analog');
            else
                disp('channel already exists: updating channel')
                data.([ch_name '_' method]).line =r;
            end
            
            if r_val~=0 &&events_exists
                [~,r_val] = cocontraction_line_test(muscle1_prt,muscle2_prt,method);
                data.([ch_name '_' method]).event.(['co_contraction_value' '_from_' evts_tag])= [1,r_val,0];
            elseif r_val~=0
                data.([ch_name '_' method]).event.co_contraction_value= [1,r_val,0];
            end
            
        else
            disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2},' using Default:Rudolph'])
            
            r = cocontraction_line_test(muscle1,muscle2);
            if ~isfield(data,[ch_name '_Rudolph'])
                data = addchannel_data(data,[ch_name '_Rudolph'],r,'Analog');
            else
                disp('channel already exists: updating channel')
                data.([ch_name '_Rudolph']).line =r;
            end
            
        end
        
    end
    
end
end

