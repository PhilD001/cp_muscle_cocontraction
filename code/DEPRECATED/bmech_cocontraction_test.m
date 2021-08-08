function bmech_cocontraction_test(fld,pairs,varargin)

% BMECH_COCONTRACTION computes co-contraction index for muscle pairs
%
% ARGUMENTS
%  fld         ...          folder to operate on
%  pairs         ...          Names of muscle pairs (cell array of strings seperated by '-').
%                               Example = {'L_TibAnt-L_GM','L_RF-L_Ham'} computes
%                               co-contaction for L_TibAnt and L_GM, and L_RF
%                               and L_Ham muscle pairs.
%
%*NEW* OPTIONAL AGRUMENT
% 'method'  ...         Choice of algorithm to use.
%                               Default :'Rudolph'
%                               Other choices :'Falconer' and 'Lo2017'.
% 'events'   ...           pair of global events as cell array of strings (only for Lo2017 method). 
%                               Estimates  percent co-contraction btw the events (value stored in event). 
%                               Note:                                                            
%                               Ignores events for other methods and computes co-contation line for entire data
%                               Example = {'Left_FootStrike1','Left_FootStrike2'}
%
% NOTES
% - See cocontraction_line for co-contraction computational approach
%  Example:
%  bmech_cocontraction_test(fld,{'L_Tib_Ant-L_Gast','L_Rect-L_Hams'},'method', 'Lo2017', 'events', {'LFS1','LFS2'})

% See also cocontraction_data, cocontraction_line

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');

method_exists = false;
events_exists = false;
evts ={''};


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
        data = cocontraction_data_test(data,pairs,method,evts);
    elseif method_exists
        data = cocontraction_data_test(data,pairs,method);
    elseif events_exists
        data = cocontraction_data_test(data,pairs,evts);
    else
        data = cocontraction_data_test(data,pairs);
    end
    
    zsave(fl{i},data);
end