function drawBursts_dT(mf, st, en, fname, thres)
global fifo

figure('position', [100 50 640 800], 'Color', [1 1 1])

% invisible axis for title
axes('Position', [0 0 1 1], 'Xlim', [0 1], 'Ylim', [0 1], 'Box', 'off', ...
     'Visible', 'off', 'Units', 'normalized', 'clipping' , 'off');
text(0.5, 1, sprintf('Burst Segmentation (%s)', ...
     regexprep(fname, '_', '\\_')), 'HorizontalAlignment', 'center', ...
     'VerticalAlignment', 'top', 'FontName', 'FixedWidth');
 
cols = {'b-', 'c-', 'g-', 'y-', 'm-', 'r-'};

% half-length of burst in seconds
starts = ones(1, 4);
ends = [numel(fifo.macroT) - 1, 1 / fifo.MTC, 1, 1];
[~, ends(2)] = min(abs(fifo.macroT * fifo.MTC - 1));
for i = [3, 4; 2, numel(st) - 1]
    hlb = diff(fifo.macroT([st(i(2)) en(i(2))])) * fifo.MTC / 2;
    [~, starts(i(1))] = min(abs(fifo.macroT * fifo.MTC - (fifo.macroT(st(i(2))) * fifo.MTC - hlb)));
    [~, ends(i(1))] = min(abs(fifo.macroT * fifo.MTC - (fifo.macroT(en(i(2))) * fifo.MTC + hlb)));
end

% Make sure starts and ends are not out of limits
ends = min(ends, numel(fifo.macroT) - 1);
starts = max(starts, 1);

pos = [640, 450, 260, 70];
js = [1, 1, 2, numel(st) - 1];
tits = {sprintf('Entire Experiment (%d Bursts)', numel(st)), ...
        'First Second of the Experiment', ...
        'Second Burst', 'Second from Last Burst'};

for i = 1 : 4;
    axes('Units', 'Pixels', 'Position', [72, pos(i), 496, 110]); %#ok<LAXES>
    plot(fifo.macroT(starts(i) : ends(i)) * fifo.MTC, mf(starts(i) : ends(i)), 'Color', [0.5 0.5 0.5])
    set(gca, 'XLim', fifo.macroT([starts(i), ends(i)]) * fifo.MTC)
    hold on
    title(tits{i}, 'FontName', 'FixedWidth');
    ylabel('1/\DeltaT (s^{-1})', 'FontName', 'FixedWidth');
    xlabel('Time (s)', 'FontName', 'FixedWidth');
    set(gca, 'FontName', 'FixedWidth', 'LineWidth', 1)
    box on
    j = js(i);
    while en(j) < ends(i)
        plot(fifo.macroT(st(j) : en(j)) * fifo.MTC, mf(st(j) : en(j)), cols{mod(j, numel(cols)) + 1})
        j = j + 1;
        if j > numel(en)
            break
        end
    end
    plot(get(gca, 'XLim'), thres * [1 1], 'k--', 'LineWidth', 2)
    text(min(get(gca, 'XLim')), ...
         thres + 0.02 * diff(get(gca, 'YLim')), ...
         sprintf(' %g', thres), ...
         'FontName', 'FixedWidth', 'VerticalAlignment', 'baseline');
end