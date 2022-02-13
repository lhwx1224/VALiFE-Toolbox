function Omega = OLSpectrum(x, reversals, cumulative)

% OLSpectrum identifies all possible overload candidates for a given load
% stress cycle history. 
% 
% syntax: Omega = OLSpectrum(x, reversals, cumulative)
% 
% input: x - stress reversals or load time histories (stress-time hisotries)
%        reversals - logical, 1 - x is a reversal vector and 0 - x is a
%        load-time history.
%        cumulative - logical, 1 - the overload index matrix is obtained
%        from cumulatively save the previous identified overloads. 0 - each
%        row of the overload index matrix is obtianed by identifying and
%        saving only the newly identified overloads.
%
% output: Omega - overload candidate index matrix whose elements correspond
%                 to peak indecies. the matrix is composed of either 1 or 0
%                 and 1 indicates the corresponding peaks is an overload
%                 candidate.
%
% Copyright by Hewenxuan Li, hewenxuan_li@uri.edu
% Created on 2/7/2022

if nargin < 1
    % -------------------- Test reversal history -------------------------
    smin = [0 0 0 0 0 0 0 0 0]';
    smax = [3 4 5 1 4 3 5 2 2]';
    x = pv2revs(smax, smin);
    x = [x(:,2); 0];
    plot(x)
    reversals = 1;
    cumulative = 0;
    % --------------------------------------------------------------------
elseif nargin < 2
    reversals = 1;
    cumulative = 1;
elseif nargin < 3
    cumulative = 1;
end

% if ~reversals
%     % Converting signal to reversals using sig2revs function
%     revs = sig2revs(x);         % Converting a time series/signals into reversals
%     % Rainflow count the reversals
%     RF = rainflow(revs(:,3),'ext'); % Conduct MATLAB rainflow counting
% else
%     RF = rainflow(x);
% end
% [~,I] = sort(RF(:,4));          % Sort the result according to the starting indices of reversals
% RF = RF(I,:);                    % Execute the sort to the rainflow matrix
% indx = transpose(1:1:size(RF,1)); % Give an index to the identified reversals
% Quantities from the RFC function
% is = RF(:,4);                % Starting index
% ie = RF(:,5);                % Ending index
% cycles = RF(:,1);            % Cycle counts
% smax = RF(:,2)/2+RF(:,3);     % Smax
% irange = abs(is-ie);         % Cycles in between each reversal
% ol = irange>1 & cycles==0.5; % Logical vector for overloads
% lc = mod(is,2) == 1;        % Logical vector for loading half cycles
% uc = mod(is,2) == 0;        % Logical vector for unloading half cycles
% hc = cycles == 0.5;         % Logical vector for half cycle (cycles == 0.5)
% ------------------------------------------------------------------------
% Compute the Sigma_max Sigma_min, Sa
% ------------------------------------------------------------------------
[sigmamax, ~, ~, ~, ~, ~, ~, ~] = drivefactor(x, 'true'); % call drivefactor for Smax, Smin, and \Delta S
% sigmamax(:,1) = 2:2:length(sigmamax(:,1))*2; % Assign indeces correspond to the maximum stress (even indeces)
% sigmamax(sigmamax(:,2) < 0 ,2) = 0;
% sar = sqrt(sigmamax(:,2).*lcr(:,2)/2);  % Mean stress adjusted stress amplitude (Sa = lcr/2)
% sar = [sigmamax(:,1) sar];              % Add indeces to the sar vector
% sar = vertcat(sar,sar);                 % Make duplicate of the 'sar' vector
% [~,I] = sort(sar(:,1));                 % Sort it according to the index
% sar = sar(I,:);                         % Duplicated and ordered 'sar' vector

% ------------------------------------------------------------------------
% Iterative Identification of OVERLOAD CANDIDATES
% ------------------------------------------------------------------------
% Figure for the iterative identification of overload
figure(2),clf
plot(x)
hold on
% --------- Initiate the overload identification iteration ---------------
rng(1);
omega_temp = zeros(1, size(sigmamax,1)); % Temporary overload identifier vector
Omega = randn(1,size(sigmamax,1)); % Temporary overload identifier vector
dOmega = 1;
count = 0;
legends = [];
% ---- Begin the while loop unless two consecutive rows are identical ----
while dOmega ~= 0
    if ~reversals
        % Converting signal to reversals using sig2revs function
        revs = sig2revs(x);         % Converting a time series/signals into reversals
        % Rainflow count the reversals
        RF = rainflow(revs(:,3),'ext'); % Conduct MATLAB rainflow counting
    else
        RF = rainflow(x);
    end
    [~,I] = sort(RF(:,4));             % Sort the result according to the starting indices of reversals
    RF = RF(I,:);                      % Execute the sort to the rainflow matrix
    RF = [RF, RF(:,5) - RF(:,4) ~= 1]; % Calculate the distance between the starting index and the ending index of the half cycle
    RF = [(1:size(RF,1))', RF];        % Append index to the rainflow matrix
    RFOLC = RF(RF(:,7) == 1,:);        % Define the rainflow overlaod candidate matrix 
    if cumulative
        omega_temp(RFOLC(:,5)/2) = 1;     % Keep the previous overload index
    else
        omega_temp = zeros(1, size(sigmamax,1)); % Reset temporary overload identifier vector
        omega_temp(RFOLC(:,5)/2) = 1;
    end
%     RFOLC = RF(RF(:,7) == 1, :);
    for i = 1:size(RFOLC,1)
        if mod(RFOLC(i,5),2) == 0 % IF It is a unloading half cycle
%             x(RF(RFOLC(i,1),5)) = min(sigmamax(:,2));
            x(RFOLC(i,5)) = min(sigmamax(:,2));
        elseif mod(RFOLC(i,5),2) ~= 0 % IF It is a loading half cycle
%             x(RF(RFOLC(i,1),6)) = min(sigmamax(:,2));
            x(RFOLC(i,6)) = min(sigmamax(:,2));
        end
    end
    Omega = [Omega; omega_temp];
    dOmega = sum(abs(Omega(end,:) - Omega(end - 1,:)));
    count = count + 1;
    legends = [legends, strcat("Iteration #",num2str(count))];
    plot(x)
end

legend(string(legends))
pbaspect([2 1 1])
Omega(1,:) = [];

if ~cumulative
    Omega(end-1:end,:) = [];
end

figure(1),clf
imagesc(Omega)
pbaspect([2 1 1])

return