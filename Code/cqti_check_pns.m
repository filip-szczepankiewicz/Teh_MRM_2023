clear

%% Load an scale GWF

load("cqti_NOW_result.mat");

% This is roughly correct, and the analysis in the paper is based on the
% actual waveform used by the scanner.

dt  = r.dt * (43.44*2+8.68)/p.totalTimeActual;
q   = 2.6751e+08 * cumsum( r.gwf.*r.rf, 1 ) * dt;
b   = trace(q'*q)*dt;
gwf = r.gwf * sqrt(1.5e9/b);



%% Check PNS
% Requires framework: https://github.com/filip-szczepankiewicz/safe_pns_prediction

% Set MRI system parameters
hw = safe_hw_prisma_xr_sh05; % This info is confidentail, but can be shared at the MAGNETOM forum or email (FSz).

% Best results when gwf is interpolated to proper gradient raster time
% [gwf, rf, dt] = gwf_interp(gwf, r.rf, dt, round((length(gwf)-1)*dt/10e-6));

pns = safe_gwf_to_pns(gwf, r.rf, dt, hw, 1);

figure(1)
clf
safe_plot(pns, dt)



