function [acc,prec,rec,f1] = mlacc( answer, predict )

[trow,tcol] = size(answer);
[prow,pcol] = size(predict);

if (trow ~= prow) || (tcol ~= pcol)
    error( 'The size of answer and predict must be same size' );
end

% Preventing Divide by Zero Error by Adding Smallest Value
Ylen = sum(answer,2)+0.001;
Yhat_len = sum(predict,2)+0.001;

acc = 0;
prec = 0;
rec = 0;
Inter = answer + predict;
for k=1:trow
    inter_len = length(find(Inter(k,:)==2))+0.001;
    union_len = length(find(Inter(k,:)>=1))+0.001;

    acc = acc + inter_len / union_len;
    prec = prec + inter_len / Yhat_len(k);
    rec = rec + inter_len / Ylen(k);
end
acc = acc / trow;
prec = prec / trow;
rec = rec / trow;
f1 = 2*prec*rec / (prec+rec);
