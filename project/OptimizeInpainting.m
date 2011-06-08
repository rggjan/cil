% Optimize the parameters of inPainting.

parameters.gauss_size = 5;
parameters.gauss_sigma = 0.8;

parameters.patch_size = 16;
parameters.patch_frame = 8;

parameters.iterations = 1;

error_old = 1;
error = EvaluateInpaintingParameterized(parameters);

while abs(error_old - error) / error_old > 0.05
	
	parameters.gauss_size = 5;
	parameters.gauss_sigma = 0.8;
	
	parameters.patch_size = 16;
	parameters.patch_frame = 8;
	
	parameters.iterations = 1;
	
	error_old = error;
	error = EvaluateInpaintingParameterized(parameters);
	
	disp(['Average quadratic error: ' error]);
	disp(['Used parameters: ' parameters]);
	
end
