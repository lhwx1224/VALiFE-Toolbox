function [t, s_rol] = RandomOL1(s_min, s_baseline, N, ols_ini, OLR, NOL, InitTime, FinalTime)
% RandomOL1 returns a reversal vector by designating a based line loading,
% the overload ratio, and the period of overloads.
%
% syntax: [time_array, s_pol] = PeriodicOL1(s_min, s_baseline, N, ols_init, ols_T, OLR, InitTime, FinalTime)
%
% input: s_min - minimum stress of the baseline loading
%        s_baseline - maximum stress of the baseline loading
%        N - total number of cycles included in the CAL
%        ols_ini - the appearance of the first overload
%        OLR - overload ratio
%        NOL - total number of overloads
%        InitTime - initial time stamp
%        FinalTime - ending time stamp
%
% output: t - time vector
%         s_pol - periodic overload reversals
%
% Copyright by Hewenxuan Li and Gideon Lyngdoh, hewenxuan_li@uri.edu
% Created on March 18, 2022

% ------------- INQUIRE THE INPUT ---------------------------------------
if nargin < 8
    InitTime = 1;
    FinalTime = N;
end

% ------------- CREATE BASELINE LOADING ---------------------------------
[t,s_CAL]=CAL(s_min,s_baseline, N, InitTime, FinalTime);
% -----------------------------------------------------------------------

%-------------- CREATE A RANDOM OVERLOAD STATISTICS ---------------------
ols_end = numel(t)-1;
% the indexes for ols is multiply by 2 because the odd locations is set for 
% minimum stress value and even location for maximum stress value
list_ols = ols_ini*2:2:ols_end;
% randomly permuted the number from the range of ols
rand_peaks = randperm(numel(list_ols),NOL);
ols_indx = list_ols(rand_peaks);
s_rol = s_CAL;
% the stress overload 
s_rol(ols_indx) = s_baseline*OLR;
% -----------------------------------------------------------------------
return