function [t,revs]=CAL(s_min,s_max, N, InitTime, FinalTime)
% CAL gives a constant amplitude loading reversal by defining the minimum
% stress, maximum stress (sigma_baseline); if time is needed, a psudo-time
% vector can be assigned using the initial time, final time, and the number
% of cycles per unit time.
%
% syntax: [t,revs]=CAL(s_min,s_max, N, InitTime, FinalTime)
% 
% input: s_min - minimum stress
%        s_max - maximum stress
%        InitTime - inital time value
%        FinalTime - final time value
%        pps - peaks per second, frequency of the appreance of peaks
%
% output: t - time array 
%         revs - reversals
%
% Copyright by Gideon Lyngdoh and Hewenxuan Li, March 18, 2022 
% VALiFE-Toolbox v0.0

if nargin < 3
    InitTime = 1;
    FinalTime = N;
end

% this is the stress cylic unit that form as a base for the stress reversal
% history
stress_reversal_unit = [s_min, s_max];
% create the array of stress reversal by replicating the stress reversal
% unit
revs = repmat(stress_reversal_unit,1,N);
revs(end+1) = 0; % the last part of the stress history is set to zero.
% create the time history
t = linspace(InitTime,FinalTime,N*2+1);
end