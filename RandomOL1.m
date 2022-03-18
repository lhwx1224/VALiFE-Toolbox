function [t, ] = RandomOL1()
% RandomOL1 returns a reversal vector by designating a based line loading,
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

%------ create a random overload statistics ------------
% ols_ini = 1; % the initial location of the ols to appear
ols_end = numel(t)-1;
% the indexes for ols is multiply by 2 because the odd locations is set for 
% minimum stress value and even location for maximum stress value
list_ols = ols_ini*2:2:ols_end;
num_ols = 5; % number of ols to occur in the stress history
% randomly permuted the number from the range of ols
rand_peaks = randperm(numel(list_ols),num_ols);
ols_indx = list_ols(rand_peaks);
stress_ols = stress_array;
ols_ratio = 1.5;% the stress ratio = stress_max/stress_base_line
% the stress overload 
stress_ols(ols_indx) = sigma_baseline*ols_ratio;
% stress_ols(end-1) = sigma_baseline;

return