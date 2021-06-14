function bmech_cocontraction_test(fld,pairs,varargin)

% BMECH_COCONTRACTION computes co-contraction index for muscle pairs
%
% ARGUMENTS
%  fld         ...   folder to operate on
%  pairs       ...   Names of muscle pairs (cell array of strings).
%                    Default = {'VM_MG','VM_MH','VL_LG','VL_LH'}
%*NEW* OPTIONAL AGRUMENT
%  sides    ...   Prefix for limb side. Default = {'R','L'}
%  method         ...   Choice of algorithm to use.
%                       Default :'Rudolph'
%                       Other choices :'Falconer' and 'Lo2017'.
% NOTES
% - See cocontraction_line for co-contraction computational approach
%
% See also cocontraction_data, cocontraction_line

% Batch process
%
cd(fld)
fl = engine('path',fld,'extension','zoo');


if nargin==2
    method_exists = false;
    sides = {'R','L'};
    
elseif nargin==3
    if ischar(varargin{1})
        method_exists = true;
        sides = {'R','L'};
        method = varargin{1};
    elseif iscell(varargin{1})
        method_exists = false;
        sides = varargin{1};
    end
    
elseif nargin==4
    method_exists = true;
    sides = varargin{1};
    method = varargin{2};
end


for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing co-contraction');
    
    if method_exists
        data = cocontraction_data_test(data,pairs,sides,method);
    else
        data = cocontraction_data_test(data,pairs,sides);
    end
    
    zsave(fl{i},data);
end