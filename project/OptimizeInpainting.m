% Optimize the parameters of inPainting.
function optimizeInpainting()

  % Set random seet to get reproducable results
  rand('seed', 12345);

  % Initial parameters
  parameters = struct;
  parameters.gauss_size = 10;
  parameters.gauss_sigma = 0.8;
  parameters.patch_size = 4;
  parameters.patch_frame_size = 8;
  parameters.td_abortbelow_stdev = 0.0001;
  parameters.td_abortbelow_stepsize = 0.01;
  parameters.td_middle = 10;
  parameters.validation = 0.2; 
  parameters.iterative = true; 
  parameters.max_iterations = 1; 
  parameters.abortbelow_change = 0.15; 
  
  % Result set
  final_parameters = parameters;
  cost = EvaluateInpaintingParameterized(parameters);
  
  while(true)
    final_parameters.gauss_size             = gradientDescent(1, @getNextGaussSize, parameters, cost);
    final_parameters.gauss_sigma            = gradientDescent(2, @getNextGaussSigma, parameters, cost);
    final_parameters.patch_size             = gradientDescent(3, @getNextPatchSize, parameters, cost);
    final_parameters.patch_frame_size       = gradientDescent(4, @getNextFrameSize, parameters, cost);
    final_parameters.td_abortbelow_stdev    = gradientDescent(5, @getNextTDAbortBelowStdev, parameters, cost);
    final_parameters.td_abortbelow_stepsize = gradientDescent(6, @getNextTDAbortBelowStep, parameters, cost);
    final_parameters.td_middle              = gradientDescent(7, @getNextTDMiddle, parameters, cost);
    final_parameters.validation             = gradientDescent(8, @getNextValidation, parameters, cost);
    %Dont iterate over bool 'iterative'
    final_parameters.max_iterations         = gradientDescent(10, @getNextMaxIterations, parameters, cost);
    final_parameters.abortbelow_change      = gradientDescent(11, @getNextAbortBelowChange, parameters, cost);    
    
    parameters = final_parameters
    cost = EvaluateInpaintingParameterized(parameters);
  end

end

function new_value = gradientDescent(index, getNext, parameters, cost);
  learning_rate = 100;

  fields = {'gauss_size', ...
            'gauss_sigma', ...
            'patch_size', ...
            'patch_frame_size', ...
            'td_abortbelow_stdev', ...
            'td_abortbelow_stepsize', ...
            'td_middle', ...
            'validation', ...
            'iterative', ...
            'max_iterations', ...
            'abortbelow_change'};

  % Case +1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, 1);
  new_parameters = cell2struct(param_cell, fields, 1);
  fprintf('%s: %g +1 ...', fields{index}, param_cell{index})
  new_cost_plus = EvaluateInpaintingParameterized(new_parameters) - cost;

  % Case -1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, -1);
  new_parameters = cell2struct(param_cell, fields, 1);
  fprintf('%s: %g -1 ...', fields{index}, param_cell{index})
  new_cost_minus = EvaluateInpaintingParameterized(new_parameters) - cost;

  param_cell = struct2cell(parameters);
  if(new_cost_plus > 0 && new_cost_minus > 0)
      %Keep the old setting
      fprintf('%s: %g --', fields{index})

      new_value = param_cell{index};
  else
      stepsize = -1*(new_cost_plus-new_cost_minus)/2*learning_rate;
      new_value = getNext(param_cell{index}, stepsize);
      
      fprintf('%s: %g => %g (%g)', fields{index}, param_cell{index}, new_value, stepsize)
  end
  %pause;
end

function new = getNextGaussSize(Value, Stepsize)
  new = Value + Stepsize;
  if(new < 2)
    new = 2;
  end
end

function new = getNextGaussSigma(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);  
end

function new = getNextPatchSize(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);
  % Patchsize must divide image size (const: 512)
  % Here we work with the exponent of the power of two
  if(new > 9)
    new = 9;
  end
end

function new = getNextFrameSize(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);  
end

function new = getNextTDAbortBelowStep(Value, Stepsize)
 new = getNextPositiveRealNumber(Value, Stepsize);
end

function new = getNextTDAbortBelowStdev(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);
end

function new = getNextTDMiddle(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);
end

function new = getNextMaxIterations(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize);
  if(new<1)
    new = 1;
  end
end

function new = getNextValidation(Value, Stepsize)
  new = getNextPercentage(Value, Stepsize);
end

function new = getNextAbortBelowChange(Value, Stepsize)
  new = getNextPercentage(Value, Stepsize);
end

function new = getNextPercentage(Value, Stepsize)
  new = Value + Stepsize/100;
  if(new >= 1)
    new = 1-eps;
  end
  if(new <= 0)
    new = eps;
  end
end

function new = getNextPositiveRealNumber(Value, Stepsize)
    new = Value + Stepsize;
  if (new <= 0)
    new = eps;
  end
end
