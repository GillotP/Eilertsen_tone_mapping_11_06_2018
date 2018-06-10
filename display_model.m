function luminance = display_model(luma,L_peak,L_black,L_refl,gamma)

% Display model: luma to diplay luminance.

luminance = (luma.^gamma)*(L_peak - L_black) + L_black + L_refl;

end

