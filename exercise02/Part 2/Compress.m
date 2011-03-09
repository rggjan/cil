function I_comp = Compress(I)

% Compressing function
extract(I,50);
I_comp.I = I; % this is just a stump to make the evaluation script run, replace it with your code!

end

function X = extract(I,d)
    %Replicate the last column/row until it is divisible by d

    if (mod(size(I,1), d)) ~= 0
       % Copy row
       copy = repmat( I(size(I,1),:,:), (d-mod(size(I,1), d)) , 1));
       I = [I; copy];

    end

    if (mod(size(I,2),d)) ~= 0
       % Copy column
       copy2 = repmat(:,I(size(I,2),:), 1, (d-mod(size(I,2), d)));
       I = [I copy2];
    end

    imshow(I);
    pause;
    
    % Now we are guaranteed to have a matrix that is square, with each
    % dimension divisible by d

    % Cut into blocks and return them (vectorized)
    X = zeros(d^2, I/d, 3);
    for i=1:size(I,1)/d
       for j=1:size(I,2)/d 

       end
end

end