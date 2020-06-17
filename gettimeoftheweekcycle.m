function [summarymed summaryiqr samplen] = gettimeoftheweekcycle(speed,times,timezone)
% uses the output of getspeedperh to gather the time of the week cycles. 
% Usage [v_median v_iqr raw] = gettimeoftheweekcycle(speed,times,timezone)
% Input> speed as in hourly parameter extracted using getspeed per h
% times in UTC milliseconds, timezone in matlab format as in 'Europe/Amsterdam'
% Output> central tendency (median) values per hour,iqr, samplen are the number
% of samples in the bin, first value is 0h, and last value is 23h

% Arko Ghosh Jan 2019
% Leiden University, The Netherlands 


pre_TimeD = datetime(times ./1000, 'convertfrom', 'posixtime', 'TimeZone', 'UTC');
pre_TimeD.TimeZone = timezone; 
dvec = day(pre_TimeD,'dayofweek');

% Now aggregate for each hour
for i = 1:7
    try
 summarymed(i) = nanmean(speed(dvec == i));
 samplen(i) = length(speed(dvec == i));
 summaryiqr(i) = iqr(speed(dvec == i));
    catch
 summarymed(i) = NaN;
 samplen(i) = NaN;
 summaryiqr(i) = 0;
    end
end

%summarymed(summarymed==0) = deal(NaN);
%summaryiqr(summaryiqr==0) = deal(NaN);

end