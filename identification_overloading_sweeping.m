function [peak_store,store_ol_ids]=identification_overloading_sweeping(yt,xt)
% This functoion indentified the overloading peaks in the dtaa
% ----- Outputs
% peak_store: store all the peaks
% store_ol_ids: store the peaks value location
%
% ----- Inputs
% [peaks_value,idx_peaks] = findpeaks(yt);
% yt: the stress history
% yt: the time of index history

[c,~,~,~,~] = rainflow(yt);
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
    [c,~,~,~,~] = rainflow(yt_updated);
    T = array2table(c,'VariableNames',{'Count','Range','Mean','Start','End'});
    [xt_updated,yt_updated,xpeak,ypeak] = checking_overloading(T,xt_updated,yt_updated,yt,jj);
    if ~isnan(xpeak)
        store_ol_ids(jj) = xpeak;
        peak_store(jj,1:2)= [xpeak,ypeak];
    end
    jj = jj+1;
end
end