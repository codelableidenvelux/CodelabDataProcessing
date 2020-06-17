function [time_min_rec sum_day app_day timezones] = getusageperh(Data,Timestamp_start, hoursbin)
% Usage [time_min_rec median_day] = getspeedperh(Data,Timestamp_start, hoursbin)
% Input: 
% Data -> Data in QA data extract format
% Timestamp_start -> The timestamp from which to begin computing the stat (all inputs floored to hh:00),
% hoursbin -> number of hours binned to obtain the statistics
% Output: 
% time_min_rec -> The lower edge of the time bin in UTC milliseconds 
% sum_day -> The number of touches in a given bin  
% timezones -> The timezones and their corresponding UTC milliseconds
% values 
%
% Default values: 
% Timestamp_start: first value in Data; 
% hoursbin: 1h

% Leiden University, Arko Ghosh, Jan 2020. Updated June 2020

if ~exist('hoursbin')
hoursbin = 1;
end


if ~exist('Timestamp_start')
Timestamp_start = [];
end


tmp_Type = [Data{1,1}.SUBJECT.tap.type];
App = [Data{1,1}.SUBJECT.tap.app];
log_tap = strcmp('tap', tmp_Type);
Timestamp = [Data{1,1}.SUBJECT.tap.timestamp]+(1000*60*60);
log_start = strcmp('start', tmp_Type);
log_stop = strcmp('stop', tmp_Type);
%log_tap = cellfun(@(s) searchtap(s,'whatsapp'), App);

% Get the time zones involved 
tz = Data{1, 1}.SUBJECT.tap.tz;
timezones(:,2) = string([tz(~cellfun('isempty',tz))]);
timezones(:,1) = Timestamp(~cellfun('isempty',tz));


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
parfor i = 1:(Days)
Time_min = Timestamp_start+((1000*60*60*hoursbin)*(i-1));
Time_max = Time_min+((1000*60*60*hoursbin));
Time_log = and(Time_min<Timestamp,Timestamp<Time_max);
Time_trim_tap = Timestamp(and(log_tap,Time_log));

%% make a smaller data set in the time period containing log_start/stop log_tap and timestamps 
Timestamp_trim = Timestamp(Time_log); 
Speed_trim = diff(Timestamp_trim)>70; 
log_start_trim = log_start(Time_log); 
log_stop_trim = log_stop(Time_log); 
log_tap_trim = log_tap(Time_log); 
App_trim = App(Time_log); 
App_trim = (App_trim(~cellfun('isempty',App_trim)));


App_trim = unique([cellfun(@cellstr,App_trim).']);

try
if size(App_trim,2) < 2
   if strcmp(App_trim{1,1},'undefined NULL')
   AppNum_trim = NaN;   
   else
   AppNum_trim = 1;     
   end
else
    AppNum_trim = size(App_trim,2);
end
catch
    AppNum_trim = NaN; 
end

%% estimate usage in terms of taps and App numbers

app_day(i) = AppNum_trim; 
sum_day(i) = sum(and(log_tap_trim', [Speed_trim' true])); 

time_min_rec(i) = Time_min;

%clear Median_stop Time_min *_trim
end
end
