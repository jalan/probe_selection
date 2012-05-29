function [bound] = crlb_on_var(X, number_of_scans, d, Gamma, sigma_N, M)
%
% [bound] = crlb_on_var(X, number_of_scans, d, Gamma, sigma_N, M)
%
% This function computes the Cramer-Rao lower bound on the variance of
% Gamma_hat, assuming unbiased estimators.
%
% The inputs are X = [B_m; Delta_B], number_of_scans, d, Gamma, sigma_N, and M:
%
%     B_m             : row vector, modulation amplitude for each scan, in Gauss
%     Delta_B         : row vector, sweep width for each scan, in Gauss
%     number_of_scans : how many different scans to perform
%     d               : the spin density, in arbitrary units
%     Gamma           : the HWHM linewidth, in Gauss
%     sigma_N         : noise standard deviation, in arbitrary units
%     M               : samples per scan
%
% Dependencies for this function are df_dd, df_dGamma, and df_dB_m
%

% Note: I am aware that number_of_scans is not strictly necessary, but it makes
% for a nice sanity check.

	% Argument processing and checking
	if ~isscalar(number_of_scans) || ~isfloat(number_of_scans) || ...
		~(number_of_scans > 0)
			error('crlb_on_var:invalid_argument', ...
				'number_of_scans must be a positive scalar float');
	elseif ~isequal(size(X), [2 number_of_scans])
		error('crlb_on_var:invalid_argument', ...
			'X must be a 2-by-number_of_scans matrix');
	else
		% Break X apart for easier manipulation below
		B_m = X(1,:);
		Delta_B = X(2,:);
	end
	if ~isfloat(B_m) || any(B_m<0)
		error('crlb_on_var:invalid_argument', ...
			'B_m must be a vector of positive floats');
	elseif ~isfloat(Delta_B) || any(Delta_B<0)
		error('crlb_on_var:invalid_argument', ...
			'Delta_B must be a vector of positive floats');
	elseif ~isscalar(d) || ~isfloat(d) || ~(d>0)
		error('crlb_on_var:invalid_argument', ...
			'd must be a positive scalar float');
	elseif ~isscalar(Gamma) || ~isfloat(Gamma) || ~(Gamma>0)
		error('crlb_on_var:invalid_argument', ...
			'Gamma must be a positive scalar float');
	elseif ~isscalar(sigma_N) || ~isfloat(sigma_N) || ~(sigma_N>0)
		error('crlb_on_var:invalid_argument', ...
			'sigma_N must be a positive scalar float');
	elseif ~isscalar(M) || ~isfloat(M) || ~(M>0)
		error('crlb_on_var:invalid_argument', ...
			'M must be a positive scalar float');
	end

	% The unknowns are d, Gamma, and one B_m for each scan
	J_total = zeros(2 + number_of_scans); % total information from all scans

	% Time is fixed; information is additive. e.g., if you use two windows, the
	% information from each is cut in half, then the two information matrices
	% are added together.
	multiscan_factor = 1/number_of_scans;

	% Get the information from one scan at a time
	for i=1:1:number_of_scans

		% Reset the current information matrix, from a single scan
		J_current = zeros(2 + number_of_scans);

		% Collect information across the sweep
		for j=1:1:M

			% Our location in the sweep
			B_j = j * Delta_B(i) / (M-1) - Delta_B(i)/2;

			% We always get these three elements
			J_current(1, 1) = J_current(1, 1) + ...
				(df_dd(d, Gamma, B_m(i), B_j))^2;
			J_current(1, 2) = J_current(1, 2) + ...
				df_dd(d, Gamma, B_m(i), B_j)*df_dGamma(d, Gamma, B_m(i), B_j);
			J_current(2, 2) = J_current(2, 2) + ...
				(df_dGamma(d, Gamma, B_m(i), B_j))^2;

			% The locations of these element vary by scan
			J_current(1,   2+i) = J_current(1,   2+i) + ...
				df_dd(d, Gamma, B_m(i), B_j)*df_dB_m(d, Gamma, B_m(i), B_j);
			J_current(2,   2+i) = J_current(2,   2+i) + ...
				df_dGamma(d, Gamma, B_m(i), B_j)*df_dB_m(d, Gamma, B_m(i), B_j);
			J_current(2+i, 2+i) = J_current(2+i, 2+i) + ...
				(df_dB_m(d, Gamma, B_m(i), B_j))^2;

		end

		% We have three remaining elements to fill in by symmetry
		J_current(2,   1) = J_current(1, 2);
		J_current(2+i, 1) = J_current(1, 2+i);
		J_current(2+i, 2) = J_current(2, 2+i);

		% Don't forget the noise power and the multiscan factor
		J_current = J_current / sigma_N^2 * multiscan_factor;

		% Add to the total information
		J_total = J_total + J_current;

	end

	% Invert the matrix (watch out for a bug in inv--use pinv instead)
	J_inv = pinv(J_total);

	% Get the bound on the variance of Gamma_hat
	bound = J_inv(2, 2);

	% Rounding errors sometimes make the bound complex. This will overestimate
	% the bound in that case, which is conservative
	bound = abs(bound);

end
