function bmech_cocontraction_test(fld,pairs,varargin)

% BMECH_COCONTRACTION computes co-contraction index for muscle pairs
%
% ARGUMENTS
%  fld         ...   folder to operate on
%  pairs       ...   Names of muscle pairs (cell array of strings).
%                      Prefix side L or R at begining of string input.
%                      Example = {'LTibAnt_GM','LRF_Ham'} computes
%                      co-contaction for LTibAnt and LGM, and LRF
%                      and LHam muscle pairs.
%*NEW* OPTIONAL AGRUMENT
%  'method'         ...   Choice of algorithm to use.
%                       Default :'Rudolph'
%                       Other choices :'Falconer' and 'Lo2017'.
% 'events'   ...   pair of global events as cell array of strings.
%                 Exampl = {'Left_FootStrike1','Left_FootStrike2'}
% NOTES
% - See cocontraction_line for co-contraction computational approach
%
% See also cocontraction_data, cocontraction_line

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

method_exists = false;
events_exists = false;
evts ={''};

sides = {};
for i=1: length(pairs)
    side = pairs{1,i}(1);
    sides{1,i} =side;
    
    pairs{1,i} = pairs{1,i}(2:end);
end
sides = unique(sides);

if nargin <2
    error('Check Input')
elseif nargin ==3
    error('Check Input')
elseif nargin>3
    for i = 1:2:nargin-2
        
        switch varargin{i}
            
            case 'method'
                method = varargin{i+1};
                method_exists = true;
                
            case 'events'
                evts = varargin{i+1};
                events_exists =true;
                
        end
    end
end


for i = 1:length(fl)
    data = zload(fl{i});
    
    batchdisp(fl{i},'computing co-contraction');
    
    if method_exists&&events_exists
        data = cocontraction_data_test(data,pairs,sides,method,evts);
    elseif method_exists
        data = cocontraction_data_test(data,pairs,sides,method);
    elseif events_exists
        data = cocontraction_data_test(data,pairs,sides,evts);
    else
        data = cocontraction_data_test(data,pairs,sides);
    end
    
    zsave(fl{i},data);
end