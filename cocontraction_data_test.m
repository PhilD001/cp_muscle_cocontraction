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
switch n
    case 3
        sides = varargin{1};
        method_exists =false;
        
    case 4
        sides = varargin{1};
        method = varargin{2};
        method_exists =true;
        
    otherwise
        disp('Error: check input arguments/ not all input arguments have to provided')
end

for i = 1:length(muscle_pairs)
    muscles = strsplit(muscle_pairs{i},'_');
    
    for j = 1:length(sides)
        %         muscle1 = data.([sides{j},muscles{1}]).line;                       %       lines need to be uncommented in a normal work flow
        %         muscle2 = data.([sides{j},muscles{2}]).line;
        
        muscle1 = data.([sides{j},muscles{1},'_normalized']).line;               %       lines need to be commented out. In a normal work flow the
        muscle2 = data.([sides{j},muscles{2},'_normalized']).line;               %       muscles will be already replaced with data that's normalized
        
        if method_exists
            disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2},' using ',method])
            
            [r,r_val] = cocontraction_line_test(muscle1,muscle2,method);
            data = addchannel_data(data,[sides{j},muscles{1},'_',muscles{2}],r,'Analog');
            if r_val~=0
                data.([sides{j},muscles{1},'_',muscles{2}]).event.co_contraction_value_entire_gait= r_val;
            end
        else
            disp(['computing co-contraction for muscles ',sides{j},muscles{1},' and ',sides{j},muscles{2},' using Default:Rudolph'])
            
            r = cocontraction_line_test(muscle1,muscle2);
            data = addchannel_data(data,[sides{j},muscles{1},'_',muscles{2}],r,'Analog');
            
        end
        
    end
    
end
end

