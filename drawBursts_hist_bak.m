function drawBursts_hist(mf, st, en, fname, thres, binsize, burstshape)
global fifo

figure('position', [100 50 640 800], 'Color', [1 1 1])

% invisible axis for title
axes('Position', [0 0 1 1], 'Xlim', [0 1], 'Ylim', [0 1], 'Box', 'off', ...
     'Visible', 'off', 'Units', 'normalized', 'clipping' , 'off');
text(0.45, 1, sprintf('Burst Segmentation (%s)', ...
     regexprep(fname, '_', '\\_')), 'HorizontalAlignment', 'center', ...
     'VerticalAlignment', 'top', 'FontName', 'FixedWidth');
 
cols = {'b-', 'c-', 'g-', 'y-', 'm-', 'r-'};

X = binsize / 2 : binsize : fifo.macroT(end) * fifo.MTC - binsize / 2;
starts = [1, 1, st(2) st(end - 1)];
ends = [numel(X) round(1 / binsize) en(2) en(end - 1)];
% half-length of burst in seconds
hlb = [0, 0, (en(2) - st(2)) / 2, (en(end - 1) - st(end - 1)) / 2];
starts = round(starts - hlb);
ends = round(ends + hlb);


% Make sure starts and ends are not out of limits
ends = min(ends, numel(X));
starts = max(starts, 1);

% % Convert starts and ends in seconds into histogran numbers.
% endsH = round(ends / binsize);
% startsH = round(starts / binsize);
% 
% % Make sure starts and ends are not out of limits
% endsH = min(endsH, numel(mf));
% startsH = max(startsH, 1);



pos = [640, 450, 260, 70; 506, 506, 220, 220];
js = [1, 1, 2, numel(st) - 1];
tits = {sprintf('Entire Experiment (%d Bursts)                     ', numel(st)), ...
        'First Second of the Experiment                     ', ...
        'Second Burst          ', 'Second from Last Burst              '};

for i = 1 : 4;
    axes('Units', 'Pixels', 'Position', [72, pos(:, i)', 110]); %#ok<LAXES>
    plot(X(starts(i) : ends(i)), mf(starts(i) : ends(i)), 'Color', [0.5 0.5 0.5])
    set(gca, 'XLim', X([starts(i), ends(i)]) + binsize * [-0.5, 0.5])
    hold on
    title(tits{i}, 'FontName', 'FixedWidth');
    ylabel('photon #    ', 'FontName', 'FixedWidth');
    xlabel('Time (s)      ', 'FontName', 'FixedWidth');
    set(gca, 'FontName', 'FixedWidth', 'LineWidth', 1)
    box on
    j = js(i);
    while en(j) < ends(i)
        plot(X(st(j) : en(j)), mf(st(j) : en(j)), cols{mod(j, numel(cols)) + 1})
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
axes('Units', 'Pixels', 'Position', [368, pos(1, 4), 210, 300]);
X = (0 : size(burstshape, 2) - 1) * binsize * 1000;
Y = mean(burstshape);
X = [X, fliplr(X)];
Y = [Y + std(burstshape), fliplr(Y - std(burstshape))];
fill(X, Y, [0.8 0.8 0.8], 'EdgeColor', 'none');
hold on
X = (0 : size(burstshape, 2) - 1) * binsize * 1000;
Y = mean(burstshape);
plot(X, Y, 'k-', 'LineWidth', 2)
set(gca, 'XLim', X([1 end]), 'YLim', [0, max(get(gca, 'YLim'))], 'XGrid','on')
title('Average Burst Shape             ', 'FontName', 'FixedWidth');
ylabel('Photon Count (A.U.)         ', 'FontName', 'FixedWidth');
xlabel('Time (ms)        ', 'FontName', 'FixedWidth');
set(gca, 'FontName', 'FixedWidth', 'LineWidth', 1)
box on