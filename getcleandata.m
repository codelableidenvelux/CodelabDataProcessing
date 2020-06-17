function [Dataout removalstat] = getcleandata(Data)
% Goes through the data and removes any parts which do not have the app
% permission 
%
% usage> [Dataout rejectpercent] = getcleandata(Datain); 
% Datain Tap Data using gettapdata 
% Dataout in the some format 
% rejectpercent as the % data rejected due to permission loss 
% Based on the assumption that in absence of permission data is labelled "undefined NULL"
% Arko Ghosh, Leiden University, The Netherlands June 2020

% Get list of apps and identify undefined NULL
App = [Data{1,1}.SUBJECT.tap.app];
log_app = cellfun(@(s) searchtap(s,'undefined NULL'), App); 

% Remove segments which do not have App permission 
Dataout{1,1}.SUBJECT.tap = Data{1,1}.SUBJECT.tap(~log_app,1:5);

% summarize what was removed 
% Proportion of data removed. 
removalstat = [1-(length(Dataout{1,1}.SUBJECT.tap{:,1})./length(Data{1,1}.SUBJECT.tap{:,1}))]*100;

