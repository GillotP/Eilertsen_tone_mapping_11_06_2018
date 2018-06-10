function tone_mapped_log_HDR_luma = tone_mapp_with_local_interpolation(local_tone_curves,log_HDR_luma_absciss,log_HDR_luma,bloc_size_row,bloc_size_col)

% Performs a spatial (2D) linear interpolation of the local tone curves 
% initially computed for each bloc. This interpolation gives one tone curve 
% per pixel. An other interpolation is then performed on each tone curve 
% obtained this way in order to locally tone mapp the log-illuminations.

[M,N] = size(log_HDR_luma);
[nb_bloc_row,nb_bloc_col,nb_bin] = size(local_tone_curves);

half_bloc_size_row = ceil(bloc_size_row/2);
half_bloc_size_col = ceil(bloc_size_col/2);
centers_blocs_row = (0:(nb_bloc_row-1))*bloc_size_row+half_bloc_size_row;
centers_blocs_col = (0:(nb_bloc_col-1))*bloc_size_col+half_bloc_size_col;

%% Interpolating spatially local tone curves:
[Y,X,Z] = meshgrid(centers_blocs_col,centers_blocs_row,(1:nb_bin));
my_tone_curves_interpolant = griddedInterpolant(X,Y,Z,local_tone_curves,'linear','linear');
[Y_interp,X_interp,Z_interp] = meshgrid((1:N),(1:M),(1:nb_bin));
interpolated_local_tone_curves = my_tone_curves_interpolant(X_interp,Y_interp,Z_interp);

%% Interpolating tones:
log_HDR_luma_absciss = repmat(reshape(log_HDR_luma_absciss,1,1,[]),[M N]); 
X_interp = single(X_interp);
Y_interp = single(Y_interp);
my_tones_interpolant = griddedInterpolant(X_interp,Y_interp,log_HDR_luma_absciss,interpolated_local_tone_curves,'linear','linear');
tone_mapped_log_HDR_luma = my_tones_interpolant(X_interp(:,:,1),Y_interp(:,:,1),log_HDR_luma);
     
end

