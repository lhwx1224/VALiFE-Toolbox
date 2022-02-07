function [rfol,rfext] = rainflowol4(x,ct,olt,r)
% RAINFLOWOL returns a modified rainflow counting matrix which contains
% usual rainflow statistics and additional overload information. The
% rainflow matrix, c, from the MATLAB built-in function RAINFLOW is sorted
% according to the occurrence of each half cycle (the fourth column of the
% c matrix). Then, a series of criteria for extracting overload information
% is processed. The output, RFOL, is a extended rainflow matrix that
% contains overload criteria. 
% 
% Syntax: RFOLU = RAINFLOWOL(X,CT,OLT,R) returns rainflow overload matrix RFOLU of
% the input vector of time series X.
%
% Input:      X - m*1 time series vector
%            CT - Threshold number of cycles to escape the retardation zone
%           OLT - Overload threshold for adjusting the initial retardation
%                 reduction for the cycles after overloads
%             R - fraction of overload amplitude when cycles after overload
%                 equals to the equilibrium cycle, N_{eq}
% 
% For the ease of explanation, stress is described using S or \sigma in
% this code.
%
% Output:  RFOL - n*19 matrix whose columns are:
%                 1. Rainflow counts of cycles (or half cycles from rainflow)
%                 2. Stress range - (\Delta S)
%                 3. Mean stress - ((Smax + Smin)/2)
%                 4. Maximum stress - Smax
%                 5. Index of the starting reversal of a cycle (Istart)
%                 6. Index of the ending reversal of a cycle (Iend)
%                 7. OLDIST - Number of cycles affected by the naive
%                 overloads, the span of successive loading and successive
%                 unloading cycles (Iend- Istart)
%                 8. Logical vector indicating cycles that are possibly
%                 introduce overloads (A+B+C+D)
%                 9. Criterion A: overload in large loading phase
%                 10. Criterion B: overload in large unloading phase
%                 11. Criterion C: overload in local loading phase
%                 12. Criterion D: overload in local unloading phase
%                 13. Index of the peak of the designated overload
%                *14. Index of the peak position (all corrected to local
%                     maximum stress) 
%                *15. Mean stress corrected load amplitude (rainflow
%                     counted version) 
%                *16. Peak stress correspond to overloads (rainflow counted
%                     version) 
%                *17. Mean stress corrected load amplitude (range counted
%                     version) 
%                *18. Retarded stress amplitude (range counted version)
%                *19. Peak differences for each cycle (naive overload if
%                     greater than zero) 
%          RFEXT - extended rainflow matrix from which RFOL is obtained by
%                  imposing overload condition
% Copyright by Hewenxuan Li April 10, 2020, University of Rhode Island
%
% Modified versions:
% 1. overload matrix added April 2020
% 2  Retardation effect model added May 2020
% 3. Corrections to the descriptions (see * parts) May 2020
% 4. Fraction of residue stress when overload retardation effect ends added
% to the program; state of the processes added May 2020
% 5. Documentation, April 2021

% Initialization of the counting
if nargin == 1 % IF no overload threshold and cycle threshould designated
    olt = 1;   % Defualt overload threshold = 1
    ct = 100;  % Default cycle threshol = 100
    r = 0.1;   % Default percentage of intial overload == 0.1
elseif nargin == 3
    r = 0.1;   % Default percentage of intial overload == 0.1
elseif nargin == 4
elseif nargin > 4
    error('Please check the number of input!')
end

% Print the setup
fprintf('==================== Input Parameters =====================\n')
fprintf('Cycle Threshold CT (N_c): %d\n',ct)
fprintf('Overload Threshold OLT (rho_ol): %.2f\n',olt)
fprintf('Fraction of Residue Stress r: %.2f\n',r)
% Converting signal to reversals using sig2revs function
revs = sig2revs(x);         % Converting a time series/signals into reversals
% Rainflow count the reversals
c = rainflow(revs(:,3),'ext'); % Conduct classical rainflow counting
[~,I] = sort(c(:,4));          % Sort the result according to the starting indices of reversals
c = c(I,:);                    % Execute the sort to the randlow matrix
indx = transpose(1:1:size(c,1)); % Give an index to the identified reversals
% Quantities from the RFC function
is = c(:,4);                % Starting index
ie = c(:,5);                % Ending index
cycles = c(:,1);            % Cycle counts
smax = c(:,2)/2+c(:,3);     % Smax
nspan = abs(is-ie);         % Cycles in between each reversal
ol = nspan>1 | cycles==0.5; % Logical vector for overloads
lc = mod(is,2) == 1;        % Logical vector for loading half cycles
uc = mod(is,2) == 0;        % Logical vector for unloading half cycles
hc = cycles == 0.5;         % Logical vector for half cycle (cycles == 0.5)
% Overloads that are loading cycles
oll = ol & lc;

% Overloads that are unloading cycles
olu = ol & uc;

% Large scale OL
A = oll & hc;               % Large scale loading cycles
B = olu & hc;               % Large scale unloading cycles
% Local scale OL
C = oll & ~hc;              % Local loading cycles
D = olu & ~hc;              % Local unloading cycles
% Print the process
fprintf('=============== Overload Type A & B Identified ===============\n')
% Additional logical variable for real overloads
[sigmamax, sigmamin, lcr, ~, ~, ~, ~, ~] = drivefactor(x); % call drivefactor for Smax, Smin, and \Delta S
sigmamax(:,1) = 2:2:length(sigmamax(:,1))*2; % Assign indeces correspond to the maximum stress (even indeces)
sigmamax(sigmamax(:,2) < 0 ,2) = 0;
sar = sqrt(sigmamax(:,2).*lcr(:,2)/2);  % Mean stress adjusted stress amplitude (Sa = lcr/2)
sar = [sigmamax(:,1) sar];              % Add indeces to the sar vector
sar = vertcat(sar,sar);                 % Make duplicate of the 'sar' vector
[~,I] = sort(sar(:,1));                 % Sort it according to the index
sar = sar(I,:);                         % Duplicated and ordered 'sar' vector
% -------------------------------------------------------------------------
% Local overload identification C & D
% -------------------------------------------------------------------------
ismax = ie;                             % index correspond to the maximum stress (assign ending index here)
for i = 1:length(ie)        
    if mod(ismax(i),2) == 1             % For unloading cycles, assign starting index instead (unloading cycle ending index is odd)
        ismax(i) = is(i);               % If it is an unloading cycle, place the starting index as peak index
    end
end
ismaxs = ismax;                         % Index correspond to shifted maximum stress
for i = 1:length(ismaxs)
    if mod(ie(i),2) == 0
        ismaxs(i) = ismaxs(i) + 2;      % If the current overload is a loading sequence, make the shift to the next peak
        if ismaxs(i) > ie(end)
            ismaxs(i) = ismaxs(i) - 2;  % If the next peak is out of the sequence, make the shift zero
        end
    else
        ismaxs(i) = ismaxs(i) - 2;      % If the current overload is a unloading sequence, make the shift to the previous peak
        if ismaxs(i) == 0
            ismaxs(i) = ismaxs(i) + 2;  % If the next previous peak is out of the sequence, make the shift zero
        end
    end
end
% if the current peak is larger than the peak being compared, assign TRUE
% to this condition.
for i = 1:length(ismax)
    CDcon(i) = sigmamax(sigmamax(:,1)==ismax(i),2)>sigmamax(sigmamax(:,1)==ismaxs(i),2); 
end
% This condition determines whether the peak (Smax) prior to a local unloading sequence
% is larger than the starting point (is) of the unloading sequence. Also, 
% it determines whether the peak following a local loading sequence is
% smaller than the ending peak of this loading sequence.
if size(CDcon,1) < size(CDcon,2)
    CDcon = logical(transpose(CDcon));
end

% Whether the current ending max larger than the next max?
C = C & CDcon;
D = D & CDcon;

% Print the process
fprintf('=============== Overload Type C & D Identified ===============\n')
% Construct the extended rainflow matrix:
% Col1: cycle counts; Col2: cycle range; Col3: mean stress; Col4: Smax;
% Col5: starting index of cycle; Col6: ending index of cycle; Col7: cycle
% span; Col8: overload logic (if overload - 1); Col9: A logic; Col10: B
% logic; Col11: C logic; Col12: D logic.
rfext = [cycles c(:,2) c(:,3) smax is ie nspan ol A B C D];
% Find true overload by imposing the Union of A, B, C, and D
trueol = A | B | C | D;                    % True overload condition 

% Add A,B,C,and D to obtain criteria for true ol (Col13: OL event)
rfext = [rfext rfext(:,9)+rfext(:,10)+rfext(:,11)+rfext(:,12)];

% sigmamax2 = vertcat(sigmamax,sigmamax);           % Smax
% [~,I] = sort(sigmamax2(:,1));
% sigmamax2 = sigmamax2(I,:);

olindx = zeros(size(rfext,1),1);                  % New index adjusted for correct overload position
olamp = zeros(size(rfext,1),1);                   % Initialize overload amplitude
olp = zeros(size(rfext,1),1);                     % Initialize overload peak value
  
% ======== Desginate the Overloads According to the Index =========
% Initiate finding overload for loop
for i = 1:size(rfext,1)
    if rfext(i,9) == 1 || rfext(i,11) == 1        % Criteria A & C
        olindx(i) = rfext(i,6);
        olamp(i) = sqrt(rfext(i,4)*rfext(i,2)/2); % Overload amplitude through Walker Equation
        olp(i) = rfext(i,4);                      % Overload peak = Smax(ol(j))
    elseif rfext(i,10) == 1 || rfext(i,12) == 1   % Criteria B & D
        olindx(i) = rfext(i,5);
        olamp(i) = sqrt(rfext(i,4)*rfext(i,2)/2);
        olp(i) = rfext(i,4);
    else                                          % If not overload
        if rfext(i,8) == 1                        % If it spans more than one cycle
            if mod(rfext(i,5),2) == 1               % If it is a loading cycle, assign the index to the starting point
                olindx(i) = rfext(i,6);
            else                                    % if it is an unloading cycle, assign the index to the ending point
                olindx(i) = rfext(i,5);
            end
        else                                      % if it spans only one cycle
            if mod(rfext(i,5),2) == 1               % If it is a loading cycle
                olindx(i) = rfext(i,6);
            else                                    % if it is an unloading cycle
                olindx(i) = rfext(i,5);
            end
        end
        olamp(i) = sqrt(rfext(i,4)*rfext(i,2)/2);   % calculate amplitude *(called overload amplitude)
        olp(i) = rfext(i,4);             % Calculate the peak value *(called overload peak value)
    end
end
%Note that the olamp and olp are genericly named after overloads but
%it should be the adjusted stress amplitude and the maximum stress. *(see the asterisked lines above)
rfext = [rfext olindx olamp olp];                % Col14: olindx; Col15: olamp; Col16: olp
[~,dupindx,~] = unique(rfext(:,14));             % Retain only the unique overloads
rfext = rfext(dupindx,:);

sar_lcr = sar(rfext(:,14),2);                    % Retain the loading cycle range (search in sar)
rfext = [rfext sar_lcr];                         % Add it to extended rainflow matrix (Col17)
%--------------------------------------------------------------------------
% Overload stress amplitude, overload amplitude, maximum number of affected
% cycles.
%--------------------------------------------------------------------------
sarol = zeros(size(rfext,1),1);                  
sara = zeros(size(rfext,1),1);
% pd is referred to as the peak difference (difference between two consecutive load cycle ranges)
pd = rfext(1:end-1,17) - rfext(2:end,17); % column 15 is used if rainflow damage is assumed, column 17 is used if lcr damage is assumed
pd = [pd; 0];                             % Append zero to match the matrix size
% if nargin == 3
%     r = 0.1;
% end
N = 0;                                    % Initate the overload counter (exceed which the ol effect is negated!)
% C = 100;
% A = 0.5; 
j = 0;                                    % Initate the overload index
for i = 1:size(rfext,1)
    if rfext(i,13) == 1 && pd(i) > 0      % if ith cycle is overload with a positive pd
        N = 1;                            % Start counting cycles affected by overload N
        j = j + 1;                        % Start counting the index of the overload
        sara(i) = rfext(i,17);            % Set sara corresponding to the current ol
        sol(j) = pd(i);                   % Overload amplitude = positive pd
        if i == size(rfext,1)                   % If the end of rfmatrix
            olr(j) = rfext(i,17)/rfext(i,17);   % set olr = 1
        else
            olr(j) = rfext(i,17)/rfext(i+1,17); % otherwize overload ratio is defined as the ratio between two consecutive sar_lcr
        end
        Namax(j) = ct*(exp(olr(j)-1)-1);        % Calculate the maximum number of cycles to be adjusted
    else
        if N~=0                                 % If not overload (followed by an overload)
            sara(i) = rfext(i,17) - olt*sol(j)*exp(N/Namax(j)*log(r)); % adjust the stress amplitude
            N = N + 1;                                                 % Count the cycles affected by overload - N
            if N>=Namax(j)                                             % If N is over the range of load sequence effect
                N = 0;                                                 % RESET N!
            end
        else
            sara(i) = rfext(i,17);                                     % If no overload affected region, leave as is
        end
        pd(i) = pd(i);                                                 % Keep pd the same 
    end
    sarol(i) = rfext(i,17);                                            % sarol 
end

% Print the process
fprintf('=============== Retardation Correction Done ===============\n')
fprintf('\n')

sara(sara < 0) = 0;
rfext = [rfext sara pd];                     % add adjusted stress amp and pd to the extended rfmatrix (Col 18 19)
rfol = rfext(rfext(:,13) == 1 & pd>0,:);     % Extract overload only matrix, call it rfol
rfext = real(rfext);                         %
rfol = real(rfol);                           %
return