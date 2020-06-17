function [pval] = getperiodstats(peakval, pgram) 
% getperiodstats(peakval, pgram) 
% inputs can be a matrix or individual periodograms 
% 
% usage example: 
% pval = getperiodstats(peakamp, values);
% Where 'pval' is the p value of the 'peakamp', derived from a range of
% 'values'. Can be used to address if the peak is significant at alpha 0.05
% for instance. 
% 
% Arko Ghosh, Leiden University, June 2020 
%
% References: 
% mathworks.com/help/signal/ug/significance-testing-for-periodic-component.html
% [1] Percival, Donald B. and Andrew T. Walden. Spectral Analysis for Physical Applications. Cambridge, UK: Cambridge University Press, 1993.
% [2] Wichert, Sofia, Konstantinos Fokianos, and Korbinian Strimmer. "Identifying Periodically Expressed Transcripts in Microarray Time Series Data." Bioinformatics. Vol. 20, 2004, pp. 5-20.

for i = 1:size(pgram,1)
fisher_g = peakval(i)/nansum(pgram(i,:));

N = length(pgram);
nn = 1:floor(1/fisher_g);
try
I = (-1).^(nn-1).*exp(gammaln(N+1)-gammaln(nn+1)-gammaln(N-nn+1)).*(1-nn*fisher_g).^(N-1);

pval(i) = nansum(I);
if sum(isnan(I)) == length(I)
pval(i) = 1;
end
catch
pval(i) = 1;
end
end
end