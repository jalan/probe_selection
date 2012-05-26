function [ranked_list, scores, parameters, varargout] = ...
	rank_probes(probe_list, pO2_min, pO2_max, ranking_mode, varargin)
%
% TODO: function description
%

	%% Argument checking and processing

	% Check the number of input arguments
	if ~((nargin == 4) || (nargin == 5))
		error('rank_probes:invalid_argument', ...
			'Number of input arguments must be four or five');
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
	if ~isscalar(pO2_min) || ~isfloat(pO2_min)
		error('rank_probes:invalid_argument', ...
			'pO2_min must be a scalar float');
	end

	% Check pO2_max
	if ~isscalar(pO2_max) || ~isfloat(pO2_max)
		error('rank_probes:invalid_argument', ...
			'pO2_max must be a scalar float');
	end

	% Check ranking_mode
	if ~ischar(ranking_mode) || ...
			~(strcmp(ranking_mode, 'worst') || strcmp(ranking_mode, 'average'))
		error('rank_probes:invalid_argument', ...
			'ranking_mode must be either ''worst'' or ''average''');
	end

	% Check make_figure, which is an optional input argument
	if (nargin == 4)
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
				parameters{i},   ... acquisition parameters
				1,               ... number of scans
				probe_list{i}.d, ... spin density
				Gamma_hwhm_max,  ... HWHM linewidth
				1,               ... noise standard deviation TODO
				128              ... samples per scan (shouldn't affect results)
			));
		else % ranking_mode is 'average'
			scores(i) = crlb_on_mean_std( ...
				parameters{i},   ... acquisition parameters
				1,               ... number of scans
				probe_list{i}.d, ... spin density
				1,               ... noise standard deviation TODO
				128,             ... samples per scan (shouldn't affect results)
				Gamma_hwhm_min,  ... minimum HWHM linewidth
				Gamma_hwhm_max,  ... maximum HWHM linewidth
				64               ... how many different linewidths to check
			);
		end
	end

	%% Normalize the scores: lower is better; the best score is 1
	scores = scores / min(scores);
	
	%% Sort from best to worst
	[scores, indices] = sort(scores);
	parameters = parameters(indices);
	ranked_list = probe_list(indices);

	%% Optionally make a figure
	% This uses some ugly hacks to get multiple bar colors. Jesus, matlab.
	if make_figure
		varargout{1} = figure(); % new figure window
		hold('on');
		bar_colors = {'r' 'y' 'g' 'c' 'b' 'm'};
		for i=1:length(scores)
			single_bar = zeros(size(scores));
			single_bar(i) = scores(i);
			bar(single_bar, bar_colors{mod(i,length(bar_colors))});
		end

	else
		varargout{1} = 0;
	end
	
end
