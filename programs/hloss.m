function [res] = hloss( answer, predict )

[trow tcol] = size(answer);
[prow pcol] = size(predict);

if (trow ~= prow) || (tcol ~= pcol)
    error( 'The size of answer and predict must be same size' );
end

res = sum(sum(abs(answer-predict)')/tcol)/trow;
