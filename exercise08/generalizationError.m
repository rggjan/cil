function G = generalizationError(Xmat, Umat, Zmat, ratio )

% matrix sizes:
% Xmat    D x N
% Umat    D x K
% Zmat    K x N

[ D, N ] = size(Xmat);

% unique assignment sets
Zmat = unique(Zmat','rows')';
N_assSets = size(Zmat, 2);

% randomly choose a number of dimensions
rperm = randperm(D);
myDims = rperm( 1:round(ratio*D) );
otherDims = rperm( round(ratio*D)+1 : D );


UmatL = combineRolesIntern(Umat, Zmat);
if numel(Zmat)==1
    UmatL = UmatL';
end

newAssN = zeros(1, N);
newHamm = zeros(1, N);
Xrec = 0*Xmat;
for dat = 1 : N
    % assign roles according to revealed dimensions
    myHamm = sum( abs( repmat(Xmat(myDims, dat), [1 N_assSets]) - UmatL(myDims, :) ), 1);
    [ newHamm(dat), newAssN(dat) ] = min(myHamm);
    
    % compute prediction of remaining dimensions
    Xrec(:, dat) = UmatL(:, newAssN(dat));
end

% compute difference to data
reconstrDiff = Xmat(otherDims,:) - double( Xrec(otherDims,:) > 0 );
G = sum(sum(abs( reconstrDiff ))) /N /length(otherDims);

end


%% Auxiliary Functions
function uL = combineRolesIntern(Umat, poss_assignments)
% combineBetasIntern(betas, poss_assignments) computes proxy centroids out of the
% BINARY centroid matrix 'Umat' and the BINARY matrix of all possible centroid
% combinations 'poss_assignments'.

uL = (Umat * poss_assignments)>0;
uL = single(uL);

if size(poss_assignments,2) == 1
    % if there is only one label set, the 'squeeze' makes a column vector
    % out of the row vector. This has to be undone in order for the rest to
    % work correctly.
    uL = uL';
end

end



