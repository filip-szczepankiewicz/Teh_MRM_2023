clear

%% NOW - Numerically Optimized Waveform
%  Requires framework: https://github.com/jsjol/NOW

p = optimizationProblem();
p.sMax = 100;
p.doMaxwellComp = 1;

% Set time scale
dtin   = 8.08/8;

% Set b-tensor anisotropy factor. This ensures that one sub-axis from PTE will
% be able to reach the same b-value as the full PTE.
anisoF = 0.5;

p.durationFirstPartRequested = 40*dtin;
p.targetTensor = [0 0 0; 0 anisoF 0; 0 0 1];
p.durationSecondPartRequested = p.durationFirstPartRequested;
p.durationZeroGradientRequested = 8*dtin;

% Engage motion compensation (https://doi.org/10.1002/mrm.28551)
p.motionCompensation.linear = [1 1 ];
p.motionCompensation.order = [1 2 ];
p.motionCompensation.maxMagnitude = [0 0];


p.N = (p.durationFirstPartRequested+p.durationSecondPartRequested+p.durationZeroGradientRequested)/dtin;
p = optimizationProblem(p);

r = NOW_RUN(p);


% Undo the anisotropy factor to get PTE
gwf = r.gwf ./ sqrt([1 anisoF 1]);

plot(gwf)



%% Separate and save the GWF
R_pte   = r;
R_lte_y = r;
R_lte_z = r;

% PTE
% In the paper, the exact shape was forced to be exactly PTE (see section 2.4 in https://doi.org/10.1016/j.jneumeth.2020.109007, note the missing square before eq. 11)
g_pte = r.gwf.*[0 1 1]; 

% LTE (short td)
g_lte_y = g_pte(:,2)*[1 0 0];
g_lte_y = g_lte_y/max(abs(g_lte_y(:)));

% LTE (long td)
g_lte_z = g_pte(:,3)*[1 0 0];
g_lte_z = g_lte_z/max(abs(g_lte_z(:)));

% Copy and replace an optimization result to use the write function.
R_pte.g   = g_pte   .*r.rf;
R_lte_y.g = g_lte_z .*r.rf;
R_lte_z.g = g_lte_y .*r.rf;


fn1 = {'FWF_CUSTOM001_AB', 'FWF_CUSTOM001_A', 'FWF_CUSTOM001_B'};
fn2 = {'FWF_CUSTOM002_AB', 'FWF_CUSTOM002_A', 'FWF_CUSTOM002_B'};
fn3 = {'FWF_CUSTOM003_AB', 'FWF_CUSTOM003_A', 'FWF_CUSTOM003_B'};

now_write_wf(R_pte,   p, pwd, fn1)
now_write_wf(R_lte_y, p, pwd, fn2)
now_write_wf(R_lte_z, p, pwd, fn3)


