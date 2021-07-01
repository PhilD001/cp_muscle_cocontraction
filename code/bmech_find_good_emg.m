function bmech_find_good_emg(fld)

% ch={'LVM';'LTibAnt';'LGM';'LHam';'LRF';'LGLUTMED';'RVM';'RTibAnt';'RGM';'RHam';'RRF';'RGLUTMED',};
% folder 3074_1 was empty from beginning
fl =engine('path',fld,'ext','.zoo');
data2 =struct();
figure;
hold on;
s1=subplot(2,6,1);
s2=subplot(2,6,2);
s3=subplot(2,6,3); 
s4=subplot(2,6,4);
s5=subplot(2,6,5);
s6=subplot(2,6,6);
s7=subplot(2,6,7);
s8=subplot(2,6,8);
s9=subplot(2,6,9);
s10=subplot(2,6,10);
s11=subplot(2,6,11);
s12=subplot(2,6,12);
for i=1:length(fl)
data = zload(fl{i});
data2.(['T' num2str(i)])=data;
 
 subplot(s1);plot(data.LVM_filthigh_filtlow .line); title('LVM');hold on;
 subplot(s2);plot(data.LTibAnt_filthigh_filtlow .line); title('LTibAnt');hold on; 
 subplot(s3);plot(data.LGM_filthigh_filtlow .line); title('LGM');hold on;
 subplot(s4);plot(data.LHam_filthigh_filtlow .line);title('LHam');hold on; 
 subplot(s5);plot(data.LRF_filthigh_filtlow .line); title('LRF');hold on;
 subplot(s6);plot(data.LGLUTMED_filthigh_filtlow .line); title('LGLUTMED');hold on;
 subplot(s7);plot(data.RVM_filthigh_filtlow .line);title('RVM');hold on;  
 subplot(s8);plot(data.RTibAnt_filthigh_filtlow .line); title('RTibAnt');hold on; 
 subplot(s9);plot(data.RGM_filthigh_filtlow .line);title('RGM');hold on;  
 subplot(s10);plot(data.RHam_filthigh_filtlow .line);title('RHam');hold on;  
 subplot(s11);plot(data.RRF_filthigh_filtlow .line);title('RRF');hold on; 
 subplot(s12);plot(data.RGLUTMED_filthigh_filtlow .line);title('RGLUTMED');hold on; 
end