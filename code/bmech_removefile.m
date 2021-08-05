function bmech_removefile(fld,files)

% BMECH_REMOVEFile(fld,fl) batch process removal of trials from subfolder
%
% ARGUMENTS
%  fld      ...  Folder to batch process (string) 
%  files     ...  trials to remove (cell array of strings)


% Error checking
%
if ~iscell(files)
   files= {files};
end

s = filesep;                                            % get slash direction based on computer 
indx = strfind(files{1},s);

if isempty(indx)
    
    if ispc
        files{1} = strrep(files{1},'/',s);
    else
        files{1} = strrep(files{1},'\',s);
    end
end

% Remove files data 

for i = 1:length(files)
  
    fl = engine('fld',fld,'search file',files{i});
    disp(['file ',' is an outlier ', files{i}])
     del=true;
     
     if del
        batchdisp(files{i},'deleting trial');
        delfile(fl);
        
     end
        
end
    
   
end
    
%     sfld_all = subdir(fld)';
    
       
    
