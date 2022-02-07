function revs = pv2revs(peaks,valleys)
% pv2revs converts peaks and valleys into reversals
%
% PV2REVS converts peaks and valley series into an indexed reversal history 
% When the input PEAKS and VALLEYS are both vectors (where their indeces 
% are missing) the output REVS is a Mx2 matrix whose first column is the
% indeces of the reversal. When the input PEAKS and VALLEYS are both mx2
% matrices, the output REVS is a Mx3 matrix whose first column is the
% indeces of the reversal history and the second column is the time index
% vector.
% 
% Syntax: REVS = PV2REVS(PEAKS, VALLEYS)
%
% Input:  PEAKS - M*2 matrix, where the second column contains the peak
%                 loads
%                 M*1 vector, where the vector contains peak history 
%       VALLEYS - M*2 matrix, where the second column contains the valley
%                 loads
%                 M*1 vector, where the vector contains valley history
%
% Output:  revs - M*2 matrix whose first column are indeces to the
%                 reversals and whose second column are the reversal
%                 history.
%                 M*3 matrix whose first column are indeces to the
%                 reversals and the second column are the time indeces to
%                 the original time series. The third column is the
%                 reversal history.
%
% Programmed by Hewenxuan Li Feb 12, 2019
% Modified on April 7, 2020
% The function is now converted to output reversal matrix REVS.
% The INPUT does not require a FLAG anymore. The indeces vector will be
% automatically added to the reversal history.
% Copyright by Hewenxuan Li April, 2020


if size(peaks)~=size(valleys)
    error('The dimension of the inputs must be identical!')
end

if size(peaks,2) == 1 && size(valleys,2) == 1
    r = 0; % Case 0 is the index of reversals only case
elseif size(peaks,2) == 2 && size(valleys,2) == 2
    r = 1; % Case 1 is the index of reversals and time case
else 
    error('The dimension of the inputs are not matching! Please refer to the USAGE part of this function!')
end

if r == 1
    pv = vertcat(valleys,peaks); % Concatenate valley and peak history
    [~,I] = sort(pv(:,1));       % Get sorted index of the 
    pv = pv(I,:);                % Sort the concatenated matrix according to their time index
    rindx = 1:1:length(pv);      % Get the indeces of the reversal
    revs = [transpose(rindx) pv];

elseif r == 0
    M = size(peaks,1);           % Get the dimension of the reversal history
    vindx = 1:2:2*M;             % Indeces to the valleys
    pindx = 2:2:2*M;             % Indeces to the peaks
    pv = [transpose(vindx) valleys];    % Assign the indeces to the reversal histories
    pp = [transpose(pindx) peaks];
    revs = vertcat(pv,pp);              % Concatenate the indexed reversal history
    [~,I] = sort(revs(:,1));            % Sort it according to the index
    revs = revs(I,:);                   % M*2 matrix of the indexed reversals
end

return