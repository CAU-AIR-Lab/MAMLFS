function stats = mamfs( IDATA, IANSWER, IPOOL_SIZE, INCALLS, ILCONS, IDISC, IPERF )

global data
global disc_data
global answer
global pool_size
global pool
global eval
global ncalls
global col
global row
global lcons
global acalls
global disc
global rel
global red
global f_ent
global perf
global res_hist

data = IDATA;
answer = IANSWER;
pool_size = IPOOL_SIZE;
ncalls = INCALLS;
acalls = 0;
lcons = ILCONS;
perf = IPERF;

[row,col] = size( data );

% due to multi-label accuracy family, 1+4 cells needs to be saved
% [acalls,primary measures,secondary measures,...]
res_hist = zeros( 0, 1+4 );
disc = lower(IDISC);
if ~strcmp( disc, 'on' ) && ~strcmp( disc, 'off' )
    disc = 'off';
end

fprintf( 'Initialize ...\n' );
tic
disc_data = data;
if strcmp( disc, 'on' )
    for k=1:col
        disc_data(:,k) = dis_ewi( disc_data(:,k), 3 );
    end
end

% Prepare Approximate Mutual Information
f_ent = zeros( col, 1 );
for k=1:col
    f_ent(k) = p_entropy( disc_data(:,k) );
end

acol = size(answer,2);
a_ent = zeros( acol, 1 );
for k=1:acol
    a_ent(k) = p_entropy( answer(:,k) );
end

rel = zeros( col, acol );
for k=1:col
    for m=1:acol
        rel(k,m) = f_ent(k) + a_ent(m) ...
            - p_entropy( [disc_data(:,k) answer(:,m)] );
    end
end
rel = sum( rel, 2 );

red = zeros( col, col );
red(:,:) = NaN;

%% Initialize P(t)
% Randomly initialize the pool
% Each chromosome must contain less than LCONS '1' bit
idx = 1:col;
pool = zeros(pool_size,col);
for k=1:pool_size
    tidx = idx;
    rlen = round(rand()*min((lcons-1),(col-1)))+1;
    for m=1:rlen
        ridx = round(rand()*(length(tidx)-1))+1;
        pool(k,tidx(ridx)) = 1;
        tidx(ridx) = [];
    end
end

% for the case of Multi-label accuracy, pre-allocate 4 cells; [mlacc mlprec mlrec mlf1]
% for the other evaluation measures, values are assigned as NaN
eval = zeros(pool_size,4);
eval(:,:) = inf;

%% Evaluate P(t)
for k=1:pool_size    
    eval(k,:) = evaluate( pool(k,:) ); % Obtaining each fitness
    
    res_hist(end+1,1) = acalls;
    [res_hist(end,2),tidx] = min(eval(:,1));
    res_hist(end,3:5) = eval(tidx,2:4);
end

%% LS Improvement P(t) according to the Age
[eval,sidx] = sortrows( eval, 1 );
pool = pool(sidx,:);
fprintf( 'Initialize Complete ... %1.2f s.\n', toc );

%% Start Generation
while acalls < ncalls % until termination condition is satisfied
    while size(pool,1) <= pool_size
        % Perform Local Improvement Process
        ls_ifs();

        % Crossover
        offsprings = crossover();
        c1_eval = evaluate( offsprings(1,:) );
        c2_eval = evaluate( offsprings(2,:) );

        pool = [pool;offsprings];
        eval = [eval;c1_eval;c2_eval];

        res_hist(end+1,1) = acalls;
        res_hist(end,2) = min(eval(:,1));
        [res_hist(end,2),tidx] = min(eval(:,1));
        res_hist(end,3:5) = eval(tidx,2:4);                
        
        % Mutation
        child = mutation();
        c_eval = evaluate( child );
        
        pool = [pool;child];
        eval = [eval;c_eval];

        res_hist(end+1,1) = acalls;
        res_hist(end,2) = min(eval(:,1));        
        [res_hist(end,2),tidx] = min(eval(:,1));
        res_hist(end,3:5) = eval(tidx,2:4);        
        
        [pool,sidx] = unique( pool, 'rows', 'first' );        
        eval = eval(sidx,:);
    end
    
    [eval,sidx] = sortrows( eval, 1 );
    pool = pool(sidx,:);
    
    eval = eval(1:pool_size,:);
    pool = pool(1:pool_size,:);

    fprintf( '%6d Calls, Best Perf. = %1.4f (Proposed)\n', acalls, min(eval(:,1)) );
end
% [res_pool res_eval res_hist]
stats = cell(1,3);
stats{1,1} = pool;
stats{1,2} = eval;

res_hist(end+1,1) = acalls;
res_hist(end,2) = min(eval(:,1));
[res_hist(end,2),tidx] = min(eval(:,1));
res_hist(end,3:5) = eval(tidx,2:4);
stats{1,3} = res_hist;


function ls_ifs()

global lcons
global pool
global eval
global res_hist
global acalls
global ncalls

% since genetic processes expense 3 times of evaluation,
% w * b should be 3 in order to balance with
% computational burden of genetic processes
w = 1;
b = 3;
for k=1:w
    chr_len = sum( pool(k,:) );
    
    % prepare for new chromosomes
    p_eval = zeros( b, 4 );
    p_chr = zeros( b, size(pool,2) );
    
    for m=1:b
        ratio = ( ncalls - acalls ) / ncalls;
        add_num = round( rand()*(chr_len*ratio) );
        del_num = round( rand()*(chr_len*ratio) );

        % Make sure that the number of selected features after LS improvement
        % obey the number of allowable bit
        if chr_len + add_num - del_num > lcons
            add_num = add_num + ( lcons - chr_len - add_num + del_num );
        elseif chr_len + add_num - del_num <= 0
            del_num = del_num - ( chr_len + add_num - del_num - 1 );
        end

        p_chr(m,:) = ls_ami( pool(k,:), add_num, del_num );
        p_eval(m,:) = evaluate( p_chr(m,:) );
    end
    
    % find the best improved chromosome
    [val,idx] = min( p_eval(:,1) );
    if ( val < eval(k,1) )
        % Replace the chromosome c with the improved c'
        pool(k,:) = p_chr(idx,:);
        eval(k,:) = p_eval(idx,:);
    end
    
    res_hist(end+1,1) = acalls;
    res_hist(end,2) = min(eval(:,1));
    [res_hist(end,2),tidx] = min(eval(:,1));
    res_hist(end,3:5) = eval(tidx,2:4);    
end



function children = crossover()
% Restrictive Crossover

global pool
global lcons

% Mating the best chromosome p1 and a randomly selected chromosome p2
pidx = round(rand()*(size(pool,1)-1))+1;
midx = round(rand()*(size(pool,1)-1))+1;
while pidx == midx
    midx = round(rand()*(size(pool,1)-1))+1;
end
children = zeros( 2, size(pool,2) );

% Perform the single point crossover
spoint = round(rand()*(size(pool,2)-1))+1;
children(1,1:spoint) = pool(pidx,1:spoint);
children(1,spoint+1:end) = pool(midx,spoint+1:end);
children(2,1:spoint) = pool(midx,1:spoint);
children(2,spoint+1:end) = pool(pidx,spoint+1:end);

% Make sure that the number of selected features after crossover
% obey the number of allowable bit
for k=1:2
    chr_len = sum(children(k,:));
    if chr_len > lcons
        ones_list = find(children(k,:)==1);
        for m=1:chr_len-lcons
            ridx = round(rand()*(length(ones_list)-1))+1;
            children(k,ones_list(ridx)) = 0;
            ones_list(ridx) = [];
        end
    end
end


function child = mutation()
% Restrictive Mutation

global pool
global lcons

pidx = round(rand()*(size(pool,1)-1))+1;

child = pool(pidx,:);
for k=1:length(find(pool(pidx,:)==1))
    p_zeroslist = find(child==0);
    
    if ~isempty(p_zeroslist)
        p_oneslist = find(child==1);
        zidx = round(rand()*(length(p_zeroslist)-1))+1;

        child( 1, p_zeroslist(zidx) ) = 1;
        child( 1, p_oneslist(k) ) = 0;
    end
end

for k=1:lcons-length(find(child==1))
    if rand() < 0.1 % Mutation Rate
        p_zeroslist = find(child==0);
        
        if ~isempty(p_zeroslist)
            zidx = round(rand()*(length(p_zeroslist)-1))+1;
            child( 1, p_zeroslist(zidx) ) = 1;
        end
    end
end



function val = evaluate( chr )

global acalls
% Increase the number of actual fitness function calls
acalls = acalls + 1;

if all(chr==0)
    val = [inf NaN NaN NaN];
    return;
end

global data
global row
global answer
global perf

val = zeros(1,4);

[train,test] = crossvalind( 'holdout', ones(row,1), 0.2 );
[pre,post] = pmlbayes_matlab( data(train,chr==1), answer(train,:), data(test,chr==1) );

if strcmp( perf, 'hloss' )
    val(1) = hloss( answer(test,:), pre );
    val(2) = NaN; val(3) = NaN; val(4) = NaN;
elseif strcmp( perf, 'rloss' )
    val(1) = rloss( answer(test,:), post );
    val(2) = NaN; val(3) = NaN; val(4) = NaN;
elseif strcmp( perf, 'mlacc' )
    [ta,tb,tc,td] = mlacc( answer(test,:), pre );
    val(1) = val(1) - ta; val(2) = val(2) - tb;
    val(3) = val(3) - tc; val(4) = val(4) - td;
elseif strcmp( perf, 'setacc' )
    val(1) = -setacc( answer(test,:), pre );
    val(2) = NaN; val(3) = NaN; val(4) = NaN;
elseif strcmp( perf, 'onerr' )
    val(1) = onerr( answer(test,:), post );
    val(2) = NaN; val(3) = NaN; val(4) = NaN;
elseif strcmp( perf, 'mlcov' )
    val(1) = mlcov( answer(test,:), post );
    val(2) = NaN; val(3) = NaN; val(4) = NaN;
end



function [pre,post] = pmlbayes_matlab( train, answer, test )
% Multi Label Naive Bayes
lcol = size( answer, 2 );
pre = zeros( size(test,1), lcol );
post = zeros( size(test,1), lcol );

global disc

if strcmp( disc, 'on' )
    for k=1:lcol
        model = NaiveBayes.fit( train, answer(:,k) );

        [t,pre(:,k)] = posterior( model, test );
        t(isnan(t(:,end)),end) = 0;
        pre(isnan(pre(:,k)),k) = 0;

        post(:,k) = t(:,end);
    end
else
    for k=1:lcol
        model = NaiveBayes.fit( train, answer(:,k), 'dist', 'mvmn' );

        [t,pre(:,k)] = posterior( model, test );
        t(isnan(t(:,end)),end) = 0;
        pre(isnan(pre(:,k)),k) = 0;
        
        post(:,k) = t(:,end);
    end
end




function ls_chr = ls_ami( chr, add_len, del_len )

global rel
global red
global col
global disc_data
global f_ent

aidx = zeros(add_len,1);
new_chr = chr;
for k=1:add_len
    j_value = rel;
    for m=1:col
        if new_chr(m) == 1
            j_value(m) = -inf;
            continue;
        end
        
        for n=1:col
            if (m == n) || (new_chr(n)==0)
                continue;
            end
            
            if isnan( red(m,n) )
                red(m,n) = f_ent(m) + f_ent(n) ...
                    - p_entropy( [disc_data(:,m) disc_data(:,n)] );
                red(n,m) = red(m,n);
            end
            j_value(m) = j_value(m) - red(n,m);
        end
    end
    [~,aidx(k)] = max( j_value );
    new_chr( aidx(k) ) = 1;
end

didx = zeros(del_len,1);
new_chr = chr;
for k=1:del_len
    j_value = rel;
    for m=1:col
        if new_chr(m) == 0
            j_value(m) = inf;
            continue;
        end
        
        for n=1:col
            if (m == n) || (new_chr(n)==0)
                continue;
            end
            
            if isnan( red(m,n) )
                red(m,n) = f_ent(m) + f_ent(n) ...
                    - p_entropy( [disc_data(:,m) disc_data(:,n)] );
                red(n,m) = red(m,n);
            end
            j_value(m) = j_value(m) - red(n,m);
        end
    end
    [~,didx(k)] = min( j_value );
    new_chr( didx(k) ) = 0;
end

ls_chr = chr;
ls_chr( aidx ) = 1;
ls_chr( didx ) = 0;
