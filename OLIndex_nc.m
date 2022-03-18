function OLI = OLIndex_nc(Omega, rol)
% OLIndex_nc returns the identified overloads from the overload candidate
% matrix Omega. 
%
% syntax: OLI = OLIndex_nc(Omega)
%
% input: Omega - Overload candidate index matrix
%
% output: OLI - Overload index matrix
%
% Copyright by Hewenxuan Li, hewenxuan_li@uri.edu
% Created on 2/11/2022

[m, ~] = size(Omega);
% omegam = Omega(m,:);

%% ======================== FORWARD RUN ================================

% ------------------------------------------------------------------------
%                ROW-WISE WEIGHT THE CANDIDIATE MATRIX
% ------------------------------------------------------------------------
w = m:-1:1;
Omega_w = Omega.*w';

% ------------------------------------------------------------------------
%                CONDUCT ROW-WISE SUMMATION: Omega_s
% ------------------------------------------------------------------------
Omega_s = sum(Omega_w, 1);

% ------------------------------------------------------------------------
%         GET DIFFERENCE OF THE TWO CONSECUTIVE WEIGHTED CANDIDATES
% ------------------------------------------------------------------------
dOmega_s = Omega_s(2:end) - Omega_s(1:end-1);

% ------------------------------------------------------------------------
%     OVERLOAD INDICES FROM NEGATIVE DIFFERENCE OF WEIGHTED CANDIDATES
% ------------------------------------------------------------------------
oli = dOmega_s < 0;

% ------------------------------------------------------------------------
%                         OVERLOAD INDICES MATRIX
% ------------------------------------------------------------------------
OLI = Omega.*[double(oli) 0];

%% ======================= BACKWARD SIFT ===============================

% ------------------------------------------------------------------------
%                ROW-WISE WEIGHT THE CANDIDIATE MATRIX
% ------------------------------------------------------------------------
Omega_w = OLI;

% ------------------------------------------------------------------------
%                CONDUCT ROW-WISE SUMMATION: Omega_s
% ------------------------------------------------------------------------
Omega_s = sum(Omega_w, 1);
Omega_s = [1:length(Omega_s); Omega_s];
Omega_s_ol = Omega_s(1,Omega_s(2,:) == 1);

% ------------------------------------------------------------------------
%         GET DIFFERENCE OF THE TWO CONSECUTIVE WEIGHTED CANDIDATES
% ------------------------------------------------------------------------
dOmega_s_ol = Omega_s_ol(:,2:end) - Omega_s_ol(:,1:end-1);
dOmega_s_ol = [nan(1,rol), dOmega_s_ol];

neg_indx = Omega_s_ol(1,dOmega_s_ol <= rol);

OLI(:, neg_indx) = zeros(size(OLI,1),length(neg_indx));

