% This function converts any time series into seqeuncies of maximum and
% minimum values.
%   Input: x - original time series for conversion
% Outputs: sigmamin - minimum values of the original time series
%          sigmamax - maximum values of the original time series
% 
% Created by: Hewenxuan Li
% Last Modified: 12/21/2018
%                 3/11/2019: notification and data shaping was added
function [sigmamin, sigmamax] = conversion(x)

if size(x,1) > 1 && size(x,2) > 1
    error('Input to the conversion function should be a vector!')
end
if size(x,1) < size(x,2)
    disp('Your input vector is a row vector, transpose is conducted.')
    x = transpose(x);
end
M = mean(x); % Mean value of the original time series
[pks, locs] = findpeaks(x);% Find peaks of the original time series
sigmamax = [locs, pks];% Locations and the maximum values
y = -(x - M);% Mean subtraction and flipping of the original time seires
[pksy, locsy] = findpeaks(y);% These maximum values are minimum values due to flipping 
pksy = -pksy + M;% Conversion to minimum by flipping and mean addition
sigmamin = [locsy, pksy];
% the following lines makes sure the seqeunce always starts with a minimum
if sigmamin(1,1) > sigmamax(1,1)
    sigmamax = sigmamax(2:end,:);
end
% the following lines make sure the sequence always ends with a maximum
if size(sigmamin,1)>size(sigmamax,1)
    sigmamin = sigmamin(1:end-1,:);
end
return