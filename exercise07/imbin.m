


function imbin(X)
%function imbin(X);
% convienient method to plot binary matrices via imagesc
% ones are black; zeros are white

imagesc(-single(X),[-1 0]);
title('Black=1; White=0');
axis tight; colormap(gray); drawnow;
end