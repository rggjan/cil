% Optimize the parameters of inPainting.
function OptimizeInpainting()

  missing_pixels = 0.6;

  % Set random seet to get reproducable results
  rand('seed', 12345);

  % Load parameters and best_cost from (binary) file
  load('params.mat');

  % Store best value in global variable, for usage in Evaluation script
  global global_best_cost;
  global_best_cost = best_cost;
  fprintf('\nStarting optimization, current best cost is %g\n\n', best_cost);

  % Initial parameters
  % parameters = struct;
  % parameters.gauss_size = 9.3;
  % parameters.gauss_sigma = 0.7;
  % parameters.patch_size = 7.9;
  % parameters.patch_frame_size = 8.9;
  % parameters.td_abortbelow_stdev = 3.8;
  % parameters.td_abortbelow_stepsize = 2.3;
  % parameters.td_middle = 8.1;
  % parameters.validation = 0.05; 
  % parameters.iterative = true; 
  % parameters.max_iterations = 4.9; 
  % parameters.abortbelow_change = 0.18; 
  old = zeros(11, 1);
  
  % Result set
  final_parameters = parameters;
  
  while(true)
    fprintf('========== Starting new round ===========\n')
    parameters = final_parameters
    [cost, unused] = EvaluateInpaintingParameterized(parameters, missing_pixels);
    fprintf('=> cost %g\n\n', cost);

    % gauss_size
    [final_parameters.gauss_size, old]             = gradientDescent(1, @getNextGaussSize, parameters, old, cost, missing_pixels);
    [final_parameters.gauss_sigma, old]            = gradientDescent(2, @getNextGaussSigma, parameters, old, cost, missing_pixels);
    [final_parameters.patch_size, old]             = gradientDescent(3, @getNextPatchSize, parameters, old, cost, missing_pixels);
    [final_parameters.patch_frame_size, old]       = gradientDescent(4, @getNextFrameSize, parameters, old, cost, missing_pixels);
    [final_parameters.td_abortbelow_stdev, old]    = gradientDescent(5, @getNextTDAbortBelowStdev, parameters, old, cost, missing_pixels);
    [final_parameters.td_abortbelow_stepsize, old] = gradientDescent(6, @getNextTDAbortBelowStep, parameters, old, cost, missing_pixels);
    [final_parameters.td_middle, old]              = gradientDescent(7, @getNextTDMiddle, parameters, old, cost, missing_pixels);
    [final_parameters.validation, old]             = gradientDescent(8, @getNextValidation, parameters, old, cost, missing_pixels);
    %Dont iterate over bool 'iterative'
    if parameters.iterative
      [final_parameters.max_iterations, old]         = gradientDescent(10, @getNextMaxIterations, parameters, old, cost, missing_pixels);
      [final_parameters.abortbelow_change, old]      = gradientDescent(11, @getNextAbortBelowChange, parameters, old, cost, missing_pixels);
    end
  end

end

function [new_value, next_old] = gradientDescent(index, getNext, parameters, old, cost, missing_pixels);
  learning_rate = 5;
  alpha = 0.9;

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
  fprintf('%s: %g ... ', fields{index}, param_cell{index})
  [new_cost, unused] = EvaluateInpaintingParameterized(new_parameters, missing_pixels);
  new_cost_plus = new_cost - cost;
  fprintf('cost %g\n', new_cost_plus);

  % Case -1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, -1);
  new_parameters = cell2struct(param_cell, fields, 1);
  fprintf('%s: %g ... ', fields{index}, param_cell{index})
  [new_cost, unused] = EvaluateInpaintingParameterized(new_parameters, missing_pixels);
  new_cost_minus = new_cost - cost;
  fprintf('cost %g\n', new_cost_minus);

  param_cell = struct2cell(parameters);
%  if(new_cost_plus > 0 && new_cost_minus > 0)
      %Keep the old setting
%      fprintf('%s: %g --\n\n', fields{index}, param_cell{index})

%      new_value = param_cell{index};
%  else
      stepsize = -1*(new_cost_plus-new_cost_minus)/2*learning_rate;
      old_stepsize = old(index);
      if (old_stepsize ~= 0)
        new_stepsize = old_stepsize*alpha + (1-alpha)*stepsize;
      else
        new_stepsize = stepsize;
      end
      fprintf('steps(old/new/together): %g/%g/%g\n', old_stepsize, stepsize, new_stepsize)
      old(index) = new_stepsize;
      new_value = getNext(param_cell{index}, new_stepsize);
      
      fprintf('%s: %g => %g\n\n', fields{index}, param_cell{index}, new_value)
%  end
  %pause;
  next_old = old;
end

function new = getNextGaussSize(Value, Stepsize)
  new = Value + Stepsize;
  if(new < 2)
    new = 2;
  end
end

function new = getNextGaussSigma(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize/10);
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
 new = getNextPositiveRealNumber(Value, Stepsize/5);
end

function new = getNextTDAbortBelowStdev(Value, Stepsize)
  new = getNextPositiveRealNumber(Value, Stepsize/5);
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
