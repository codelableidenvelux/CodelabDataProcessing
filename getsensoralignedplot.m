function [Phone, Marker_d, BS, idx] = getsensoralignedplot(EEG,indices)
% Plot phone data in onjunction with BS movement data 
% Usage : [Phone, Transitions, BS, idx] = getsensoralignedplot(EEG,indices)
% Continous Phone Data
% Marker_d Breaks in EEG recorder
% BS data (filtered)
% Indices of phone data idx. 
% Use of indices 
% If 0 use uncorrected phone indices vs. EEG aligned BS data
% If 1 use corrected phone indices vs. EEG aligned BS data 
% If 2 use piece wise alignment data vs. uncorrected phone indices 
% CODELAB EEG FORMAT (partial data is sufficient) 

if indices == 0 
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];
    end
elseif indices == 1
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.Phone.Corrected,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Corrected{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];
    end
elseif indices == 2
    Phone_d = []; Marker_d = []; 
    for ff = 1:size(EEG.Aligned.Phone.Blind,2)
        Phone_d = [Phone_d EEG.Aligned.Phone.Blind{1,ff}(:,2)'];
        Marker_d = [Marker_d min(EEG.Aligned.Phone.Blind{1,ff}(:,2)')];

    end
end 

    Phone = double(ismember(1:EEG.pnts, Phone_d));
    Transitions = double(ismember(1:EEG.pnts, Marker_d));
    Transitions(Transitions<1) = deal(NaN) ;

if or(indices == 0,indices == 1)
BS = getcleanedbsdata(EEG.Aligned.BS.Data(:,1),EEG.srate,[1 10]);
else
EEG.Aligned.Piece.BS(EEG.Aligned.Piece.Corr<0.01) = deal(NaN);
BS = getcleanedbsdata(EEG.Aligned.Piece.BS',EEG.srate,[1 10]);   
end 

figure('name','Aligned Data')
plot(Phone); hold on; 
plot(Transitions,'.r','MarkerSize',20)
yyaxis right; 
plot(BS); 


figure('name','Aligned Epoched Data')
idx = find(Phone>0.1); idx(diff(idx)<100) = []; 
ep = getepocheddata(BS,idx,[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'k'); hold on
 ep = getepocheddata(BS,idx(1:200),[-10000 10000]); ep(ep==0) = deal(NaN);
 plot(nanmean(ep,1),'g','LineWidth',1.5); hold on
 legend({'Overall','First 200'}); 
% for b = 1:length(Marker_d) 
%     if b == length(Marker_d)
%         idx_tmp = idx(idx>Marker_d(b));
%         ep = getepocheddata(BS,idx_tmp,[-10000 10000]); ep(ep==0) = deal(NaN);
%         plot(nanmedian(ep,1),'g');hold on
%     else
%         idx_tmp = idx(and(idx>Marker_d(b),idx<Marker_d(b+1)));
%         ep = getepocheddata(BS,idx_tmp,[-10000 10000]); ep(ep==0) = deal(NaN);
%         plot(nanmedian(ep,1),'r');hold on
%     end
% end
xlabel('Distance from smartphone touch (data points)')
ylabel('Median displacement (a.u)')

end