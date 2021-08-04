function bmech_removebydescription(fld,desc)


% removes trials based on vicon nexus description column. 
%
% ARGUMENTS
% fld   ... folder to operate on
% desc ... string contained in description branch zoosyste,
%
% Created November 2012 by Philippe C. Dixon
%
%
% Updated Jan 8th 2013
% - compatible with zoosystem v1.1
% - second test to delete static trials missing data from ENF file
%
% Updated May 10th 2013
% - compatible with zoosystem v1.2
% 
% Updated Nov 12th 2014
% - use of 'lower' functions gets rid of inconsistency problem in capitalization

fl = engine('path',fld,'extension','zoo');

desc = lower(desc);

for j = 1:length(fl)
    
    data = zload(fl{j});
    
        if isin(lower(data.zoosystem.Header.Description),desc)
            delfile(fl{j})
            batchdisp(fl{j},['deleting ',desc,' trial'])
        end
       

        if isempty(desc) % this is to remove files with no desc
            
            if isempty(data.zoosystem.EnfInfo.description)
                delfile(fl{j})
                batchdisp(fl{j},'deleting other unidentified trials')
            end
        end
           
end