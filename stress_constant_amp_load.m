clc; clear; 
% vlvlvlv
sigma_min = 0; % the minimum stress range history
sigma_baseline = 1; % the baseline stress
% this is the stress cylic unit that form as a base for the stress reversal
% history
stress_reversal_unit = [sigma_min, sigma_baseline]; 
% num_peaks: this set as a number of peaks to plot. Alternatively, you can set the
% total time set and the frequency to get the number of peaks
InitTime = 0; % initial time
FinalTime = 1; % Final Time
TotTime = FinalTime-InitTime;
freq_time = 20; % number of cycles per unit time
num_peaks = freq_time*TotTime; 
% create the array of stress reversal by replicating the stress reversal
% unit in column wise
stress_array = repmat(stress_reversal_unit,1,num_peaks);
stress_array(end+1) = 0; % the last part of the stress history is set to zero.
% create the time history
time_array = linspace(InitTime,FinalTime,num_peaks*2+1);
% Create plot
h = figure();
axes_parent = axes('Parent',h);
plt = plot(time_array,stress_array);
pltprops.color = 'b';
plt.LineWidth = 1.5;
% Create ylabel
ylabel('Stress (MPa)');
% Create xlabel
xlabel('Time (s)');
title('Constant Stress Loading')
box(axes_parent,'on');
hold(axes_parent,'off');
% Set the remaining axes properties
set(axes_parent,'FontName','Arial','FontSize',12,'FontWeight','bold','LineWidth',...
    1.5);