function bmech_emgprocess(fld,ch,filt_high,filt_low)

% BMECH_EMGPROCES(fld,ch) will perform basic processing for EMG signals
%  1- High pass filter @ 20Hz
%  2- Low-pass filter  @ 500 Hz
%  3 - Rectify signal
%  4 - Root mean square
%
% ARGUMENTSw
%  fld    ... folder to operate on
%  ch     ... name of emg channels to process (cel array of strings)
%
% NOTES
% - Data should be collected at 1000 Hz minimum (Nyquist problem)


% Revision History
% Created at KU Leuven
% Last updated by Philippe C. Dixon Feb 2017
% - clean up, more comments

cd(fld)

% extract all non static files
fl = engine('path',fld,'extension','zoo');
% fl_tmp = engine('path',fld,'extension','zoo','search file','Cal');
% fl = setdiff(fl_all,fl_tmp);

for i = 1:length(fl)    
    batchdisplay(fl{i},'emg process')
    data = zload(fl{i});
    data = emgprocess_data(data,ch,filt_high,filt_low);
    zsave(fl{i},data);
end


function data = emgprocess_data(data,emg_ch,filt_high,filt_low)


SR=data.zoosystem.Analog.Freq;                   % EMG sampling rate                                         % sample frequency

if SR < 1000
    error('sampling rate must be at least 1000 Hz')
end

% Dc offset (removing zero drift)
for i = 1:length(emg_ch)
    r = data.(emg_ch{i}).line;                 
    DC_r = detrend(r);                            
    data = addchannel_data(data,[emg_ch{i},'_DC'],DC_r,'Analog');
end

% filter high pass 
fnyq = SR/2;                                       % Nyquist frequency
fcut = filt_high;                                  % cutoff frequency
nord = 4;                                          % Filter order
[B,A]=butter(nord,fcut/fnyq,'high');

for i = 1:length(emg_ch)
    DC_r = data.([emg_ch{i},'_DC']).line;                 
    filt_high = filtfilt(B,A,DC_r);                            
    data = addchannel_data(data,[emg_ch{i},'_filthigh'],filt_high,'Analog');
end

   
% filter low pass

fcut = filt_low;                                        % cutoff
nord = 4;
[B,A]=butter(nord,fcut/fnyq,'low');
	
for i = 1:length(emg_ch)
    filt_high = data.([emg_ch{i},'_filthigh']).line;
    filt_high_low = filtfilt(B,A,filt_high);
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow'],filt_high_low,'Analog');
end

%notch filter   
fcut=60;                   %power-line noise
fnyq = SR/2; 
w0=fcut/fnyq;
bw=w0/35;
[B,A]=iirnotch(w0,bw);

for i = 1:length(emg_ch)
    filt_high = data.([emg_ch{i},'_filthigh_filtlow']).line;
    filt_high_low = filtfilt(B,A,filt_high);
    data = addchannel_data(data,[emg_ch{i},'_filthigh_filtlow_notch'],filt_high_low,'Analog');
end


%rectify + RMS
span=50;
window = ones(span,1)/span;

for i = 1:length(emg_ch)
    filt_high_low = data.([emg_ch{i},'_filthigh_filtlow_notch']).line;
    rect_r = filt_high_low.*filt_high_low;                      
    mean_temp=convn(rect_r,window,'same');
    RMS_r=sqrt(mean_temp);
    data = addchannel_data(data,[emg_ch{i},'_rect_RMS'],RMS_r,'Analog');
        
end

%max normalization
for i = 1:length(emg_ch)
   filt_high_low = data.([emg_ch{i},'_rect_RMS']).line;
   normalized_data=(RMS_r)/max(RMS_r);
   data = addchannel_data(data,[emg_ch{i},'_rect_RMS_normalized'], normalized_data,'Analog');
        
end

  