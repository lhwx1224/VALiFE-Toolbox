function revs = sig2revs(x)
% SIG2REVS converts a continuously sampled signal into min-max reversals
% with their corresponding reversal index and time index vectors.
%
% Syntax: REVS = SIG2REVS(X) takes in a m*1 time series
%
% Input:     X - m*1 vector that continuously sampled time series
%
% Output: REVS - m*3 reversal matrix whose first column is the index vector
%                to the reversal history, and the second column is the time
%                index vector to the oringal time history. 
%
% Copyright by Hewenxuan Li April, 7 2020
% Programmed by Hewenxuan Li, University of Rhode Island

[sigmamax, sigmamin, ~, ~, ~, ~, ~, ~] = drivefactor(x);
M = size(sigmamax,1);        % Get the dimension of the reversal history
vindx = 1:2:2*M;             % Indeces to the valleys
pindx = 2:2:2*M;             % Indeces to the peaks
pv = [transpose(vindx) sigmamin];    % Assign the indeces to the reversal histories
pp = [transpose(pindx) sigmamax];
revs = vertcat(pv,pp);              % Concatenate the indexed reversal history
[~,I] = sort(revs(:,1));            % Sort it according to the index
revs = revs(I,:);                   % M*2 matrix of the indexed reversals
end