% This function converts the original time series to driving factors,
% namely the maximum values (e.g., maximum stress), minimum values (e.g.,
% the minimum stress), difference between consecutive trough and
% peak (e.g., loading cycle range), difference between two consecutive
% peaks (e.g., peak stress difference), difference between two consecutive
% peaks only if the second is smaller than the first one (e.g., overload),
% load cycle range corresponding to the overload, and the unloading cycle
% range corresponding to the overload.
%
% NOTE: This program is a generalization to the 'conversion.m' file.
%
% SYNTAX:  [sigmamax, sigmamin, lcr, pd, ol, lcr_ol, ulcr_ol, sigmam] =
%          drivefactor(x)
% INPUTS:  x - time seires 
% OUTPUTS: sigmamax - (n*2) maximum stress levels' locations and values
%          sigmamin - (n*2) minimum stress levels' locations and values
%               lcr - (n*2) loading cycle range location and values
%                pd - (n*2) peak difference ...
%                ol - (n1*2) overload ... 
%            lcr_ol - (n1*1) loading cycle range (correspons to the overload)
%               sar - (n1*2) Mean stress adjusted stress amplitude
%            sigmam - (n*2) mean stress level
% Copyright by Hewenxuan Li, University of Rhode Island
% Modified on 10/8/18
%             2/15/19   Unloading cycle range was deleted
%             6/3/19    Description updated, conversion.m is no longer
%             required.
%             3/27/2020 Mean stress added to the program.
%             3/30/2020 Mean stress formulation corrected to n*2 matrix
%             with locations of sigmamax.
%             4/15/2020 Mean stress adjusted stress amplitude added,
%             unloading cycle range corresponds to overload is commented
function [sigmamax, sigmamin, lcr, pd, ol, lcr_ol, sar, sigmam] = drivefactor(x, fullhistory)

if nargin < 2
    fullhistory = 'true';
end
% Previous function 'conversion.m' which returns the maxima of the time
% series
if size(x,1) > 1 && size(x,2) > 1
    error('Input time series should be a vector!')
end
% Reshape if it is not a column vector
if size(x,1) < size(x,2)
%     disp('Your input vector is a row vector, transpose is conducted.')
    x = transpose(x);
end
xindx = 1:1:length(x);
% If the first half cycle is a loading cycle, pending an unloading half
% cycle to the first half cycle
if x(2) - x(1) > 0
    x1 = [x(1) + 1; x];
    xindx = xindx + 1;
end
% If the last half cycle is an unloading cycle, pending a loading half
% cycle in the end
if x(end) - x(end - 1) < 0
    x1 = [x1; x1(end) + 1];
end
% ----------- Find Peaks ----------
M = mean(x1);                    % Mean value of the original time series
[pks, locs] = findpeaks(x1);     % Find peaks of the original time series
sigmamax = [locs, pks];         % Locations and the maximum values

% ----------- Find Valleys ----------
y = -(x1 - M);                   % Mean subtraction and flipping of the original time seires
[pksy, locsy] = findpeaks(y);   % These maximum values are minimum values due to flipping 
pksy = -pksy + M;               % Conversion to minimum by flipping and mean addition
sigmamin = [locsy, pksy];
if x(2) - x(1) > 0
    sigmamax(:,1) = sigmamax(:,1) - 1;
    sigmamin(:,1) = sigmamin(:,1) - 1;
end

% if x(end) - x(end - 1) < 0
%     sigmamin(:,1) = sigmamin(:,1) - 2;
% end

plot(x1,'k--');
hold on
plot(xindx,x,'r');
plot(locsy, pksy, '*')
plot(locs,pks,'x')

% ---------- Reshape the cycle history for fatigue analysis ----------
% The following lines makes sure the seqeunce always starts with a minimum
% or, equivalently, always starts with a loading cycle range
if isequal(lower(fullhistory),'false')
if sigmamin(1,1) > sigmamax(1,1)  % IF the 1st min index is greater than the 1st max index
    % Remove the first maximum stress point (remove the first unloading half cycle)
    sigmamax = sigmamax(2:end,:); 
end
% The following lines make sure the sequence always ends with a maximum or,
% equivalently, always ends with a loading cycle range

% IF the minimum sequence is longer than the maximum stress sequence
    if size(sigmamin,1)>size(sigmamax,1)
        % Remove the last minimum stress point (remove the last unloading half cycle)
        sigmamin = sigmamin(1:end-1,:);
    end
end

lsmax = length(sigmamax(:,2));
lsmin = length(sigmamin(:,2));
minls = min(lsmax,lsmin);
lcr = zeros(minls,2);                 % Loading cycle range
lcr(:,1) = sigmamax(1:minls,1);  
lcr(:,2) = sigmamax(1:minls,2)- sigmamin(1:minls,2);
% % Drive factors
% lcr = zeros(length(sigmamax(:,2))-1,2);                 % Loading cycle range
% lcr(:,1) = sigmamax(1:end-1,1);                         
% lcr(:,2) = sigmamax(1:end-1,2)- sigmamin(1:end-1,2);
% ulcr = sigmamax(1:end-1,2)-sigmamin(2:end,2);
pd = zeros(length(sigmamax(:,2))-1,2);                  % Peak difference
pd(:,1) = sigmamax(1:end-1,1);
pd(:,2) = sigmamax(1:end-1,2)-sigmamax(2:end,2);
indx = pd(:,2)>0;
ol = pd(indx,:);
lcr_ol = sigmamax(indx,2) - sigmamin(indx,2);           % LCR wrt OL
% UNLOADIN CYCLE RANGE CORR OL
% indxx = [false; indx(1:end-1)];
% xx = sigmamax(indx,2);
% yy = sigmamin(indxx,2);
% if length(xx)>length(yy)
%     L = length(xx) - length(yy);
%     xx = xx(1:end-L);
%     ol = ol(1:end-L,:);
%     lcr_ol = lcr_ol(1:end-L);
%     
% elseif length(yy)>length(xx)
%     L = length(xx) - length(yy);
%     yy = yy(1:end-L);
%     ol = ol(1:end-L,:);
%     lcr_ol = lcr_ol(1:end-L);
%     
% end
% % ulcr_ol = sigmamax(indx,2) - sigmamin(indxx,2);
% ulcr_ol = xx - yy;

% sigmamax = sigmamax(1:end-1,:);
% sigmamin = sigmamin(1:end-1,:);
sigmam  = [sigmamax(1:minls,1) 0.5*(sigmamax(1:minls,2) + sigmamin(1:minls,2))];
sar = [sigmamax(1:minls,1) sqrt(sigmamax(1:minls,2).*lcr(1:minls,2)/2)];
end