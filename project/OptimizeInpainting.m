function optimizeInpainting()
% Optimize the parameters of inPainting.

  %Initial parameters
  parameters.gauss_size = 10;
  parameters.gauss_sigma = 0.8;
  parameters.patch_size = 16;
  parameters.patch_frame_size = 8;
  parameters.td_abortbelow_stdev = 0.0001;
  parameters.td_abortbelow_stepsize = 0.01;
  parameters.validation = 0.2; 
  parameters.iterative = true; 
  parameters.max_iterations = 1; 
  parameters.abortbelow_change = 0.15; 
  
  % Result set
  final_parameters = parameters;
  cost = EvaluateInpaintingParameterized(parameters);
  
  while(true)

    %Working copy
    new_parameters = parameters;
    
    
    % Case +1
    new_parameters.abortbelow_change = getNextAbortBelowChange(parameters.abortbelow_change,1)
    new_cost_plus = EvaluateInpaintingParameterized(new_parameters) - cost
    % Case -1
    new_parameters.abortbelow_change = getNextAbortBelowChange(parameters.abortbelow_change,-1)
    new_cost_minus = EvaluateInpaintingParameterized(new_parameters) - cost

    if(new_cost_plus > 0 && new_cost_minus > 0)
        %Keep the old setting
    else
        final_parameters.abortbelow_change = getNextAbortBelowChange(parameters.abortbelow_change,-1*(new_cost_plus-new_cost_minus)/2);
    end
    
    parameters = final_parameters
    cost = EvaluateInpaintingParameterized(parameters)
    
  end

end

function new = getNextGaussSize(Value, Stepsize)
  
end

function new = getNextPatchSize(Value, Stepsize)

  
end

function new = getNextFrameSize(Value, Stepsize)

  
end

function new = getNextTDAbortBelowStep(Value, Stepsize)

  
end

function new = getNextTDAbortBelowStdev(Value, Stepsize)

  
end

function new = getNextValidation(Value, Stepsize)

end

function new = getNextMaxIterations(Value, Stepsize)

end

function new = getNextAbortBelowChange(Value, Stepsize)
  new = Value + Stepsize/100;
  if(new >= 1)
    new = 1-eps;
  end
  if(new <= 0)
      new = eps;
  end
end