function logv = searchtap(where_to_search, str_to_search, rough)
% logv = searchtap(where_to_search, str_to_search, rough)
% rough is true if and only if an exact match is needed... 
% can be used in cell fun
% ispresent = cellfun(@(s) searchtap(s,'android'), SUBJECT.tap.app);
% is the cell empty ? Note, empty cell get a 'false'
if isempty(where_to_search) == 1
    logv = logical(0); m = logical(1); 
elseif isnumeric(where_to_search) == 1
    logv = logical(0); m = logical(1); 
else
    m = logical(0); 
end
   
if ~exist('rough')
   rough = false;
end


if m == logical(0)
    try
    where_to_search_str = (where_to_search{1,1});
    catch
    where_to_search_str = where_to_search;
    end
    if ~rough
    logv =  ~isempty(regexp(where_to_search_str,str_to_search, 'match','ignorecase'));
    else
    tmp_r =    regexp(where_to_search_str,str_to_search, 'match','ignorecase');
    try
    logv = strcmp(where_to_search_str,tmp_r{1,1});
    catch
        logv = false; 
    end
    clear tmp_r; 
    end
end

end