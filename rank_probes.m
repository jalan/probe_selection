function [ranked_list, scores, parameters, varargout] = rank_probes( ...
	probe_list, pO2_min, pO2_max, sigma_N, M, ranking_mode, varargin)
%
% [ranked_list, scores, parameters] = rank_probes( ...
%     probe_list, pO2_min, pO2_max, sigma_N, M, ranking_mode)
%
%                    or to include a figure
%
% [ranked_list, scores, parameters, handle] = rank_probes( ...
%     probe_list, pO2_min, pO2_max, sigma_N, M, ranking_mode, make_figure)
%
% This function takes a list of probes and a description of an EPR oximetry
% experiment and predicts how well each probe will perform.
%
% The inputs are probe_list, pO2_min, pO2_max, sigma_N, M, ranking_mode, and
% make_figure:
%
%     probe_list   : cell array of Probe objects to evaluate
%     pO2_min      : lowest oxygen pressure (pO2) expected, in mmHg
%     pO2_max      : highest oxygen pressure expected, in mmHg
%     sigma_N      : noise standard deviation at each sample
%     M            : how many samples in the scan
%     ranking_mode : 'average' or 'worst', how to score each probe
%     make_figure  : optional, 'yes' or 'no', to create an explanatory figure
%
%     ranking_mode='average' implies that the scoring metric is the standard
%     deviation of pO2, averaged across the pO2 range in question.
%     ranking_mode='worst' implies that the scoring metric is the standard
%     deviation of pO2 at the highest pO2 value (i.e., where the standard
%     deviation is highest).
%
% The outputs are ranked_list, scores, parameters, and handle:
%
%     ranked_list : a cell array of Probe objects, ordered from best to worst
%     scores      : corresponding scores for each probe, using the metric
%                   specified in ranking_mode. Lower scores are better
%     parameters  : corresponding optimized acquisition parameters for each
%                   probe. Each entry in this cell array is [B_m; Delta_B],
%                   where B_m is the modulation amplitude and Delta_B is the
%                   sweep width, each in Gauss
%     handle      : a handle to the optional explanatory figure
%
% The scores returned, and the values on the vertical axes of the optional
% plots, are arbitrary in some sense: they depend on the values of sigma_N and M
% that you supply.
%  - If you DO know these values, perhaps from performing previous experiments,
%    great: the scores and plots will be realistic.
%  - If you DON'T know these values, that's fine too: just provide some default
%    values like sigma_N=1e18 and M=512; then the scores and the plots may not
%    be realistic, but the probes will still be ranked correctly.
%
% Dependencies for this function are crlb_on_var, crlb_on_mean_std, df_dd,
% df_dGamma, df_dB_m, and Probe
%

	%% Argument checking and processing

	% Check the number of input arguments
	if ~((nargin == 6) || (nargin == 7))
		error('rank_probes:invalid_argument', ...
			'Number of input arguments must be six or seven');
	end

	% Check probe_list
	if ~iscell(probe_list) || ~isvector(probe_list)
		error('rank_probes:invalid_argument', ...
			'probe_list must be an Nx1 cell array of Probe objects');
	end
	for i=1:length(probe_list)
		if ~isa(probe_list{i}, 'Probe')
			error('rank_probes:invalid_argument', ...
				'probe_list must be an Nx1 cell array of Probe objects');
		end
	end

	% Check pO2_min
	if ~isscalar(pO2_min) || ~isfloat(pO2_min) || (pO2_min<0)
		error('rank_probes:invalid_argument', ...
			'pO2_min must be a non-negative scalar float');
	end

	% Check pO2_max
	if ~isscalar(pO2_max) || ~isfloat(pO2_max) || (pO2_max<0)
		error('rank_probes:invalid_argument', ...
			'pO2_max must be a non-negative scalar float');
	end

	% These must be in the right order
	if (pO2_min > pO2_max)
		error('rank_probes:invalid_argument', ...
			'pO2_min must not be greater than pO2_max');
	end

	% Check sigma_N
	if ~isscalar(sigma_N) || ~isfloat(sigma_N) || ~(sigma_N>0)
		error('rank_probes:invalid_argument', ...
			'sigma_N must be a positive scalar float');
	end

	% Check M
	if ~isscalar(M) || ~isfloat(M) || ~(M>0)
		error('rank_probes:invalid_argument', ...
			'M must be a positive scalar float');
	end

	% Check ranking_mode
	if ~ischar(ranking_mode) || ...
			~(strcmp(ranking_mode, 'worst') || strcmp(ranking_mode, 'average'))
		error('rank_probes:invalid_argument', ...
			'ranking_mode must be either ''worst'' or ''average''');
	end

	% Check make_figure, which is an optional input argument
	if (nargin == 6)
		make_figure = false();
	elseif ~ischar(varargin{1})
		error('rank_probes:invalid_argument', ...
			'make_figure must be either ''yes'' or ''no''');
	elseif strcmp(varargin{1}, 'no')
		make_figure = false();
	elseif strcmp(varargin{1}, 'yes')
		make_figure = true();
	else
		error('rank_probes:invalid_argument', ...
			'make_figure must be either ''yes'' or ''no''');
	end

	% Check number of output arguments
	if ~((nargout == 3) || (nargout == 4))
		error('rank_probes:invalid_argument', ...
			'Number of output arguments must be three or four');
	end

	%% Multiply these by the max HWHM linewidth to determine our parameters
	if strcmp(ranking_mode, 'worst')
		 B_m_factor = 4;
		 Delta_B_factor = 8;
	else % ranking_mode is 'average'
		 B_m_factor = 2.91;
		 Delta_B_factor = 6.01;
	end

	%% Preallocate
	parameters = cell(size(probe_list));
	scores = zeros(size(probe_list));

	%% Determine the parameters to use for each probe, and assign its score
	for i=1:length(probe_list)

		% Minimum and maximum linewidths, peak-to-peak
		Gamma_pp_min = probe_list{i}.Gamma_0_pp + ...
			probe_list{i}.sensitivity*pO2_min;
		Gamma_pp_max = probe_list{i}.Gamma_0_pp + ...
			probe_list{i}.sensitivity*pO2_max;

		% Minimum and maximum linewidths, half-width at half-maximum
		Gamma_hwhm_min = sqrt(3)/2 * Gamma_pp_min;
		Gamma_hwhm_max = sqrt(3)/2 * Gamma_pp_max;

		% Optimized parameters
		parameters{i} = ...
			[Gamma_hwhm_max * B_m_factor;      % modulation amplitude, in Gauss
			 Gamma_hwhm_max * Delta_B_factor]; % sweep width, in Gauss

		% Compute score
		if strcmp(ranking_mode, 'worst')
			scores(i) = sqrt(crlb_on_var( ...
				parameters{i},   ... % acquisition parameters
				1,               ... % number of scans
				probe_list{i}.d, ... % spin density
				Gamma_hwhm_max,  ... % HWHM linewidth
				sigma_N,         ... % noise standard deviation
				M                ... % samples per scan
			));
		else % ranking_mode is 'average'
			scores(i) = crlb_on_mean_std( ...
				parameters{i},   ... % acquisition parameters
				1,               ... % number of scans
				probe_list{i}.d, ... % spin density
				sigma_N,         ... % noise standard deviation
				M,               ... % samples per scan
				Gamma_hwhm_min,  ... % minimum HWHM linewidth
				Gamma_hwhm_max,  ... % maximum HWHM linewidth
				64               ... % how many different linewidths to check
			);
		end

		% Convert from Gamma_hwhm std. to pO2 std.
		scores(i) = scores(i) * 2/sqrt(3) / probe_list{i}.sensitivity;
	end

	%% Sort from best to worst
	[scores, indices] = sort(scores);
	parameters = parameters(indices);
	ranked_list = probe_list(indices);

	%% Optionally make a figure
	if make_figure
		varargout{1} = figure(); % new figure window

		% Top plot: scores for each probe
		% This uses an ugly hack to get multiple bar colors :/
		subplot(2, 1, 1);
		hold('on');
		bar_colors = {'r' 'y' 'g' 'c' 'b' 'm'};
		xtick_labels = {''};
		for i=1:length(scores)
			single_bar = zeros(size(scores));
			single_bar(i) = scores(i);
			bar(single_bar, 0.5, bar_colors{mod(i, length(bar_colors))});
			xtick_labels{end+1} = ranked_list{i}.name; %#ok
			xtick_labels{end+1} = ''; %#ok
		end
		set(gca(), 'Xticklabel', xtick_labels);
		if strcmp(ranking_mode, 'worst')
			ylabel('Worst pO_2 std. (mmHg)');
			title('Worst-case standard deviation--lower is better');
		else % ranking_mode is 'average'
			ylabel('Average pO_2 std. (mmHg)');
			title('Average standard deviation--lower is better');
		end

		% Bottom plot: performance across the range for the winning probe
		subplot(2, 1, 2);
		pO2 = linspace(pO2_min, pO2_max, 100);
		Gamma_hwhm = sqrt(3)/2 * ...
			(ranked_list{1}.Gamma_0_pp + ranked_list{1}.sensitivity * pO2);
		predicted_std = zeros(size(Gamma_hwhm));
		for i=1:length(Gamma_hwhm)
			predicted_std(i) = sqrt(crlb_on_var( ...
				parameters{1},    ... % acquisition parameters
				1,                ... % number of scans
				ranked_list{1}.d, ... % spin density
				Gamma_hwhm(i),    ... % HWHM linewidth
				sigma_N,          ... % noise standard deviation
				M                 ... % samples per scan
			));
		end
		% Convert from Gamma_hwhm std. to pO2 std.
		predicted_std = predicted_std * 2/sqrt(3) / ranked_list{1}.sensitivity;
		plot(pO2, predicted_std, bar_colors{1});
		xlabel('pO_2 (mmHg)');
		ylabel('pO_2 std. (mmHg)');
		title(['Performance profile for ' ranked_list{1}.name]);
	else
		% In case the user didn't ask for a figure but still requested a handle
		varargout{1} = -1; % not a valid handle
	end
end
