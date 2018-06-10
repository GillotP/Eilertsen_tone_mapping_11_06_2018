function I_filtered = iteratif_filtering(I,N_iter,sigma_0)

% Iterative filtering derived from the classical bilateral filtering. Used
% to separate illumination (smooth high global contrast component) from 
% reflectance (low global contrast with high frequencies).

I_filtered = I;
sum_square_sigmas = 0;

for n = 1:N_iter
    
    sigma_n_square = (n*sigma_0)^2 - sum_square_sigmas;
    sum_square_sigmas = sum_square_sigmas + sigma_n_square;
    sigma_n = sqrt(sigma_n_square);

    half_size = ceil(3*sigma_n);
    grid_1D = -half_size:half_size;
    full_size = length(grid_1D);
    [grid_2D_y,grid_2D_x] = meshgrid(grid_1D,grid_1D);
    
    gaussian_kernel = exp(-((grid_2D_x).^2 + (grid_2D_y).^2)/(2*sigma_n_square));
    I_gaussianed = imfilter(I_filtered,gaussian_kernel,'replicate');

    filter_grad_h = repmat(grid_1D',[1 full_size]);
    filter_grad_v = repmat(grid_1D,[full_size 1]);
    grad_h = imfilter(I_filtered,filter_grad_h,'replicate');
    grad_v = imfilter(I_filtered,filter_grad_v,'replicate');
    norm_L2_grad = sqrt(grad_h.^2 + grad_v.^2);
    norm_L2_grad_constrained = max(norm_L2_grad,n*abs(I_gaussianed - I));

    stop = 5*median(norm_L2_grad_constrained(:)); % sinon: histogram of gradient magnitudes + unimodal thresholding of histogram
    intensity_weights = edge_stop(norm_L2_grad_constrained,stop);
    I_filtered = (1 - intensity_weights).*I_filtered + intensity_weights.*I_gaussianed;

end

end

