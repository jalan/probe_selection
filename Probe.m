classdef Probe

	properties
		name;        % what we should call this probe
		d;           % spin density, [1/g]
		Gamma_0_pp;  % anoxic linewidth, peak-to-peak, [G]
		sensitivity; % [G / mmHg pO2]
	end

	properties (Dependent = true) % can only be read, not set
		Gamma_0_hwhm; % anoxic linewidth, half-width at half-maximum, [G]
	end

	methods

		% constructor
		function probe = Probe(name, d, Gamma_0_pp, sensitivity)
			probe.name = name;
			probe.d = d;
			probe.Gamma_0_pp = Gamma_0_pp;
			probe.sensitivity = sensitivity;
		end

		% setter for property 'name'
		function probe = set.name(probe, name)
			if ~ischar(name)
				error('Probe:invalid_property', ...
					'name must be a character array');
			else
				probe.name = name;
			end
		end

		% setter for property 'd'
		function probe = set.d(probe, d)
			if ~isfloat(d) || ~isscalar(d) || ~(d>0)
				error('Probe:invalid_property', ...
					'd must be a positive scalar float');
			else
				probe.d = d;
			end
		end

		% setter for property 'Gamma_0_pp'
		function probe = set.Gamma_0_pp(probe, Gamma_0_pp)
			if ~isfloat(Gamma_0_pp) || ~isscalar(Gamma_0_pp) || ~(Gamma_0_pp>0)
				error('Probe:invalid_property', ...
					'Gamma_0_pp must be a positive scalar float');
			else
				probe.Gamma_0_pp = Gamma_0_pp;
			end
		end

		% setter for property 'sensitivity'
		function probe = set.sensitivity(probe, sensitivity)
			if ~isfloat(sensitivity) || ~isscalar(sensitivity) || ~(sensitivity>0)
				error('Probe:invalid_property', ...
					'sensitivity must be a positive scalar float');
			else
				probe.sensitivity = sensitivity;
			end
		end

		% getter for dependent property 'Gamma_0_hwhm'
		function value = get.Gamma_0_hwhm(probe)
			value = probe.Gamma_0_pp * sqrt(3)/2;
		end

	end

end
