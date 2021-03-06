function OLI = OLIndx_pd(x, Nbins, OLmetric)
% OLIndx_pd uses PEAK DIFFERENCE information to identify overloads embeded
% in a variable amplitude loading. 
% 
% syntax: OLI = OLIndx_pd(x, Nbins, OLmetric)
%
% input: x - stress reversals
%        Nbins - # of bins used to classfy the levels of overloads
%        OLmetric - metric used to identify overloads
%                   'pd' - peak difference, sigmamax(i) - sigmamax(i + 1)
%                   'lcr' - loading cycle range, sigmamax(i) - sigmamin(i)
%                   'prouct' - sqrt(pd*lcr), the geometric average of the
%                   peak difference and loading cycle range.
%
% VALiFE-toolbox v0.0
% Copyright by Hewenxuan Li, hewenxuan_li@uri.edu
% Created on 2/11/2022

addpath('OS')                       % Load options
[Markers, ~, Mycolors] = mystyle(); % Define visualization style
DefColor = Mycolors.defaultcolor;   % Define default MATLAB colors

% Check the input size: default options Nbins = 2; OLmetric = 'product'.
if nargin < 1
    smin = [0 0 0 0 0 0 0 0 0]';
    smax = [3 4 5 1 4 3 5 2 1.8]';
    x = pv2revs(smax, smin);
    x = [x(:,2); 0];
    Nbins = 2;
    OLmetric = 'product';
elseif nargin < 2
    Nbins = 2;
    OLmetric = 'product';
elseif nargin < 3
    OLmetric = 'product';
end
tic
xindx = 1:length(x);                % index used for reversal id

% ------------------------------------------------------------------------
%                IDENTIFY OVERLOADS USING PD ALGORITHM
% ------------------------------------------------------------------------
% call drivefactor for Smax, Smin, lcr, pd, and ol
% Maximum stress, minimum stress, loading cycle range, peak difference,
% peak-difference-related overload candidates:
[sigmamax, sigmamin, lcr, pd, ol, ~, ~, ~] = drivefactor(x, 'true'); 

% ------------------------------------------------------------------------
%                SIFTING OVERLOADS ACCORDING TO THE LCR
% ------------------------------------------------------------------------
switch OLmetric
    case 'pd'
        pd_ol_min = min(ol(:,2));
        pd_ol_max = max(ol(:,2));
        pd_ol_bin_edges = linspace(pd_ol_min,pd_ol_max,Nbins + 1);
        edges = pd_ol_bin_edges;
        metric = pd(1:end,:);
        Metric_text = 'Peak Difference --- $\Delta\sigma_{\max}$';

    case 'lcr'
        lcr_min = min(lcr(1:end-1,2));
        lcr_max = max(lcr(1:end-1,2));
        lcr_bin_edges = linspace(lcr_min, lcr_max, Nbins + 1);
        edges = lcr_bin_edges;
        metric = lcr(1:end-1,:);
        Metric_text = 'Load Cycle Range --- $\Delta\sigma^{+}$';

    case 'product'
        prod = sqrt(lcr(1:end-1,2).*abs(pd(:,2)));
        prod = [pd(1:size(prod,1),1), prod];
        prod_min = min(prod(:,2));
        prod_max = max(prod(:,2));
        prod_bin_edges = linspace(prod_min,prod_max,Nbins + 1);
        edges = prod_bin_edges;
        metric = prod(1:end,:);
        Metric_text = 'Geometric Mean --- $\sqrt{\Delta\sigma^{+}\Delta\sigma_{\max}}$';
end

% ALLOCATE MEMORY FOR THE OVERLOAD INDEX
OLI = zeros(Nbins,size(pd,1));
% SIFT OUT THE OVERLOAD BY LEVELS OF METRICS

% FOR in total Nbins number of subsections of metric, 
for i = 1:Nbins
    % Find the peak such that the metric falls into each bin
    OLI(i, :) = metric(:,2) >= edges(i) & metric(:,2) < edges(i+1) & pd(:,2) > 0; 
    % IF the last bin, consider the upper bound of the last bin as well
    if i == Nbins
        OLI(i, :) = metric(:,2) >= edges(i) & metric(:,2) <= edges(i+1) & pd(:,2) > 0;
    end
    % END IF
end % END FOR

% ------------------------------------------------------------------------
%          POST-PROCESSING THE OVERLOAD IDENTIFICATION RESULTS
% ------------------------------------------------------------------------

% MAKE OVERLOAD INDICES INTO LOGICAL ARRAYS
OLI = logical([OLI zeros(size(OLI,1),1)]);
% FLIP THE OVERLOAD INDICES S.T. THE ROWS OF INDICES ARE IN ACCORDANCE WITH
% AN INCREASING OL AMPLITUDE
OLI = flipud(OLI);
% DELETE EMPTY BINS
OLIsum = sum(OLI, 2);
OLIempty = OLIsum == 0;
OLI(OLIempty, :) = [];
p = cell(size(OLI,1),1);
% IF NO OUTPUT, plot a diagram
if nargout == 0
    figure(1),clf
    pp = plot(xindx,x,'color',DefColor{1});   % Plot the original reversals
    hold on 
    for i = 1:size(OLI,1)
        % plot the identified overload on top of the reversals
            p{i} = plot(sigmamax(OLI(i,:),1), sigmamax(OLI(i,:),2), 'v',...
            'markerfacecolor', DefColor{i}, 'MarkerEdgeColor', DefColor{i});
    end
    % Designate a pool of legends
    legends = {'OL Level 1','OL Level 2','OL Level 3','OL Level 4',...
        'OL Level 5','OL Level 6','OL Level 7','OL Level 8',...
        'OL Level 9','OL Level 10'};
    legend([pp, p{:}],{'Reversals',legends{1:length(p)}}) % Legend
    xlabel('Reservsals')          % xlabel 
    ylabel('Stress Magnitude')    % ylabel
    xticks(2:2:length(x));
    axis tight
    grid on
    pbaspect([2 1 1])
    title(['Overload ID Result using ', Metric_text])
end
toc
return