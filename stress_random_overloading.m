clc; clear;
sigma_min = 0; % the minimum stress range history
sigma_baseline = 1; % the baseline stress
InitTime = 0; % initial time
FinalTime = 1; % Final Time
freq_time = 20; % number of cycles per unit time
[time_array,stress_array]=constant_loading(sigma_min,sigma_baseline,...
    InitTime,FinalTime,freq_time);
%------ create a random overload statistics ------------
ols_ini = 1; % the initial location of the ols to appear
ols_end = numel(time_array)-1;
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

% Create plot
h = figure();
axes_parent = axes('Parent',h);
hold(axes_parent,'on');
plt = plot(time_array,stress_array);
pltprops.color = 'b';
plt.LineWidth = 1.5;
hold on
plt = plot(time_array,stress_ols,'--');
pltprops.color = 'r';
plt.LineWidth = 1.5;
hold off

% Create ylabel
ylabel('Stress (MPa)');
% Create xlabel
xlabel('Time (s)');
% ylim([-0.5,2])
title([num2str(num_ols),' randomly distributed constant OLS'])
box(axes_parent,'on');
hold(axes_parent,'off');
% Set the remaining axes properties
set(axes_parent,'FontName','Arial','FontSize',12,'FontWeight','bold','LineWidth',...
    1.5);


function [time_array,stress_array]=constant_loading(sigma_min,sigma_baseline,InitTime,FinalTime,freq_time)
% sigma_min = 0; % the minimum stress range history
% sigma_baseline = 1; % the baseline stress
% this is the stress cylic unit that form as a base for the stress reversal
% history
stress_reversal_unit = [sigma_min, sigma_baseline];
% num_peaks: this set as a number of peaks to plot. Alternatively, you can set the
% total time set and the frequency to get the number of peaks
% InitTime = 0; % initial time
% FinalTime = 1; % Final Time
TotTime = FinalTime-InitTime;
% freq_time = 20; % number of cycles per unit time
num_peaks = freq_time*TotTime;
% create the array of stress reversal by replicating the stress reversal
% unit
stress_array = repmat(stress_reversal_unit,1,num_peaks);
stress_array(end+1) = 0; % the last part of the stress history is set to zero.
% create the time history
time_array = linspace(InitTime,FinalTime,num_peaks*2+1);
end

