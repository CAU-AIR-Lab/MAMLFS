function [res] = rloss( answer, predict )

[trow tcol] = size(answer);
[prow pcol] = size(predict);

if (trow ~= prow) || (tcol ~= pcol)
    error( 'The size of answer and predict must be same size' );
end

res = 0;
for k=1:trow
    vec = combvec( find( answer(k,:) == 1 ), find( answer(k,:) == 0 ) )';
    if isempty(vec), continue; end
    
    comb = size(vec,1);    
    count = 0;
    for m=1:comb
        if predict(k,vec(m,1)) <= predict(k,vec(m,2))
            count = count + 1;
        end
    end
    res = res + count / comb;
end
res = res / trow;
