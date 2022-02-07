function Y = signorm(X,mean,var)
% SIGNORM normalized the given signals (e.g.,time series) with given mean
% and variance. For example, SIGNORM(X,0,1) normalize a given time series
% matrix X to zero mean and unit variance for each of its column.
% 
% Syntax: Y = SIGNORM(X,MEAN,VAR) => X is normalized with given MEAN and
%         VAR.
%         Y = SIGNORM(X) => X is normalized with the extremum point of the
%         time series.
%
% Input:     X - Matrix whose Columns are time series under normalization
%         MEAN - Mean to the converted time series, Y
%          VAR - Variance to the converted time series, Y 
%                                                                           
% Ouput:     Y - Matrix whose Columns are normalized with the designated
%                method.
%
% Copyright by Hewenxuan Li, March 2020
% Programmed in March 2020, University of Rhode Island, RI 02881, USA
if nargin == 1
    method = 'absMax';
    fprintf('Load time history is adjusted by designated ablolute maximum value!\n')

elseif nargin == 3
    method = 'MeanVariance';
    fprintf('Load time history is adjusted by designated mean of %f and variance of %f!\n',[mean var])
else 
    error('Please check the input arguments! See usage in the description!')
end

if strcmp(method,'MeanVariance')
    Y = zscore(X);
    Y = bsxfun(@times, Y, sqrt(var));
    Y = bsxfun(@plus,Y,mean);
elseif strcmp(method,'absMax')
    xmax = max(abs(X));
    Y = X./xmax;
end

return
% -... IPSA SCENTIA POTESTAS EST -....