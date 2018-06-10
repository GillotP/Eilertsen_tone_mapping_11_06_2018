clc; clear all; close all;

% Noise-aware tone mapping implementation by Pierre Gillot. Work in
% progress. Currently only for images. Code is vectorized as much as
% possible. Entirely based on the following publication:
% Eilertsen et al. (2015) Real-time noise-aware tone mapping
% (http://vcl.itn.liu.se/publications/2015/EMU15/SGA15_paper.pdf)

%% Loading an HDR image:
im_HDR = hdrread('hdr_scene.hdr');
[M,N,~] = size(im_HDR);

%% Color channels and luma extraction:
im_HDR_R = im_HDR(:,:,1);
im_HDR_G = im_HDR(:,:,2);
im_HDR_B = im_HDR(:,:,3);
im_HDR_gray = 0.2126*im_HDR_R + 0.7152*im_HDR_G + 0.0722*im_HDR_B;

%% Logarithmic mapping:
im_HDR_gray_log = log(1+im_HDR_gray)/log(10);

%% Display model: 
L_peak = 100;
L_black = 0.5;
E_amb = 75000; 
gamma = 2.2;
k = 0.01;
L_refl = k*E_amb/pi;
L_d = display_model([0 1],L_peak,L_black,L_refl,gamma); 
tone_inf_log = log(L_d(1))/log(10); 
tone_sup_log = log(L_d(2))/log(10); 

%% Tone mapping parameters:
N_iter = 10;
sigma = 0.1;
nb_bin = 100;
gamma_color = 0.6;
nb_bloc_row = 8;
nb_bloc_col = 8;
assert((mod(M,nb_bloc_row) == 0)*(mod(N,nb_bloc_col) == 0) == 1);
local_trust = 0.9;

%% Illumination-Reflectance separation in the logarithmic scale:
base_layer_log = iteratif_filtering(im_HDR_gray_log,N_iter,sigma);
detail_layer_log = im_HDR_gray_log - base_layer_log;

%% Global tone curve computation:
base_layer_log_vec = base_layer_log(:);
log_HDR_luma_absciss = linspace(min(base_layer_log_vec),max(base_layer_log_vec),nb_bin);
delta = log_HDR_luma_absciss(2) - log_HDR_luma_absciss(1);
base_layer_gray_histogram_log = compute_HDR_gray_histogram(base_layer_log_vec,log_HDR_luma_absciss);
global_tone_curve = compute_tone_curve(base_layer_gray_histogram_log,tone_inf_log,tone_sup_log,delta);

%% Global tone mapping of log-illumination:
base_layer_log_vec_toned = interp1(log_HDR_luma_absciss(:),global_tone_curve(:),base_layer_log_vec);
base_layer_log_toned = reshape(base_layer_log_vec_toned,size(base_layer_log));

%% Local tone curves computation:
bloc_size_row = M/nb_bloc_row;
bloc_size_col = N/nb_bloc_col;
local_tone_curves = zeros(nb_bloc_row,nb_bloc_col,nb_bin);
for m = 1:nb_bloc_row
    for n = 1:nb_bloc_col
        log_HDR_luma_bloc = base_layer_log((m-1)*bloc_size_row+1:m*bloc_size_row,(n-1)*bloc_size_col+1:n*bloc_size_col);
        local_histogram = compute_HDR_gray_histogram(log_HDR_luma_bloc,log_HDR_luma_absciss);
        weighted_local_histogram = (1 - local_trust)*base_layer_gray_histogram_log + local_trust*local_histogram;
        local_tone_curves(m,n,:) = compute_tone_curve(weighted_local_histogram,tone_inf_log,tone_sup_log,delta);
    end
end

%% Local tone curves interpolation + local tone_mapping:
base_layer_log_locally_toned_with_interpolation = tone_mapp_with_local_interpolation(local_tone_curves,log_HDR_luma_absciss,base_layer_log,bloc_size_row,bloc_size_col);

%% Reconstruction of the tone mapped displayed luminance in the logarithmic scale:
im_log_toned_luminance = base_layer_log_toned + detail_layer_log;
im_log_locally_toned_with_interpolation_luminance = base_layer_log_locally_toned_with_interpolation + detail_layer_log;

%% Reconstruction of the tone mapped luma with inverse display model:
im_toned_luminance = 10.^im_log_toned_luminance;  
im_toned_luma = inverse_display_model(im_toned_luminance,L_peak,L_black,L_refl,gamma);
im_locally_toned_with_interpolation_luminance = 10.^im_log_locally_toned_with_interpolation_luminance;  
im_locally_toned_with_interpolation_luma = inverse_display_model(im_locally_toned_with_interpolation_luminance,L_peak,L_black,L_refl,gamma);

%% Reconstruction of the tone mapped color image with desaturated color-to-luminance ratios:
im_toned_color = (repmat(im_toned_luma,[1 1 3])).*((im_HDR./(repmat(im_HDR_gray,[1 1 3]))).^gamma_color);
im_locally_toned_with_interpolation_color = (repmat(im_locally_toned_with_interpolation_luma,[1 1 3])).*((im_HDR./(repmat(im_HDR_gray,[1 1 3]))).^gamma_color);

%% Display results:
figure
imagesc(base_layer_log), title('Base layer'), colormap gray;
figure
imagesc(detail_layer_log), title('Detail layer'), colormap gray;
figure
plot(log_HDR_luma_absciss,global_tone_curve), title('Tone curve');
figure
imshow(im_HDR_gray), title('HDR luma of input image');
figure
imshow(im_toned_luma), title('Tone mapped luma of input image');
figure
imshow(im_HDR), title('HDR color input image');
figure
imshow(im_toned_color), title('Tone mapped color input image');
figure
imshow(im_locally_toned_with_interpolation_color), title('Locally tone mapped color input image with interpolation');

