function [Data_t] = getapptransitionpoints(Data)
% Makes a new dataset only containing transition taps along with start stop
% taps. Also removes 'undefined' values so as to disregard that from
% analysis
% Usage [Data_t] = getapptransitionpoints(Data)
% Data_t is the transition selected data 
% Input must be in QA Data format. 
% Arko Ghosh, Leiden University, 2019. Edited June 2020

% Identify all transition points using App column 

log_transition = logical(zeros(length(Data{1,1}.SUBJECT.tap.app),1));  

for i = 2:length(Data{1,1}.SUBJECT.tap.app)
    if ~or(isempty(Data{1,1}.SUBJECT.tap.app{i-1}),isempty(Data{1,1}.SUBJECT.tap.app{i}))
    log_transition(i,1) = ~strcmp(Data{1,1}.SUBJECT.tap.app{i-1},Data{1,1}.SUBJECT.tap.app{i});
    end
end

tmp_Type = Data{1,1}.SUBJECT.tap.type;
log_start = strcmp('start', tmp_Type);
log_stop = strcmp('stop', tmp_Type);

final_log = or(or(log_start,log_stop),log_transition);

% Now create a new data with only transition data and start stop data 
Data_t{1,1}.SUBJECT.tap = Data{1,1}.SUBJECT.tap(final_log,:);  
end
