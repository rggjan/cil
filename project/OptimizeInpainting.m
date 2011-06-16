% Optimize the parameters of inPainting.
function optimizeInpainting()

  % Set random seet to get reproducable results
  rand('seed', 12345);

  % Initial parameters
  parameters = struct;
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
    % gauss_size
    final_parameters.gauss_size = gradientDescent(1, @getNextGaussSize, parameters, cost);
    final_parameters.abortbelow_change = gradientDescent(10, @getNextAbortBelowChange, parameters, cost);

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
            'validation', ...
            'iterative', ...
            'max_iterations', ...
            'abortbelow_change'};

  % Case +1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, 1);
  new_parameters = cell2struct(param_cell, fields, 1);
  new_cost_plus = EvaluateInpaintingParameterized(new_parameters) - cost;

  % Case -1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, -1);
  new_parameters = cell2struct(param_cell, fields, 1);
  new_cost_minus = EvaluateInpaintingParameterized(new_parameters) - cost;

  param_cell = struct2cell(parameters);
  if(new_cost_plus > 0 && new_cost_minus > 0)
      %Keep the old setting
      fprintf('Not changing %s', fields{index})

      new_value = param_cell{index};
  else
      stepsize = -1*(new_cost_plus-new_cost_minus)/2*learning_rate;
      new_value = getNext(param_cell{index}, stepsize);
      
      fprintf('Changing %s from %g with step %g', fields{index}, param_cell{index}, stepsize)
  end
  %pause;
end

function new = getNextGaussSize(Value, Stepsize)
  new = Value + Stepsize;
  if(new < 2)
    new = 2;
  end
end

function new = getNextPatchSize(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, StepSize);
  % Patchsize must divide image size (const: 512)
  % Here we work with the exponent of the power of two
  if(new > 9)
    new = 9;
  end
end

function new = getNextFrameSize(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, StepSize);  
end

function new = getNextTDAbortBelowStep(Value, Stepsize)
 new = getNextPositiveRealNumber(Value, StepSize);
end

function new = getNextTDAbortBelowStdev(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, StepSize);
end

function new = getNextTDMiddle(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, StepSize);
end

function new = getNextMaxIterations(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, StepSize);
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

function new = getPositiveRealNumber(Value, StepSize)
    new = Value + Stepsize;
  if (new <= 0)
    new = eps;
  end
end
