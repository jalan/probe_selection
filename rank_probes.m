function [ranked_list scores optimized_parameters varargout] = ...
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
	if ~((nargout == 3) || (nargin == 4))
		error('rank_probes:invalid_argument', ...
			'Number of output arguments must be three or four');
	end

	%% TODO: main code...







	%% Optionally make a figure
	if make_figure
		% TODO
	end
	
end
