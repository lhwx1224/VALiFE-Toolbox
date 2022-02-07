function [hist2,sigmamax, sigmamin, lcr, pd, ol, lcr_ol, ulcr_ol, sigmam] = nbpmf(x,N,var1,var2)
% BPMF generates bivariate joint probability mass functions from a given
% load time history X, for a given number of meshes of the normalized
% variables.
%
% USAGE: BPMF(X,N,VAR1,VAR2) takes in load time history X, number of bins
% for the PMF, N, and two load factors, namely, VAR1 and VAR2.
%
% INPUT:        X - Load time history
%               N - Number of bins to calculate BPMF
%               VAR1 - First load factor to consider
%               VAR2 - Second load factor to consider
%
% OUTPUT:       BPMF as a graph containing marginal probability mass
% functions of the two variables VAR1 and VAR2, and a two dimensional
% projection of the joint probalibity mass function of the two given load
% factors.
%
% Copyright by Hewenxuan Li 2020, University of Rhode Island.
if nargin == 2
    var1 = 'sigmamax';
    var2 = 'lcr';
elseif nargin == 4
else
    error('Check your input to the function!')
end

xbe = linspace(0,1,N);
ybe = linspace(0,1,N);
showbin = 'on';
Normalize = 'probability';
[sigmamax, sigmamin, lcr, pd, ol, lcr_ol, ulcr_ol, sigmam] = drivefactor(x);

% Assign variables according to the inputs:
if strcmp(var1,'sigmamax')
    varx = sigmamax(:,2)/(max(sigmamax(:,2))-min(sigmamax(:,2)));
    xlb = 'Maximum stress - \sigma_{max}';
    loc = 'west';
elseif strcmp(var1,'sigmamin')
    varx = sigmamin(:,2)/(max(sigmamin(:,2))-min(sigmamin(:,2)));
    xlb = 'Minimum stress - \sigma_{min}';
elseif strcmp(var1,'lcr')
    varx = lcr(:,2)/(max(lcr(:,2))-min(lcr(:,2)));
    xlb = 'Load cycle range - \Delta \sigma';
elseif strcmp(var1,'pd')
    varx = pd(:,2)/(max(pd(:,2))-min(pd(:,2)));
    xlb = 'Peak difference - \sigma_{max}^{(i)}-\sigma_{max}^{(i+1)}';
elseif strcmp(var1,'sigmam')
    varx = sigmam(:,2)/(max(sigmam(:,2))-min(sigmam(:,2)));
    xlb = 'Mean stress - \sigma_m';
elseif strcmp(var1,'ol')
    varx = ol(:,2)/(max(ol(:,2))-min(ol(:,2)));
    xlb = 'Overload - \sigma_{max}^{(i)}-\sigma_{max}^{(i+1)}>0';
else
    error('Check your first variable, VAR1!')
end

if strcmp(var2,'sigmamax')
    vary = sigmamax(:,2)/(max(sigmamax(:,2))-min(sigmamax(:,2)));
    ylb = 'Maximum stress - \sigma_{max}';
elseif strcmp(var2,'sigmamin')
    vary = sigmamin(:,2)/(max(sigmamin(:,2))-min(sigmamin(:,2)));
    ylb = 'Minimum stress - \sigma_{min}';
elseif strcmp(var2,'lcr')
    vary = lcr(:,2)/(max(lcr(:,2))-min(lcr(:,2)));
    ylb = 'Load cycle range - \Delta \sigma';
elseif strcmp(var2,'pd')
    vary = pd(:,2)/(max(pd(:,2))-min(pd(:,2)));
    ylb = 'Peak difference - \sigma_{max}^{(i)}-\sigma_{max}^{(i+1)}';
elseif strcmp(var2,'sigmam')
    vary = sigmam(:,2)/(max(sigmam(:,2))-min(sigmam(:,2)));
    ylb = 'Mean stress - \sigma_m';
elseif strcmp(var2,'ol')
    vary = ol(:,2)/(max(ol(:,2))-min(ol(:,2)));
    ylb = 'Overload - \sigma_{max}^{(i)}-\sigma_{max}^{(i+1)}>0';
elseif strcmp(var2,'lcr_ol') && strcmp(var1,'ol')
    vary = lcr_ol/(max(lcr_ol)-min(lcr_ol));
    ylb = 'Load cycle range corresponds to overload';
elseif strcmp(var2,'ulcr_ol') && strcmp(var1,'ol')
    vary = ulcr_ol(:,2)/(max(ulcr_ol(:,2))-min(ulcr_ol(:,2)));
    ylb = 'Unload cycle range corresponds to overload';
else
    error('Check your second variable, VAR2!')
end
% -------------------------------------------------------------------------
figure
ax1 = axes('Position',[0.14 0.68 0.5 0.27],'Box','on');
histogram(varx,'BinEdges',xbe,'Normalization','probability')
set(gca, 'xticklabel',[])
grid on
pbaspect([2 1 1])
xlim([min(xbe) max(xbe)])
ax2 = axes('Position',[0.14 0.11 0.5 0.54],'Box','on');
hist2 = histogram2(varx,vary,'XBinEdges', xbe, 'YBinEdges', ybe, 'FaceColor', 'flat','ShowEmptyBins',showbin,'Normalization',Normalize);
xlabel(xlb)
ylabel(ylb)

colorbar('location',loc,'axislocation','in')
view(0, 90)
pbaspect([1 1 1])
ax3 = axes('Position',[0.57 0.11 0.4782 0.54],'Box','on');
histogram(vary,'BinEdges',ybe,'Normalization','probability')
view(90,90)
set(gca, 'XDir','reverse')
set(gca, 'xticklabel',[])
xlim([min(ybe) max(ybe)])
pbaspect([2 1 1])
grid on

return
