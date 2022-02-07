function Omega = OLSpectrum(x, reversals)

% -------------------- Test reversal history ----------------------------
% smin = [0 0 0 0 0 0 0 0 0]';
% smax = [3 4 5 1 4 3 5 2 2]';
% x = pv2revs(smax, smin);
% x = [x(:,2); 0];
% plot(x)
% -----------------------------------------------------------------------

if ~reversals
    % Converting signal to reversals using sig2revs function
    revs = sig2revs(x);         % Converting a time series/signals into reversals
    % Rainflow count the reversals
    RF = rainflow(revs(:,3),'ext'); % Conduct MATLAB rainflow counting
else
    RF = rainflow(x);
end
[~,I] = sort(RF(:,4));          % Sort the result according to the starting indices of reversals
RF = RF(I,:);                    % Execute the sort to the randlow matrix
indx = transpose(1:1:size(RF,1)); % Give an index to the identified reversals
% Quantities from the RFC function
is = RF(:,4);                % Starting index
ie = RF(:,5);                % Ending index
cycles = RF(:,1);            % Cycle counts
smax = RF(:,2)/2+RF(:,3);     % Smax
irange = abs(is-ie);         % Cycles in between each reversal
ol = irange>1 & cycles==0.5; % Logical vector for overloads
lc = mod(is,2) == 1;        % Logical vector for loading half cycles
uc = mod(is,2) == 0;        % Logical vector for unloading half cycles
hc = cycles == 0.5;         % Logical vector for half cycle (cycles == 0.5)
% ------------------------------------------------------------------------
% Compute the Sigma_max Sigma_min, Sa
% ------------------------------------------------------------------------
[sigmamax, sigmamin, lcr, ~, ~, ~, ~, ~] = drivefactor(x, 'true'); % call drivefactor for Smax, Smin, and \Delta S
% sigmamax(:,1) = 2:2:length(sigmamax(:,1))*2; % Assign indeces correspond to the maximum stress (even indeces)
sigmamax(sigmamax(:,2) < 0 ,2) = 0;
sar = sqrt(sigmamax(:,2).*lcr(:,2)/2);  % Mean stress adjusted stress amplitude (Sa = lcr/2)
sar = [sigmamax(:,1) sar];              % Add indeces to the sar vector
sar = vertcat(sar,sar);                 % Make duplicate of the 'sar' vector
[~,I] = sort(sar(:,1));                 % Sort it according to the index
sar = sar(I,:);                         % Duplicated and ordered 'sar' vector

% ------------------------------------------------------------------------
% Iterative Identification of OVERLOAD CANDIDATES
% ------------------------------------------------------------------------
figure(2),clf
plot(x)
hold on
rng(1);
omega_temp = zeros(1, size(sigmamax,1)); % Temporary overload identifier vector
Omega = randn(1,size(sigmamax,1)); % Temporary overload identifier vector
dOmega = 1;
count = 0;
legends = [];
while dOmega ~= 0
    if ~reversals
        % Converting signal to reversals using sig2revs function
        revs = sig2revs(x);         % Converting a time series/signals into reversals
        % Rainflow count the reversals
        RF = rainflow(revs(:,3),'ext'); % Conduct MATLAB rainflow counting
    else
        RF = rainflow(x);
    end
    [~,I] = sort(RF(:,4));          % Sort the result according to the starting indices of reversals
    RF = RF(I,:);                    % Execute the sort to the randlow matrix
    RF = [RF, RF(:,5) - RF(:,4) ~= 1];
    RF = [(1:size(RF,1))', RF];
    OLCindx = RF(RF(:,7) == 1,5);
    omega_temp(OLCindx/2) = 1;
    RFOLC = RF(RF(:,7) == 1, :);
    for i = 1:size(RFOLC,1)
        if mod(RFOLC(i,5),2) == 0 % IF It is a unloading half cycle
        x(RF(RFOLC(i,1),5)) = 0.01;
        elseif mod(RFOLC(i,5),2) ~= 0 % IF It is a loading half cycle
        x(RF(RFOLC(i,1),6)) = 0.01;
        end
    end
    Omega = [Omega; omega_temp];
    dOmega = sum(Omega(end,:) - Omega(end - 1,:));
    count = count + 1;
    legends = [legends, strcat("Iteration #",num2str(count))];
    plot(x)
end
legend(string(legends))
Omega(1,:) = [];
figure(1),clf
imagesc(Omega)

return