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


for i=1:length(fl)
data = zload(fl{i});
fl{i};
data2.(['T' num2str(i)])=data;
 

 subplot(s1);plot(data.L_Tib_Ant_normalized.line); title('L_Tib_Ant');hold on; 
 subplot(s2);plot(data.L_Gast_normalized.line); title('L_Gast');hold on;
 subplot(s3);plot(data.L_Hams_normalized.line);title('L_Hams');hold on; 
 subplot(s4);plot(data.L_Rect_normalized.line); title('L_Rect');hold on;


 end