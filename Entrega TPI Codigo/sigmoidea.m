function [y] = sigmoidea(x,b,k)
    y = (2./(1+exp((-b.*x)))-1);
end
