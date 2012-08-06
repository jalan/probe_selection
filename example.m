%% Specify available probes
% These are the probes we happen to have on hand. You can add as many as you
% want here, in any order.

probe_list = {

	% "Lithium phthalocyanine: A probe for electron paramagnetic resonance
	% oximetry in viable biological systems". KJ Liu, P Gast, M Moussavi,
	% SW Norby, N Vahidi, T Walczak, M Wu, HM Swartz. Proceedings of the
	% National Academy of Sciences of the United States of America, 1993.
	Probe( ...
		'LiPc', ... % name
		9.2e19, ... % spin density, in spins/gram
		0.014,  ... % peak-to-peak anoxic linewidth, in Gauss
		0.0061  ... % sensitivity to O2, in Gauss/mmHg
	)

	% "Novel particulate spin probe for targeted determination of oxygen in
	% cells and tissues". RP Pandian, NL Parinandi, G Ilangovan, JL Zweier,
	% P Kuppusamy. Free Radical Biology & Medicine, 2003.
	Probe( ...
		'LiNc-BuO Tc', ... % name (Tc for "triclinic")
		7.2e20,        ... % spin density, in spins/gram
		0.21,          ... % peak-to-peak anoxic linewidth, in Gauss
		0.0085         ... % sensitivity to O2, in Gauss/mmHg
	)

	% "Molecular packing and magnetic properties of lithium naphthalocyanine
	% crystals: hollow channels enabling permeability and paramagnetic
	% sensitivity to molecular oxygen". RP Pandian, M Dolgos, C Marginean,
	% PM Woodward, PC Hammel, PT Manoharan, P Kuppusamy. Journal of Materials
	% Chemistry, 2009.

	% Notes: these are microcrystals, as opposed to nanocrystals;
	%        the source for the spin density value is unknown to me.
	Probe( ...
		'LiNc', ... % name
		6.8e20, ... % spin density, in spins/gram
		0.63,   ... % peak-to-peak anoxic linewidth, in Gauss
		0.0312  ... % sensitivity to O2, in Gauss/mmHg
	)

	% "A New Tetragonal Crystalline Polymorph of Lithium
	% Octa-n-Butoxy-Naphthalocyanine (LiNc-BuO) Radical: Structural, Magnetic
	% and Oxygen-Sensing Properties". RP Pandian, NP Raju, JC Gallucci,
	% PM Woodward, AJ Epstein, P Kuppusamy. Chemistry of Materials, 2010.
	Probe( ...
		'LiNc-BuO Tg', ... % name (Tg for "tetragonal")
		7.5e20,        ... % spin density, in spins/gram
		0.02,          ... % peak-to-peak anoxic linewidth, in Gauss
		0.00454        ... % sensitivity to O2, in Gauss/mmHg
	)

};

%% Specify the oxygen range
% Our example here is for in-vivo tumor measurements.
pO2_min = 0;  % lowest oxygen pressure we expect, in mmHg
pO2_max = 15; % highest oxygen pressure we expect, in mmHg

%% Scanning parameters
% Suppose we know these from some previous, similar experiments on the same
% instrument. If you don't know these, that's okay: they only affect the scale
% of our scores and the figures we draw, not the ranking of the probes. If you
% don't know them, then you can just leave these as they are.
sigma_N = 1e19; % noise standard deviation
M = 512;        % how many samples in our scan

%% Evaluate our probes using the 'average' ranking mode, and make a figure
[ranked_list, scores, parameters, handle] = ...
	rank_probes( ...
		probe_list, ... % our list of probes to evaluate
		pO2_min,    ... % lowest oxygen pressure we expect, in mmHg
		pO2_max,    ... % highest oxygen pressure we expect, in mmHg
		sigma_N,    ... % noise standard deviation at each sample
		M,          ... % how many samples in the scan
		'average',  ... % how to score each probe
		'yes'       ... % yes, produce a figure
	); %#ok: it's example code, so don't show a warning about unused variables

%% Evaluate our probes using the 'worst' ranking mode, and make a figure
[ranked_list, scores, parameters, handle] = ...
	rank_probes( ...
		probe_list, ... % our list of probes to evaluate
		pO2_min,    ... % lowest oxygen pressure we expect, in mmHg
		pO2_max,    ... % highest oxygen pressure we expect, in mmHg
		sigma_N,    ... % noise standard deviation at each sample
		M,          ... % how many samples in the scan
		'worst',    ... % how to score each probe
		'yes'       ... % yes, produce a figure
	);

%% More examples to try

% Try changing pO2_max to a very small or very large value and rerunning the
% code above--you'll see that the rankings change!
