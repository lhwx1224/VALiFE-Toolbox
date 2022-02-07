function RunSinglePredict(afgrow)
%Regiter the event "PredictFinished"
registerevent(afgrow, {'PredictFinished' @PredictFinished_Single_Handler});

afgrow.Visible = true; % Make the main GUI visible while running
afgrow.Units = 'UnitsMetric'; % Designate the unit system
afgrow.Model = 'aCenterThrough'; % Designate structure model 
afgrow.ConstAmplitudeSpectrum(0.0);
afgrow.SMF = 40;                 % Designate Stress Multiplication Factor
afgrow.CrackLengthC = 0.012;     % Designate Crack Length

afgrow.RunPredict;
return