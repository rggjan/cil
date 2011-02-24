P_n = 1000;
Q_n = 800;

P = rand(P_n, 2);
Q = P(1:Q_n,:);
Q = Q + 0.01*randn(size(Q));

% scatter(P(:,1),P(:,2),'r.');
% hold
% scatter(Q(:,1),Q(:,2),'bo');
% hold off

I{1} = P;
I{2} = Q;