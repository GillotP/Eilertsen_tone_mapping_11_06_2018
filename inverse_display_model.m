function luma = inverse_display_model(luminance,L_peak,L_black,L_refl,gamma)

% Inverse display model: display luminance to luma.

luma = ((max((luminance - L_black - L_refl),0))/(L_peak - L_black)).^(1/gamma);
luma = luma.*(luma <= 1) + (luma > 1);

end

