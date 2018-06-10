function tone_curve = compute_tone_curve(HDR_gray_histogram_log,tone_inf_log,tone_sup_log,delta)

% Computes the tone curve associated with a given HDR histogram and a given 
% display model. The HDR lumas are mapped to a resticted display luminance 
% range which depends on the display model properties. The output is not in
% luma: to get lumas, inverse display model needs to be applied after this
% function.

tone_range_log = tone_sup_log - tone_inf_log;
p_t = 0.0001;
tmp = Inf;
nb_bin = length(HDR_gray_histogram_log);
slopes = zeros(1,nb_bin-1);

while (abs(tmp - p_t) > p_t/10000)

    tmp = p_t;
    omega_t = find(HDR_gray_histogram_log(1:end-1) > p_t);
    p_t = max(0,(length(omega_t) - tone_range_log/delta)/(sum(1./HDR_gray_histogram_log(omega_t))));
    if (abs(tmp - p_t) <= p_t/10000)
        slopes(omega_t) = 1 + (tone_range_log/delta - length(omega_t))./(HDR_gray_histogram_log(omega_t)*sum(1./HDR_gray_histogram_log(omega_t)));
        slopes(~omega_t) = 0;
    end
    
end

tone_curve = zeros(1,nb_bin);
tone_curve(1) = -tone_range_log;

for n = 2:nb_bin

    tone_curve(n) = min(tone_curve(n-1) + delta*slopes(n-1),0);
    
end

tone_curve = tone_curve + tone_sup_log;

end

