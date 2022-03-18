function [t, s_pol] = PeriodicOL1(s_min, s_baseline, N, ols_init, ols_T, OLR, InitTime, FinalTime)
% PeriodicOL returns a reversal vector by designating a based line loading,
% the overload ratio, and the period of overloads.
%
% syntax: [time_array, s_pol] = PeriodicOL1(s_min, s_baseline, N, ols_init, ols_T, OLR, InitTime, FinalTime)
%
% input: s_min - minimum stress of the baseline loading
%        s_baseline - maximum stress of the baseline loading
%        N - total number of cycles included in the CAL
%        ols_init - the appearance of the first overload
%        ols_T - overoad period
%        OLR - overload ratio
%        InitTime - initial time stamp
%        FinalTime - ending time stamp
%
% output: t - time vector
%         s_pol - periodic overload reversals
%
% Copyright by Hewenxuan Li and Gideon Lyngdoh, hewenxuan_li@uri.edu
% Created on March 18, 2022

% ------------- INQUIRE THE INPUT ---------------------------------------
if nargin < 7
    InitTime = 1;
    FinalTime = N;
end

% ------------- CREATE BASELINE LOADING ---------------------------------
[t,s_CAL]=CAL(s_min,s_baseline, N, InitTime, FinalTime);
% -----------------------------------------------------------------------

%------------- CREATE A PERIODIC OVERLOAD STATISTICS --------------------
ols_end = numel(s_CAL)-1;
% the indexes for ols is multiply by 2 because the odd locations is set for 
% minimum stress value and even location for maximum stress value
ols_indx = ols_init*2:ols_T*2:ols_end;
s_pol = s_CAL;
% the stress overload 
s_pol(ols_indx) = s_baseline*OLR;
end