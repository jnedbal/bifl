function displayReport(hAxes)
global param
global data

cla(hAxes);
axes(hAxes);

% line index
l = 0;

% rendering on linux is problematic for figure export, therefore we will
% have to define the plusminus and mu signs accordingly
% if param.os
%     pm = '   \pm';
%     mu = '   \mu';
% else
%     pm = '\pm';
%     mu = '\mu';
% end

parX = 0.1 * ones(1, 13);
valX = 0.7 * ones(1, 13);

% binsize for histogram-based segmentation
if param.binsize
    l = l + 1;
    par{l} = 'bin size:';
    val{l} = sprintf('%g \\mus\n', param.binsize * 1e+6);
end

% median filter kernel size
l = l + 1;
par{l} = 'median filter:';
val{l} = sprintf('%g', param.medif);

% burst threshold
l = l + 1;
par{l} = 'burst threshold:';
val{l} = sprintf('%g', param.thres);

% minimum photons
l = l + 1;
par{l} = 'minimum photons:';
val{l} = sprintf('%g', param.hvMin);

% phasor frequency
l = l + 1;
par{l} = 'phasor freq:';
val{l} = sprintf('%g MHz', param.phasorFreq / 2e+6 / pi);

% analysis window
l = l + 1;
par{l} = 'analysis window:';
val{l} = '';
l = l + 1;
par{l} = '';
val{l} = sprintf('%g ns-%g ns (%g-%g)', ...
                 0.1 * round(100 * param.analysisWindow / 4095), ...
                 param.analysisWindow);
valX(l) = 0.15;

% separator
l = l + 1;
par{l} = '-------------------------';
val{l} = '';

% number of burst
l = l + 1;
par{l} = 'bursts:';
val{l} = sprintf('%g', size(data.bursts, 2));
valX(l) = 0.4;

% number of gated bursts
if sum(data.gate) < numel(data.gate)
    l = l + 1;
    par{l} = 'gated:';
    val{l} = sprintf('%g', sum(data.gate));
    valX(l) = 0.4;
end

% phasor parameters

[gm, gs] = roundtoerror(mean(data.phasorG(data.gate)), std(data.phasorG(data.gate)));
[sm, ss] = roundtoerror(mean(data.phasorS(data.gate)), std(data.phasorS(data.gate)));
[tm, ts] = roundtoerror(mean(data.tau(data.gate) * 1e+9), std(data.tau(data.gate) * 1e+9));

% phasor G component
l = l + 1;
par{l} = 'g:';
val{l} = sprintf('%g\\pm%g', gm, gs);
valX(l) = 0.4;

% phasor S component
l = l + 1;
par{l} = 's:';
val{l} = sprintf('%g\\pm%g', sm, ss);
valX(l) = 0.4;

% fluorescence lifetime component
l = l + 1;
par{l} = '\tau:';
val{l} = sprintf('%g\\pm%g', tm, ts);
valX(l) = 0.4;

for i = l : -1 : 1
    text(parX(i), (l - i + 0.5) / l, par{i}, 'VerticalAlignment', 'Baseline', ...
         'FontName', 'FixedWidth', 'Color', [0.4, 0.4, 0.4]);
    text(valX(i), (l - i + 0.5) / l, val{i}, 'VerticalAlignment', 'Baseline', ...
         'FontName', 'FixedWidth');
end


set(hAxes, 'Visible', 'off')