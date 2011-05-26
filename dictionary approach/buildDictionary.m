function U = buildDictionary(dim, I)

% Builds a dictionary with atoms of specified dimension
%
% INPUT
% dim:  The dimensionality of the dictionary atoms
% I:    Image
% r:    The shift radius in px
%
% OUTPUT:
% U (d x l) dictionary with unit norm atoms

% Here you add the code for getting the dictionary you desire





U = [overDCTdict(dim, dim)];
