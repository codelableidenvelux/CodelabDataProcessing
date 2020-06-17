function  [Sleep_UTC,Wake_UTC,Sin_drop,Raw_sleep] = getresttimesphone(Data, timewindow, ONOFF, plot_v, hou)
%%%%%% Usage : [Sleep_UTC,Wake_UTC,Sin_drop,Raw_sleep] = getresttimesphone(Data, timewindow, ONOFF, plot_v)
%%%%% uses the phone data obtained by using 'gettapdata' or from QuantActions 'extractTaps' to get the putative Sleep and Wake times, 
%%%%% relies on Casey Cox's cosinor function cosinor fits. Nelson et al. "Methods for Cosinor-Rhythmometry" Chronobiologica.1979. 
% INPUT
% Data: Phone data as obtained from gettapdata or Q
% timewindow: time in seconds when the rest/active decision is made def. 60
% ONOFF: [0/1]: 1 remove simple ON-OFF without tap values, def 1. 
% plot_v: [0/1]: 1 make plots, 0 turn off plots... 
% hou: Min number of hours gap to classify as sleep (default set at 2h); 
% OUTPUT 
% Sleep_UTC: Sleep time in UTC 
% Wake_UTC: Wake time in UTC
% Sin_drop: If the putative sleep time was detected in a possible sleep
% time determined according to Cosinor fit
% Cos. Cosinor determined times alone... (for specialised analysis and ver.
% only)
% FlagOrder: Check If Wake values come after sleep values!
% Raw_sleep = The raw activity values according to cole-kripke algorithm
% Figures showing the sleep times 
% When logical vectors are true, gap may not belong to the night 

% Author Arko Ghosh, Ledien University, 03/07/2018
% Further commented, 21/05/2019
% First discribed in npj Digital Medicine (2019)
% set defailt settings if needed 
if ~exist('timewindow')
    timewindow = 60; 
end

if ~exist('plot_v')
    plot_v = 0; 
end

if ~exist('ONOFF')
    ONOFF = 1; 
end

if ~exist('hou')
    hou = 2; % number of hours of a gap at the minimum to count it as sleep...  
end
% Merge the phone data 
tmp_merged = Data{1,1}.SUBJECT.tap;
if length(Data) > 1
for m = 2:length(Data)
tmp_b = Data{m,1}.SUBJECT.tap;    
tmp_merged = vertcat(tmp_merged,tmp_b);
end
end
try
tmp_pre_Data1 = sortrows(tmp_merged,'timestamp','ascend');% combine data from all of the devices and make a final Data file 
catch
tmp_pre_Data1 = tmp_merged; 
end
tmp_Data{1,1}.SUBJECT.tap = tmp_pre_Data1;% package it like any other data file
clear Data tmp_merged tmp_b 

% Now work on tmp_Data

type =[tmp_Data{1,1}.SUBJECT.tap.type];
timestamp =[tmp_Data{1,1}.SUBJECT.tap.timestamp];
log_tap = strcmp(type,'tap');

if ONOFF == 1
timestamp(~log_tap) = [];    
end

% Reduce data to one_min_windows
vartaps = zeros(1,floor(((timestamp(end))-timestamp(1))./(timewindow*1000))-1); 
timestaps = zeros(1,floor(((timestamp(end))-timestamp(1))./(timewindow*1000))-1); 
parfor t = 1:length(vartaps)
    
    
    s_t = timestamp(1)+((t-1)*timewindow*1000); 
    e_t = s_t+(timewindow*1000);
    vartaps(1,t) = sum(and(s_t<timestamp,timestamp<e_t));
    timestaps(1,t) = s_t; 
end

% Create Smark 
Smark(vartaps>=1) = 1; 
% Store the S values 
Raw_sleep = [timestaps' vartaps'];

% estimate active and less active points 
m_val = (60/timewindow)*60;% One min. 
Smark_avg = (movmean(Smark,m_val)>(1/40)); % if the values are less than 5% then surrounded by rest 

% estimate points where 
[aw bw]=find(Smark==1); % Active 
[ma na] = find(Smark_avg==1); 
Gap_list = na(diff(na)>(60*hou-1)); % gaps longer than 2 hours ( so impose assumption that sleep must be longer than 2 hours)
Gaps_listIdx = find((diff(na)>(60*hou-1)) == true); %find where the gaps are lcoated. 

% find going to sleep times 
parfor g = 1:length(Gap_list) 
    
    [mIdx mVal] = min(abs(Gap_list(g)-bw));
    Gap_start(g) = bw(mVal);
end

if exist('Gap_start')
    
Sleep_UTC = timestaps(Gap_start); 

% find wake-up times 
parfor gg = 1:length(Gap_list) 
    
    [mmIdx mmVal] = min(abs((na(Gaps_listIdx(gg)+1)-bw)));
    Gap_end(gg) = bw(mmVal);
end
Wake_UTC = timestaps(Gap_end); 

% estimate the overall circadian cycle and remove gaps which fall at 'high'
% activity 'times' in a 24 hour clock...  
ts = datenum(datetime(timestaps./1000, 'ConvertFrom', 'posixtime'));
[time_t sin_f y] = cosinor(ts,vartaps, 2*pi,.05);

sin_cut = prctile(sin_f,25) % Determine cut-off
log_sleep_sin = sin_f>sin_cut; % Find values less than the threshold, that is potential in active times 


% go through the gaps and check if more than 70% of the values are indeed
% at 'night', return trule if it is indeed at night 

D_pairs = min(length(Gap_start), length(Gap_end)); % number of sleep_wake pairs
parfor d = 1:D_pairs
    if nanmean(log_sleep_sin(Gap_start(d):Gap_end(d))) < 0.75 % at least 10% of the time in sin sleep 
        Sin_drop(d) = false; 
    else
        Sin_drop(d) = true;
    end
end

if plot_v == 1
figure('name', 'day night phone tappigraphy')
close all;
ptimes = datetime(timestaps./1000, 'ConvertFrom', 'posixtime');
stimes = datetime(Sleep_UTC(~Sin_drop)./1000, 'ConvertFrom', 'posixtime');
wtimes = datetime(Wake_UTC(~Sin_drop)./1000, 'ConvertFrom', 'posixtime');
plot(ptimes(1:length(Smark)), Smark); hold on
scatter(stimes,ones(1,length(stimes)),'r')
scatter(wtimes,ones(1,length(wtimes)),'g')
stimes = datetime(Sleep_UTC./1000, 'ConvertFrom', 'posixtime');
wtimes = datetime(Wake_UTC./1000, 'ConvertFrom', 'posixtime');
plot(ptimes(1:length(Smark)), log_sleep_sin(1:length(Smark))); hold on
scatter(stimes,ones(1,length(stimes)),'xr')
scatter(wtimes,ones(1,length(wtimes)),'xg')
% hgsave(h,'phone_sleep_fig');
% close (h)
end

if Gap_start(1)<Gap_end(1)
    FalgOrder = true;
else
    FalgOrder = false;
    display('The day night order may not be right')
end


% Get indices containing potential wake transitions  
[v WI] = risetime(double(log_sleep_sin));

% Get indices containing potential sleep transitions  
[v SI] = falltime(double(log_sleep_sin));

% find the closest values to SI and WI and then make sleep wake pairs 
parfor w = 1:length(WI)
[aw(w) aaw(w)] = min(abs(timestaps(floor(WI(w)))-timestaps(logical(Smark))));
end
temp_t = timestaps(logical(Smark)); 
Cos.Wake_UTC = (temp_t(aaw));


parfor w = 1:length(SI)
[as(w) aas(w)] = min(abs(timestaps(floor(SI(w)))-timestaps(~logical(Smark))));
end
temp_t = timestaps(~logical(Smark)); 
Cos.Sleep_UTC = (temp_t(aas));

else
disp('returning all NaN values')    
Sleep_UTC = NaN; 
Wake_UTC = NaN; 
Sin_drop = true; 
Cos ={};
FalgOrder = false; 
end


end 