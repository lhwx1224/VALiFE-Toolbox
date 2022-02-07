% RUN MULTIPLE PEWSIXRIONS
function RunMultiPredict(afgrow, inputArr)
    global inputs;
    global globalAfgrow;
    globalAfgrow = afgrow;
    inputs = inputArr;
    registerevent(afgrow, {'PredictFinished' @PredictFinished_Multi_Handler});
   
    afgrow.Visible = true; % Make the main GUI visible while running
    afgrow.Units = 'UnitsMetric'; % Designate the unit system
    afgrow.Model = 'aCenterThrough'; % Designate structure model 
    afgrow.ConstAmplitudeSpectrum(0.0);
    afgrow.SMF = 40;
    afgrow.CrackLengthC = inputArr(1);
    
    afgrow.RunPredict;
   
return