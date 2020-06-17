function [summarymed summaryiqr samplen] = gettimeofthedaycycle(speed,times,timezone)
% uses the output of getspeedperh to gather the time of the day cycles. 
% Usage [v_median v_iqr raw samplen] = gettimeofthedaycycle(speed,times,timezone)
% Input> 
% speed as in hourly parameter extracted using getspeed per h
% times as in UTC milliseconds, 
% timezone in matlab format as in 'Europe/Amsterdam'
% Output> central tendency (mean) values per hour,iqr, samplen are the number
% of samples in the bin, first value is 0h, and last value is 23h

% Arko Ghosh Jan 2019, updated Jan 2020
% Leiden University, The Netherlands 

pre_TimeD = datetime(times ./1000, 'convertfrom', 'posixtime', 'TimeZone', 'UTC');
pre_TimeD.TimeZone = timezone; 

dvec = datevec(pre_TimeD);
speed(isinf(speed))= deal(NaN); 
% Now aggregate for each hour
for i = 0:23
    try
 summarymed(i+1) = nanmean(speed(dvec(:,4) == i));
 samplen(i+1) = length(speed(dvec(:,4) == i));
 summaryiqr(i+1) = iqr(speed(dvec(:,4) == i));
    catch
 summarymed(i+1) = NaN;
 samplen(i+1) = NaN;
 summaryiqr(i+1) = 0;
    end
end

%summarymed(summarymed==0) = deal(NaN);
%summaryiqr(summaryiqr==0) = deal(NaN);

end