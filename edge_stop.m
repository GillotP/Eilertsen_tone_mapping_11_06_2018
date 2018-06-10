function y = edge_stop(x,lambda)

% Tukey’s biweight edge-stop function.

y = (x <= lambda).*((1-(x/lambda).^2).^2);

end

