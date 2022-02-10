% This code can identify the overloading peaks and its position in a given
% stress time history. 

clear; clc;
tic
% close all;
rng(100); % setting the random seed for repeatable purpose
peak_num = 10; % number of peaks value
min_val = 0; % set the minimum stress value
max_val = 10; % set the maximum stress value
peaks_val = rand(11,1)*peak_num;  % set the peaks value
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

xt = 0:tot_points-1;
yt = X;
[peaks_value,idx_peaks] = findpeaks(yt);

[c,hist,edges,rmm,idx] = rainflow(yt);
T = array2table(c,'VariableNames',{'Count','Range','Mean','Start','End'});
[xt_updated,yt_updated,xpeak,ypeak] = checking_overloading(T,xt,yt,yt,1);
store_ol_ids(1) = xpeak;
peak_store(1,1:2)= [xpeak,ypeak];
plot(xt,yt,'-o')
str =split(num2str(xt));
text(xt,yt+0.2,str,'Color','red','FontSize',12)
jj = 2;
disp('Rainflow counting starting....')
while ~isnan(xpeak)    
    [c,hist,edges,rmm,idx] = rainflow(yt_updated);
    T = array2table(c,'VariableNames',{'Count','Range','Mean','Start','End'});
    [xt_updated,yt_updated,xpeak,ypeak] = checking_overloading(T,xt_updated,yt_updated,yt,jj);
    if ~isnan(xpeak)
        store_ol_ids(jj) = xpeak;
        peak_store(jj,1:2)= [xpeak,ypeak];
    end
    jj = jj+1;
end
disp('Rainflow counting ended')
figure(1)
subplot(211)
plot(xt,yt,'-o')
str =split(num2str(xt));
text(xt,yt+0.2,str,'Color','red','FontSize',12)
title('Stress range history')
subplot(212)
yt_updated = zeros(size(yt));
yt_updated(peak_store(:,1)+1) = peak_store(:,2);
plot(xt,yt_updated)
str1 =num2str(peak_store(:,1));
text(peak_store(:,1),peak_store(:,2)+0.2,str1,'Color','red','FontSize',12)
title('Identification of over loading')
toc

