function [pxx,pxxci] = getlombperiods(samples,stimes, samplerate,fvec)
% Usage [pxx,pxxci] = getlombperiods(samples,stimes, samplerate,fvec)
% Runs plomb to derive the Spectral Density Estimate of The Signal
% Can contain NaN values in samples and stimes
% samples:  containing  measurement values
% stimes; times of the sample 
% samplerate: in Hz so 01/60 for 1 sample per 60 seconds... 
% if using get**** functions with utc ms outout then samplerate = 1/(nanmedian(diff('sampled_timestamps')./1000)); 
% fvec: frequency vectors of interest in days as in [0.5:.1:7], to assess half
% day to 7 day rhythms in 0.1 day steps  , typical usage fvec =
% [0.05:.001:12];


% Number of samples 
N = length(samples);

% Convert fvec to frvec ie cycles per day to cycles per second
frvec = fvec./(60*60*24*1000);

% get plomb algorithm to work on fvec
[pxx,~] = plomb(samples,stimes,frvec, 'normalized');
[~,~,pxxci] = plomb(samples,samplerate,'normalized','pd',0.95);
plot(fvec,(pxx))
xlabel('Frequency (Cycles per day)') 
ylabel('Normalised power') 
end