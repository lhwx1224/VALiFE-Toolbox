function OLI = OLIndex_nc(Omega)
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
