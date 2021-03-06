function OLI = OLIndex(Omega, rol)
% OLIndex returns the identified overloads from the overload candidate
% matrix Omega. 
%
% syntax: OLI = OLIndex(Omega, rol)
%
% input: Omega - Overload candidate index matrix
%
% output: OLI - Overload index matrix
%
% Copyright by Hewenxuan Li, hewenxuan_li@uri.edu
% Created on 2/7/2022
% Modified on:
% 2/12/2022 and 2/13/2022 - got rid of for loops and used vector difference
%                           and comparison


for i = 1:rol
    % --------------------------------------------------------------------
    %         Forward run using the vectorial difference metric
    % --------------------------------------------------------------------
    
    % -- Pad the Omega matrix to accommodate the column-wise difference --
    if i == 1
        % Assign temporary Omega matrix for the first run using the input
        % Omega matrix
        Omega_temp = [Omega, repmat(Omega(:,end),1,i)];
    else 
        % Assign temporary Omega matrix for the rest of the runs using the
        % previously obtained OLI matrix
        Omega_temp = [OLI, repmat(OLI(:,end),1,i)];
    end
    % Row-wise summation matrix of the Omega using the new Omega_temp
    omega_s = sum(Omega_temp, 1);
    % Compute domega vector using the new sum
    domega = omega_s(i+1:end) - omega_s(1:end-i);
    % Overload indices when differnece of the candidate sum is negative
    oli = domega < 0;
    % Vectorial Hadamard product to retain the valid candidate
    OLI = oli.*Omega;

    % --------------------------------------------------------------------
    %              Backward run with a limited window size
    % --------------------------------------------------------------------
    % Locate the overloads identified from the forward run
    OLI_ol = [1:length(oli);oli];             % Indexed overload id matrix
    oli_ol = OLI_ol(1, OLI_ol(2,:) == 1);     % Retain the index of OL
    oli_ol = [oli_ol; sum(OLI(:,oli_ol), 1)]; % Obtain the sum of the OL in the OLI matrix
%     oli_ol = [oli_ol(:,1), oli_ol];
    % Overload level difference and distance difference matrix
    dpli_ol = oli_ol(:,2:end) - oli_ol(:, 1:end-1);   
    % Find the ones that are less than the defined rol and is a previously
    % identified overload and use them as negating indices.
    flag = oli_ol(1,dpli_ol(1,:) == i & dpli_ol(2,:) < 0) + i; 
    % Negate the identified non-overloads
    OLI(:,flag) = zeros(size(OLI,1),length(flag));
end

% LEGACY VERSION 2/7/2022
% [m, n] = size(Omega);
% % Forward run
% omegam = Omega(m,:);
% OLI = Omega;
% for j = 1 : n-rol
%     nf = 0;
%     k = 1;
%     while nf == 0 && k <= rol
%         if omegam(j + k) == 1 && k <= rol
%             nf = 1;
%         end
%         k = k + 1;
%     end
%     k = k - 1;
%     if sum(Omega(:, j)) < sum(Omega(:, j + k))
%         OLI(:,j) = zeros(m, 1);
%     end
% end
% 
% % Backward run
% for j = n : -1 : n-2*rol
%     nf = 0;
%     k = 1;
%     while nf == 0 && k <= rol
%         if omegam(j - k) == 1 && k <= rol
%             nf = 1;
%         end
%         k = k + 1;
%     end
%     k = k - 1;
%     if sum(Omega(:, j)) < sum(Omega(:, j - k))
%         OLI(:,j) = zeros(m, 1);
%     end
% end