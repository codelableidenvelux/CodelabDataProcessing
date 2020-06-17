function [time_min_rec tapbin timebin] = getsessionusagperh(Data,Timestamp_start, hoursbin,Th)
% Usage [time_min_rec tapbin timebin] = getsessionusagperh(Data,Timestamp_start, hoursbin,Th)
% INPUT
% Data -> Data in QuantActions data extract format
% Timestamp_start -> The timestamp from which to begin computing the statistics,
% leave blank [] if starting from recording onset. 
% hoursbin -> number of hours binned to obtain the statistics. def value 1
% h. 
% Th -> number of minimum taps needed to compute the statistics. def value
% 1
% OUTPUT 
% time_min_rec -> The lower edge of the time bin in UTC milliseconds
% tapbin -> Number of touches (sum) in the bin 
% timebin -> Amount of time (sum) in ms in the bin 
%
% Note, A 50 ms threshold is used to remove consecutive touches as in swipes 
% Arko Ghosh, Leiden University, June 2020 


if ~exist('hoursbin')
hoursbin = 1;
end

if ~exist('Th')
Th = 1;
end


if ~exist('Timestamp_start')
Timestamp_start = [];
end

% Gather the data and extract tap, start, stop values 
tmp_Type = {Data{1,1}.SUBJECT.tap.type};
App = {Data{1,1}.SUBJECT.tap.app};
Timestamp = [Data{1,1}.SUBJECT.tap.timestamp]+(1000*60*60);

log_tap = strcmp('tap', tmp_Type);
log_start = strcmp('start', tmp_Type);
log_stop = strcmp('stop', tmp_Type);
if length(log_tap)==1
    log_tap = strcmp('tap', tmp_Type{:,1});
    log_start = strcmp('start', tmp_Type{:,1});
    log_stop = strcmp('stop', tmp_Type{:,1});
end
%log_tap = cellfun(@(s) searchtap(s,'whatsapp'), App);

Timestamp_tmp = datevec(datetime(Timestamp(1)./1000, 'Convertfrom', 'posixtime'));
if isempty(Timestamp_start)
Timestamp_start =(floor(Timestamp(1)./(1000*60*60))).*(1000*60*60);
else
Timestamp_start =(floor(Timestamp_start(1)./(1000*60*60))).*(1000*60*60);
end
clear Data; 
%% Estimate the number of time periods depending on hoursbin, could be days
Days = floor((Timestamp(end-200)-Timestamp_start)./(1000*60*60*hoursbin)); % introduced -10 in case of odd ending

%% loop over the number of period 
for i = 1:(Days)
Time_min = Timestamp_start+((1000*60*60*hoursbin)*(i-1));
Time_max = Time_min+((1000*60*60*hoursbin));
Time_log = and(Time_min<Timestamp,Timestamp<Time_max);
Time_trim_tap = Timestamp(and(log_tap,Time_log));
try
%% make a smaller data set in the time period containing log_start/stop log_tap and timestamps 
Timestamp_trim = Timestamp(Time_log); 
log_start_trim = log_start(Time_log); 
log_stop_trim = log_stop(Time_log); 
log_tap_trim = log_tap(Time_log); 

%% estimate number of start_stop pairs 
Idx_start = find(log_start_trim==logical(1)); 
Idx_stop = find(log_stop_trim==logical(1));

%% now go through each start event to find the time per session(valtime), and number of touches per session(valtouch) 
valtime = []; valtouch = []; cattime = []; cattouch = []; 
parfor s = 1:length(Idx_start); % check upto 1 but last value 
    Idx_stop_new = min(Idx_stop(Idx_stop>Idx_start(s))); % mark the stop event   
    if ~isempty(Idx_stop_new)% if stop event exists within borders 
    valtime(s) = Timestamp_trim(Idx_stop_new)-Timestamp_trim(Idx_start(s)); % estimate the time of the session 
   
    T_start_stop = Timestamp_trim(Idx_start(s):Idx_stop_new); %Timestamps inbetween start and stop 
    log_tap_micro_trim = log_tap_trim(Idx_start(s):Idx_stop_new); % Tap events inbetween start and stop 
    if sum(log_tap_micro_trim) == 0
        valtouch(s) = 0; % number of touches in a session 
    elseif sum(log_tap_micro_trim) == 1
        valtouch(s) = 1; % number of touches in a session 
    else 
        diff_T = diff(T_start_stop(log_tap_micro_trim)); diff_T(diff_T<50) = [];
        valtouch(s) = length(diff_T)+1; % number of touches in a session 
    end
    

  % threshold to remove sessions according to the condition set in Th 
    if valtouch(s)>Th
    cattouch = vertcat(cattouch, valtouch(s)); 
    cattime = vertcat(cattime, valtime(s));
    end
    end
end



%% Accumilate the within bin values across the sessions 
tapbin(i) = nansum(cattouch); 
timebin(i) = nansum(cattime); 
time_min_rec(i) = Time_min; 
catch
time_min_rec(i) = NaN; 
tapbin(i) = NaN; 
timebin(i) = NaN; 


end
%clear val* 
end

