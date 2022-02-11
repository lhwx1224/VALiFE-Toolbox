% This code can identify the overloading peaks and its position in a given
% stress time history. 

clear; clc;
tic
% close all;
peak_num = 10; % number of peaks value
min_val = 0; % set the minimum stress value
max_val = 10; % set the maximum stress value
seed = 100; % setting the random seed for repeatable purpose

% --------- generating the stress history dataset -----------
[yt]=generate_stress_history(seed,min_val,max_val,peak_num); 
xt = 0:size(yt,1)-1; % the index set of peaks value or time
% --------- indetified al the overloaded peaks -----------
[peak_store,store_ol_ids]=identification_overloading_sweeping(yt,xt);
% --------- Display the plots -----------
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

