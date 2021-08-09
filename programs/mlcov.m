function [res] = mlcov( answer, predict )

[trow tcol] = size(answer);
[prow pcol] = size(predict);

if (trow ~= prow) || (tcol ~= pcol)
    error( 'The size of answer and predict must be same size' );
end

res = 0;
t = zeros( pcol, 3 );
for k=1:trow
    t(:,1:2) = sortrows( [answer(k,:);predict(k,:)]', -2 );
    t(:,3) = 1:pcol;
    t = sortrows( t, -[1 2] );
        
    idx = find( t(:,1) == 1 );
    
    if ~isempty( idx ), res = res + t(idx(end),3); end
end
res = res / trow;
