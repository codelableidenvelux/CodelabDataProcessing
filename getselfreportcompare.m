function [SumRanges] = getselfreportcompare(Sample, Stimes, selfreporttimeUTCms,ranges)  
% [SumRanges ] = getselfreportcompare(Sample, Stimes, selfreporttimeUTCms,ranges) 
% output, SumRanges  is the sum of all activity in the defined ranges
% SumRanges has one extra value which is all previous sum/recording period
% 
% Sample, Hourly output as from getusageperh
% Stimes, the timestamps of the daily sample 
% Input,
% Sample - the binned values to used for stats
% Stimes - the timestamps of the binned values used for stats 
% selfreportimeUTCms - the timestamps of tbe self reports in UTCms 
% ranges = [-7 -1], for previous seven days and previous day, use only
% two 

%% Gather data and set the extractions as defined by 

TimeEnd = selfreporttimeUTCms; 
Time_1 = selfreporttimeUTCms+[ranges(1)*1000*60*60*24]; 
Time_2 = selfreporttimeUTCms+[ranges(2)*1000*60*60*24];

% Indices for Time_1 to TimeEnd 
Time_1_indices = and(Time_1<Stimes, Stimes<TimeEnd);
Time_2_indices = and(Time_2<Stimes, Stimes<TimeEnd);




%% Is there missing data? 
IdxMissing = or(isnan(sample),iszero(sample));

