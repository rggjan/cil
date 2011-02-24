n = 2000;
d = 500;
scl = 20;

X = rand(d,n);

mu1 = rand(d,1);
Sigma1 = rand(10*d,d)/scl;
Sigma1 = Sigma1'*Sigma1;

mu2 = rand(d,1);
Sigma2 = rand(10*d,d)/scl;
Sigma2 = Sigma2'*Sigma2;

% disp(['cond(Sigma1): ' num2str(cond(Sigma1))])
% disp(['det(Sigma1): ' num2str(det(Sigma1))])

I{1} = X;
I{2} = mu1;
I{3} = Sigma1;
I{4} = mu2;
I{5} = Sigma2;

