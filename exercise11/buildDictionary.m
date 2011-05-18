function U = buildDictionary(dim)

% Builds a dictionary with atoms of specified dimension
%
% INPUT
% dim: The dimensionality of the dictionary atoms
%
% OUTPUT:
% U (d x l) dictionary with unit norm atoms

% Here you add the code for getting the dictionary you desire


% Most trivial implementation, using both DCT and haarTransform
% Is still a TODO

U = [overDCTdict(dim, 50) haarTrans(dim)];
