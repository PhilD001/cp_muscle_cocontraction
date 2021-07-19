function[data2]= bmech_find_good_emg(fld)

fld=uigetfolder;
fl =engine('path',fld,'ext','.zoo');
data2 =struct();
figure;
hold on;
s1=subplot(2,6,1);
s2=subplot(2,6,2);
s3=subplot(2,6,3); 
s4=subplot(2,6,4);
% s5=subplot(2,6,5);
% s6=subplot(2,6,6);
% s7=subplot(2,6,7);
% s8=subplot(2,6,8);

for i=1:length(fl)
data = zload(fl{i});
fl{i}
data2.(['T' num2str(i)])=data;
 

 subplot(s1);plot(data.LTibAnt_normalized.line); title('LTibAnt');hold on; 
 subplot(s2);plot(data.LGM_normalized.line); title('LGM');hold on;
 subplot(s3);plot(data.LHam_normalized.line);title('LHam');hold on; 
 subplot(s4);plot(data.LRF_normalized.line); title('LRF');hold on;
%  subplot(s5);plot(data.RTibAnt_normalized.line); title('RTibAnt');hold on; 
%  subplot(s6);plot(data.RGM_normalized.line);title('RGM');hold on;  
%  subplot(s7);plot(data.RHam_normalized.line);title('RHam');hold on;  
%  subplot(s8);plot(data.RRF_normalized.line);title('RRF');hold on; 

 end