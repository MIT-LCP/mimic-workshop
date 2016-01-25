function [ rocx, rocy, auc ] = calcRoc( pred, target )
%CALCROC This function outputs the sensitivity and 1-specificity at every
%operating point in PRED. These values can be plotted to create a receiver
%operator characteristic (ROC) curve.
%   Detailed explanation goes here

[pred,idxSort] = sort(pred,1,'ascend');
target=target(idxSort);

TP = flipud(target);
FP = cumsum(1-TP);
FP = flipud(FP);
TP = cumsum(TP);
TP = flipud(TP);
FN = cumsum(target)-target;
TN = numel(target) - TP - FP - FN;

%=== 1-Specificity (false positive rate)
rocx = 1- (TN ./ (TN + FP));

%=== Sensitivity (true positive rate)
rocy = TP ./ (TP + FN);

% AUROC
if nargout > 2
idxNegative = target==0;
    % Count the number of negative targets below each element
    auc = cumsum(idxNegative,1);
    
    % Now only keep elements for positive cases
    % the result is a vector which counts, for each positive case, how many
    % negative cases are lower in predicted value
    auc = auc(~idxNegative);

    % sum the number of negative cases which are below a positive case
    auc = sum(auc,1); %=== count number who are negative

    % divide by the number of positive/negative pairs in the data
    auc = auc./(sum(target==1) * sum(target==0));

    % the result is the probability a positive case prediction is higher than a
    % negative case prediction: the AUROC.
end

end

