clc; clear;
sigma_min = 0; % the minimum stress range history
sigma_baseline = 1; % the baseline stress
InitTime = 0; % initial time
FinalTime = 1; % Final Time
peakspersecond = 20; % number of cycles per unit time
[time_array,stress_array]=CAL(sigma_min,sigma_baseline,InitTime,FinalTime,peakspersecond);

%------ create a periodic overload statistics ------------
ols_ini = 1; % the initial location of the ols to appear
ols_end = numel(time_array)-1;
ols_periodic = 5; % the periodic cycle for ols to occur in the stress history
% the indexes for ols is multiply by 2 because the odd locations is set for 
% minimum stress value and even location for maximum stress value
ols_indx = ols_ini*2:ols_periodic*2:ols_end;
stress_ols = stress_array;
ols_ratio = 1.5; % the stress ratio = stress_max/stress_base_line
% the stress overload 
stress_ols(ols_indx) = sigma_baseline*ols_ratio;
% stress_ols(end-1) = sigma_baseline;

% Create plot
h = figure();
axes_parent = axes('Parent',h);
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
title(['Periodic OLS with a gap of ',num2str(ols_periodic)])
box(axes_parent,'on');
hold(axes_parent,'off');
% Set the remaining axes properties
set(axes_parent,'FontName','Arial','FontSize',12,'FontWeight','bold','LineWidth',...
    1.5);