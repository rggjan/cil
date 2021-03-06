% OptimizeInpainting
% ==================
% Optimize the parameters of inPainting using a gradient descent method
% rounds gives the number of rounds after which to stop
% Saves plots of the cost and the changes of parameters to the plots folder
function OptimizeInpainting(rounds)
  missing_pixels = 0.6;
  repetition_evaluation = 2;

  % Load parameters and best_cost from (binary) file
  load('params.mat');

  % Store best value in global variable, for usage in Evaluation script
  % Also reset computer_speed
  global global_best_cost;
  global computer_speed;
  computer_speed = [];
  global_best_cost = best_cost;
  fprintf('\nStarting optimization, current best cost is %g\n\n', best_cost);

  % Remember old values for the momentum term
  old = zeros(11, 1);
  
  % Result set
  final_parameters = parameters;
  rounds_done = 1;

  % Save parameter_list and cost_list for plots
  global parameter_list
  parameter_list = cell2mat(struct2cell(parameters));
  global cost_list
  cost_list = [];

  % Iterate
  while(rounds_done <= rounds || rounds == 0)
    fprintf('========== Starting round %g ===========\n', rounds_done)

    parameters = final_parameters
    [cost, unused, unused2] = EvaluateInpaintingParameterized(parameters, missing_pixels, repetition_evaluation);
    fprintf('=> cost %g\n\n', cost);

    % Optimize individual parameters
    [final_parameters.gauss_size, old]             = gradientDescent(1, @getNextGaussSize, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.gauss_sigma, old]            = gradientDescent(2, @getNextGaussSigma, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.patch_size, old]             = gradientDescent(3, @getNextPatchSize, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.patch_frame_size, old]       = gradientDescent(4, @getNextFrameSize, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.td_abortbelow_stdev, old]    = gradientDescent(5, @getNextTDAbortBelowStdev, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.td_abortbelow_stepsize, old] = gradientDescent(6, @getNextTDAbortBelowStep, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.td_middle, old]              = gradientDescent(7, @getNextTDMiddle, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    [final_parameters.validation, old]             = gradientDescent(8, @getNextValidation, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    % Dont iterate over bool 'iterative'
    if parameters.iterative
      [final_parameters.max_iterations, old]         = gradientDescent(10, @getNextMaxIterations, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
      [final_parameters.abortbelow_change, old]      = gradientDescent(11, @getNextAbortBelowChange, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
    end

    % Plot cost function
    cost_list = [cost_list, cost];
    f = figure('visible', 'off');
    plot(cost_list);
    title('Cost during optimization');
    xlabel('Steps');
    ylabel('Cost function');
    saveas(f, 'plots/cost_plot.fig');
    close(f);

    rounds_done = rounds_done + 1;
  end
end

% gradientDescent
% ===============
% Do the real gradient descent in a generic way.
% Takes an input the index in the structure, a getNext function for getting a new value of a parameter,
% the old struct with all the old values, a current cost, the percentage of missing pixels and the number
% of rounds already finished.
% Returns the new parameter + the updated old struct
function [new_value, next_old] = gradientDescent(index, getNext, parameters, old, cost, missing_pixels, rounds_done, repetition_evaluation);
  % The learning rate: How much should we descent the gradient?
  learning_rate = 10;

  % Alpha, the momentum term.
  alpha = 0.8;

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
  [new_cost, unused, unused2] = EvaluateInpaintingParameterized(new_parameters, missing_pixels, repetition_evaluation);
  new_cost_plus = new_cost - cost;
  fprintf('cost %g\n', new_cost_plus);

  % Case -1
  param_cell = struct2cell(parameters);
  param_cell{index} = getNext(param_cell{index}, -1);
  new_parameters = cell2struct(param_cell, fields, 1);
  fprintf('%s: %g ... ', fields{index}, param_cell{index})
  [new_cost, unused, unused2] = EvaluateInpaintingParameterized(new_parameters, missing_pixels, repetition_evaluation);
  new_cost_minus = new_cost - cost;
  fprintf('cost %g\n', new_cost_minus);

  % Calculate the derivative
  param_cell = struct2cell(parameters);
  stepsize = -1*(new_cost_plus-new_cost_minus)/2*learning_rate;
  old_stepsize = old(index);

  % Use the old stepsize together with the momentum to get a new value
  if (old_stepsize ~= 0)
    new_stepsize = old_stepsize*alpha + (1-alpha)*stepsize;
  else
    new_stepsize = stepsize;
  end

  % Output to console
  fprintf('steps(old/new/together): %g/%g/%g\n', old_stepsize, stepsize, new_stepsize)
  old(index) = new_stepsize;
  new_value = getNext(param_cell{index}, new_stepsize);
  fprintf('%s: %g => %g\n\n', fields{index}, param_cell{index}, new_value)

  next_old = old;

  % Plot to graph
  global parameter_list
  parameter_list(index, rounds_done+1) = new_value;
  f = figure('visible', 'off');
  plot(parameter_list(index, :));
  title(sprintf('%s during optimization', fields{index}), 'Interpreter', 'none');
  xlabel('Steps');
  ylabel(sprintf('Value of %s', fields{index}), 'Interpreter', 'none');
  saveas(f, sprintf('plots/%s_plot.fig', fields{index}));
  close(f);
end

% ================= %
% getNext functions %
% ================= %

function new = getNextGaussSize(Value, Stepsize)
  new = Value + Stepsize;
  % Must be at least 2
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
  if(new < 2)
    new = 2;
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
