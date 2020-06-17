function [tmp_Data] = gettapdatamac(var, working_dir)
% get data from a particular subject Data = gettapdata('123h8881991991822')
% in case there are more than one devices used by the id then see
% length(Data)
% [Data] = gettapdatamac(var, working_dir)
% usage var = participantID, working_dir = fullpath where the file is located
% if working_dir is not specified then user is forced to choose the dir
% all sub-directories are checked for matching participant ID
% Deletes any erronous values under 2015 and 7 years after data collection
% onset 
% Arko Ghosh, Leiden University, 22/02/2018 updated 11/06/2020, 15/06/2020

warning ('Friendly reminder: Data prior to 2015 and above 7 yrs from collection is not considered')
warning ('Friendly reminder: All sub-directories will be checked')

if ~exist('working_dir') 
    working_dir = uigetdir('Locate the phone data'); 
end

% Use genpath to collect file names 
to_gen = genpath(working_dir);
to_list = regexp([to_gen ';'],'(.*?);','tokens');
to_del = cellfun(@(x) isempty(x{1,1}), to_list);
to_list(to_del) = [];


% then to files 
file_names = [];
for to = 1:length(to_list)
if strcmp(to_list{1,to}{1,1}(end),':') % to accomidate mac users 
    to_list{1,to}{1,1}(end) = [];
end
file_names_tmp = dir(strcat(to_list{1,to}{1,1},'/','Subject_*'));
file_names = vertcat(file_names, file_names_tmp);  
end
file_names=file_names(~ismember({file_names.name},{'.','..'}));

k = 0; 
for i = 1:length(file_names)
    try
   d_file = strcat(file_names(i).folder,'\',file_names(i).name);
   load(d_file, 'participationId');
   if strcmp(participationId,var) == 1 
       k = k+1; 
   Data{k,1} = load(d_file, 'SUBJECT');   
   end
    catch
        display('perhaps file is occupied....')
    end
end

% Remove Data without 'SUBJECT'
for d = 1:length(Data)
rejd(d) = ~isfield(Data{d,1},'SUBJECT');
end
Data(rejd,:) = [];

% Remove unnecessary fields
for dt = 1:length(Data)
    var_list = Data{dt,1}.SUBJECT.tap.Properties.VariableNames;
    list_col = {'type','timestamp','tz','screen','app'};
    l = cellfun(@(c)strcmp(c,var_list),list_col,'UniformOutput',false);
    Exist_Column = logical(sum(vertcat(l{:}),1));
    Data{dt,1}.SUBJECT.tap = Data{dt,1}.SUBJECT.tap(:,Exist_Column); clear Exist_Column
end

% Merge the phone data 
if exist('Data','var') == 1
tmp_merged = Data{1,1}.SUBJECT.tap;
if isstruct(tmp_merged); tmp_merged= struct2table(tmp_merged); end
if length(Data) > 1
for m = 2:length(Data)
tmp_b = Data{m,1}.SUBJECT.tap;  
if isstruct(tmp_b); tmp_b= struct2table(tmp_b); end
tmp_merged = vertcat(tmp_merged,tmp_b);
end
end
try
tmp_pre_Data1 = sortrows(tmp_merged,'timestamp','ascend');% combine data from all of the devices and make a final Data file

catch
tmp_pre_Data1 = tmp_merged; 
end

% Delete any overlap
try
[ival iidx] = unique(tmp_pre_Data1.timestamp, 'last');
catch
[ival iidx] = unique([tmp_pre_Data1.timestamp],'last');    
end
try
tmp_pre_Data2 = tmp_pre_Data1(iidx,:);
catch
tmp_pre_Data2 = tmp_pre_Data1(:,iidx);
end
% Delete any values below 1st Jan 2015 
Threshold = posixtime(datetime('01/01/2015','inputformat','dd/MM/yyyy')).*1000; clear tmp_timestamp
% datetime({'01/01/2015'},'convertfrom','datestr', 'format','dd/MM/yyyy')
try
tmp_timestamp = (tmp_pre_Data2.timestamp)<Threshold;
catch
tmp_timestamp = ([tmp_pre_Data2.timestamp])<Threshold;    
end
tmp_pre_Data2(tmp_timestamp,:) = []; clear tmp_timestamp

% Delete any date 7 years away from the min value 
Threshold = min([tmp_pre_Data2.timestamp])+(1000*60*60*24*365*7); 
% datetime({'01/01/2015'},'convertfrom','datestr', 'format','dd/MM/yyyy')
try
tmp_timestamp = (tmp_pre_Data2.timestamp)>Threshold;
catch
tmp_timestamp = ([tmp_pre_Data2.timestamp])>Threshold;    
end
tmp_pre_Data2(tmp_timestamp,:) = [];

tmp_Data{1,1}.SUBJECT.tap = tmp_pre_Data2;% package it like any other data file
clear Data tmp_merged tmp_b tmp_pre_Data1 tmp_pre_Data2

if ~exist('tmp_Data')
   tmp_Data = {};
   display('no phone data found for this subject code')
end
else
   tmp_Data = {};
   display('no phone data found for this subject code')

end

end