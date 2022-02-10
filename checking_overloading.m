function [xt_updated,yt_updated,xpeak,ypeak] = checking_overloading(T,xt,yt,yt_ini,jj)
T_array = table2array(T);
range_vec = T_array(:,5)-T_array(:,4);
OL_idx = find(range_vec>1);


if isempty(OL_idx)
    disp('No more over-loading')
    
    xt_updated = 0;
    yt_updated = 0;
    xpeak = NaN;
    ypeak = NaN;
else
    OL_1 = T_array(OL_idx(1),4);
    ypeak = yt(OL_1);
    xpeak = xt(OL_1);
    yt_updated=yt(find(yt==ypeak)+1:end);
    xt_updated=xt(find(yt==ypeak)+1:end);
    
    % to remove the false overloading peaks, the criteria is to check the
    % nearest neighbor such that for over-loading peaks the neighbors peaks
    % should be lower than the overloading peaks.
    if jj<2.9  
        % initially the left neighbors peaks is empty. A criteria is set 
        % such that it won't throw an error
        peak_0 = 0;
        peak_1 = yt_ini(xpeak+2);
    else
        peak_0 = yt_ini(xpeak+1-2);
        peak_1 = yt_ini(xpeak+1+2);
    end
    
    % this is the criteria to check for the edge effect and false 
    % identification of the overloading peaks i.e., the last
    % peaks in the stress history cannot be identified as an overloading
    % peaks.
    if peak_0>ypeak
        if peak_1<ypeak
            ypeak = 0;
            disp('False peak is detected.')
        end
    end
end

end