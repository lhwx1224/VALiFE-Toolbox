function spectrum = sig2spectra(x,spectrum_name,model)
% Convert a evenly sampled continuous time signal into max-min form which
% is compatible with AFGROW spectrum maneger (if model == 'AFGROW'). 
% For generic MATLAB application, e.g., the state-space model, model == 'GENERIC'
% 
% INPUT: x - scalar time series (a vector)
%        spectrum_name - file name for the signal being converted
%        model - application environment selection, if it is used in
%        AFGROW, model == 'AFGROW'. Default is AFGROW.
%
% OUTPUT: saved files named spectrum_name_spectrum.xls & .mat
%
% Created by Hewenxuan Li, Nov 2019
% Modification: 
% v1.1-Dec 2019 - AFGROW uses max-min sequence to reconstruct the spectrum
% not min-max as it was defined in the BPMF paper. Spectrum matrix now
% changed to max-min sense for AFGROW application.
% 
% v1.2-Sep 2021 - drivefactor function replaces the conversion function

if nargin == 2
    model = 'AFGROW';
    disp('AFGROW model default max-min sequence is selected!')
end

flag = ischar(spectrum_name);

if flag == 0
    error('The spectrum_name has to be a string!')
end

% Get the extrema of the load time history
[smax,smin] = drivefactor(x);
sigmamin = smin(:,2);
sigmamax = smax(:,2);
if length(sigmamin) > 34464
    sigmamin = sigmamin(1:34464);
    sigmamax = sigmamax(1:34464);
end
if model == 'AFGROW'
% Convert the reversal info into a matrix (AFGROW compatible)
spectrum = [sigmamax(1:end-1) sigmamin(2:end) ones(length(sigmamin)-1,1)];
elseif model == 'GENERIC'
% Convert the reversal info into a matrix (Generic MATLAB application)
    spectrum = [sigmamax sigmamin];
end

if nargout == 0
    % Save the chaotic spectrum data
    disp(['The name of the saved file will be: ',spectrum_name,'_spectrum'])
    
    writematrix(spectrum,[spectrum_name,'_spectrum.xls']);
    save([spectrum_name,'_spectrum.mat'], 'spectrum')
end
% Reconstruct the reversals of the chaotic load time hisoty in to a vector
% form (for plotting and interpolation)
% loading  = [sigmamin sigmamax];
% l1 = [transpose(1:2:2*size(loading,1)) loading(:,1)];
% l2 = [transpose(2:2:2*size(loading,1)) loading(:,2)];
% chaotic_load = [l1; l2];
% [~,indx] = sort(chaotic_load(:,1),1);
% chaotic_load = chaotic_load(indx,:);    % Reversal sequence of the chaotic load
% save('chaotic_load.mat','chaotic_load') % Save as chaotic+load 
% % Perform random permutation to the chaotic load time history
% ploading = loading(randperm(size(loading,1)),:);    % Randomly permute the load cycle ranges
% perm_spectrum = [ploading(:,2) ploading(:,1) ones(size(ploading,1),1)]; % Generate the reversals into a AFGROW friendly matrix
% writematrix(perm_spectrum,'perm_spectrum.xls');
% save('perm_spectrum.mat', 'perm_spectrum')
% 
% save('loading.mat','loading')
% save('ploading.mat','ploading')

return