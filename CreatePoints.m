function [p]=CreatePoints(n)
% Create an array "p" of [n] objects of type "point"

    % Initiate the array with a new point
    p=[Point];


    % Add n-1 objects to the array [p]
    for i=1:(n-1);
        p=[p Point]; 
    end

end
