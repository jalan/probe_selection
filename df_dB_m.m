function [value] = df_dB_m(d, Gamma, B_m, B)
%
% [value] = df_dB_m(d, Gamma, B_m, B)
%
% This is the partial derivative of the f.m function with respect to B_m.
%
% The inputs are d, Gamma, B_m, and B:
%
%     d     : the spin density, in arbitrary units
%     Gamma : the HWHM linewidth, in Gauss
%     B_m   : the modulation amplitude, in Gauss
%     B     : the field value, in Gauss
%

	% Argument checking
	if ~isscalar(d) || ~isfloat(d)
		error('df_dB_m:invalid_argument', ...
			'd must be a scalar float');
	elseif ~isscalar(Gamma) || ~isfloat(Gamma)
		error('df_dB_m:invalid_argument', ...
			'Gamma must be a scalar float');
	elseif ~isscalar(B_m) || ~isfloat(B_m)
		error('df_dB_m:invalid_argument', ...
			'B_m must be a scalar float');
	elseif ~isscalar(B) || ~isfloat(B)
		error('df_dB_m:invalid_argument', ...
			'B must be a scalar float');
	end

	% Please pardon the unreadable math....
	value = imag( ...
		(B_m*d*(B_m/4 + B_m/(8*(1 - B_m^2/(4*(B + ...
		1i*Gamma)^2))^(1/2))))/(B_m^2/8 - (((1 - B_m^2/(4*(B + ...
		1i*Gamma)^2))^(1/2) + 1)*(B + 1i*Gamma)^2)/2)^2 - d/(B_m^2/8 - ...
		(((1 - B_m^2/(4*(B + 1i*Gamma)^2))^(1/2) + 1)*(B + 1i*Gamma)^2)/2) ...
	);

end
