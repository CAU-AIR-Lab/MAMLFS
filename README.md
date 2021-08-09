# Memetic Feature Selection Algorithm for Multi-label Classification

## Abstract

The use of multi-label classification, i.e., assigning unseen patterns to multiple categories, has emerged in modern applications. A genetic-algorithm based multi-label feature selection method has been considered useful because it successfully improves the accuracy of multi-label classification. However, genetic algorithms are limited to identify fine-tuned feature subsets that are close to the global optimum, which results in a long runtime. In this paper, we present a memetic feature selection algorithm for multi-label classification that prevents premature convergence and improves the efficiency. The proposed method employs memetic procedures to refine the feature subsets found through a genetic search, resulting in an improvement in multi-label classification. Empirical studies using various tests show that the proposed method outperforms conventional multi-label feature selection methods.

This program is designed to perform the feature selection for multi-label data set. This method deals with standard multi-label data set, in which the number of given label is larger than one.

This software is a Matlab implementation of proposed method, highly specialized into the problems of categorical data set classification. The original version of this program was written by Jaesung Lee.

### [Paper]

The main technical ideas behind how this program works appear in these papers:

Jaesung Lee, and Dae-Won Kim, [“Memetic Feature Selection Algorithm for Multi-label Classification,”](https://www.sciencedirect.com/science/article/pii/S0020025514009268) Information Sciences, 293, 2015.

Zexuan Zhu et al. [“Wrapper-Filter Feature Selection Algorithm Using a Memetic Framework,”](https://ieeexplore.ieee.org/document/4067093) IEEE Transactions on Systems, Man, and Cybernetics, Part B: Cybernetics, 37, 2007.

## License

This program is available for download for non-commercial use, licensed under the GNU General Public License, which is allows its use for research purposes or other free software projects but does not allow its incorporation into any type of commerical software.

## Sample Input and Output

It will return the final population composed of solutions. Each solution represents selected/unselected features as 0/1 respectively. This code can be executed on the Matlab command window.

### [Usage]:
   `>> stats = mamfs( features, labels, poolsize, calls, cons, disc, perf );`

### [Description]
   features – a matrix that is composed of features \
   labels – a matrix represents labels of each pattern is assigned to \
   poolsize – the number of chromosomes in the population \
   calls – the number of allowed fitness function calls \
   cons – the number of allowed features, each solution will select features lesser than cons \
   disc – flag (‘on’ / ‘off’) if numerical features is given then it should be set to ‘on’ \
   perf – the name of evaluation measure (‘hloss’ / ‘rloss’ / ‘mlacc’ / ‘setacc’ / ‘onerr’ / ‘mlcov’)

   stats – 1 by 3 output cell matrix \
    1st column – the final population \
    2nd column – the final fitness values \
    3rd column – calls by 5 transactions of memetic search \
     1st column – number of spent fitness function calls (FFCs) \
     2nd to 5th columns – the best fitness value of that FFCs

By convention in the input features matrix, rows represent data (e.g. patterns) and columns represent features.

The information for other programs are:

   `>> f = dis_ewi( single_feature, bins )` : Discretize a numerical feature into a categorized feature \
   `>> ent = p_entropy( features )` : Calculate the entropy of given (multivariate) feature \
   `>> val = hloss( groundtruth, predicted )` : Calculate the Hamming loss of predicted result \
   `>> val = rloss( groundtruth, predicted(real-value) )` : Calculate the Ranking loss of predicted result \
   `>> val = mlacc( groundtruth, predicted )` : Calculate the Multi-label accuracy of predicted result \
   `>> val = setacc( groundtruth, predicted )` : Calculate the Subset accuracy of predicted result \
   `>> val = onerr( groundtruth, predicted(real-value) )` : Calculate the One error of predicted result \
   `>> val = mlcov( groundtruth, predicted(real-value) )` : Calculate the Coverage of predicted result
