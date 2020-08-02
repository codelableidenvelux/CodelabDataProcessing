function [z, idxbreak] = getundrifteddata(y,driftmodel)
% Usage [z,idxbreak] = getundrifteddata(y,d,driftmodel)
% y is the data that needs the clock drift correct. 
% the linear or quadratic clock drift estimated by getdriftestimate 
% use drift model if available
% idxbreak, if there are abrupt changes according to linear interpolation
% Arko Ghosh, Leiden University, 27th July 2020 



%% gather indices of original data 
orginalidx = [1:length(y)]'; 

%% Get differences to new indices based on the estimated d
if isempty(driftmodel)
z = y; 
else
targetidxd = (feval(driftmodel,orginalidx));   
targetloop = diff(floor(targetidxd)); % change in number of samples 
locshift = [1 find(abs(targetloop)==1)']; % locations of change in number of samples
locshiftval = [targetloop(locshift)]; % value and direction of change 


fidx = []; 

for m = 1:length(locshift)-1
    f = 1; 
    fidx(locshift(1,m):locshift(1,m+1)-1) = [orginalidx(locshift(m):locshift(m+1)-1)]+sum(locshiftval(f:m)); 
    
end

    if isempty(m)
    m = 0;    
    end
    f = 1; 

fidx(locshift(1,m+1):length(orginalidx))  = [orginalidx(locshift(m+1):end)]+sum(locshiftval(f:m+1)); 

y(fidx<1) = []; 
fidx(fidx<1) = []; 
z(1:fidx(end)) = deal(NaN);  
z(fidx) = y; 

% interpolants may contain breaks, re-sticch the data 
try
    [~,bx] = risetime(abs(diff(diff(locshift))));
    idxbreak = [locshift(floor(bx))]+sum(locshiftval(1:bx));
catch
    idxbreak = []; 
end



%% fill NaNs with 
z = fillmissing(z,'previous'); 

end 





