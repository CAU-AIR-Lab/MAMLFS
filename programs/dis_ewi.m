function [res] = dis_ewi(a, k)

% Equal Width Interval
res = zeros(length(a),1);
minval = min(a);
maxval = max(a);
binsize = abs(maxval-minval)/k;

for m=1:k-1
    res((a<=minval+m*binsize)&(res==0)) = m;
end   
res(a>minval+(k-1)*binsize) = k;
