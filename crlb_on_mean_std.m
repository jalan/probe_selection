function [bound] = crlb_on_mean_std(X, number_of_scans, d, sigma_N, M, ...
	Gamma_min, Gamma_max, Gamma_steps)
%
% [bound] = crlb_on_mean_std(X, number_of_scans, d, sigma_N, M, ...
%     Gamma_min, Gamma_max, Gamma_steps)
%
% This function computes the mean over Gamma of the Cramer-Rao lower bound on
% the standard deviation of Gamma_hat, assuming unbiased estimators.
%
% The inputs are X = [B_m; Delta_B], number_of_scans, d, sigma_N, M, Gamma_min,
% Gamma_max, and Gamma_steps:
%
%     B_m             : row vector, modulation amplitude for each scan, in Gauss
%     Delta_B         : row vector, sweep width for each scan, in Gauss
%     number_of_scans : how many different scans to perform
%     d               : the spin density, in arbitrary units
%     sigma_N         : noise standard deviation, in arbitrary units
%     M               : samples per scan
%     Gamma_min       : the minimum HWHM linewidth, in Gauss
%     Gamma_max       : the maximum HWHM linewidth, in Gauss
%     Gamma_steps     : how many different Gamma values to evaluate
%
% Dependencies for this function are crlb_on_var, df_dd, df_dGamma, and df_dB_m
%

% Note: I am aware that number_of_scans is not strictly necessary, but it makes
% for a nice sanity check.

	% Argument checking--the rest are checked in crlb_on_var
	if ~isscalar(Gamma_min) || ~isfloat(Gamma_min) || ~(Gamma_min>0)
		error('crlb_on_mean_std:invalid_argument', ...
			'Gamma_min must be a positive scalar float');
	elseif ~isscalar(Gamma_max) || ~isfloat(Gamma_max) || ~(Gamma_max>0)
		error('crlb_on_mean_std:invalid_argument', ...
			'Gamma_max must be a positive scalar float');
	elseif ~isscalar(Gamma_steps) || ~isnumeric(Gamma_steps) || ~(Gamma_steps>0)
		error('crlb_on_mean_std:invalid_argument', ...
			'Gamma_steps must be a positive scalar numeric');
	end

	% Range of linewidths
	Gamma = linspace(Gamma_min, Gamma_max, Gamma_steps);

	% Preallocate
	std = zeros(size(Gamma));

	% Compute the bound at each point Gamma
	for i=1:length(Gamma)
		std(i) = sqrt(crlb_on_var(X, number_of_scans, d, Gamma(i), sigma_N, M));
	end

	bound = mean(std);

end
