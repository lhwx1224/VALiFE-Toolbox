function [X]=generate_stress_history(seed,min_val,max_val,peak_num)
% This function generate a stress history with minimum and maximum stress
% ------ Output:
% X: the stress history between maximum stress value and minimum
% stress value
% tot_points: total number of datapoints
% ------- Inputs:
% seed: seed value for repetitive answer
% min_value
rng(seed); % setting the random seed for repeatable purpose
peaks_val = max_val*rand(peak_num,1);  % set the peaks value
j = 1;
tot_points = numel(peaks_val)*2+1; % total number of data points
X = zeros(tot_points,1);
for i =1:tot_points
    if rem(i,2)==0 % set the peaks value at the even number
        X(i) = peaks_val(j);
        j = j+1;
    else
        X(i) = min_val;
    end
end
end