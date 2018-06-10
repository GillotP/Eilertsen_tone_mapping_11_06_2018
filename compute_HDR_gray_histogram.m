function HDR_gray_histogram = compute_HDR_gray_histogram(im_HDR_gray,HDR_luma_absciss)

% Computes the histogram of an HDR gray image for a given range of values 
% uniformly spaced.

[M,N] = size(im_HDR_gray);
full_size = M*N;
nb_bin = length(HDR_luma_absciss);
L_max = HDR_luma_absciss(nb_bin);
L_min = HDR_luma_absciss(1);
delta = (L_max - L_min)/(nb_bin - 1);
HDR_gray_histogram = zeros(1,nb_bin);

for n = 1:nb_bin
    
    ind = find(((HDR_luma_absciss(n)-im_HDR_gray) < 0.5*delta).*((HDR_luma_absciss(n)-im_HDR_gray) >= -0.5*delta));
    HDR_gray_histogram(n) = length(ind)/full_size;
    
end

end

