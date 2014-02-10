function drawDecay(hAxes)
global fifo
global param
global data
global figs

axes(hAxes);
cla(hAxes);
hold on

%% Collect all burst photons
in = false(1, numel(fifo.microT));
for i = find(data.gate)
    in(data.bursts(1, i) : data.bursts(2, i)) = true;
end
x = 0 : 16 : 4095;
y = [histc(fifo.microT(in & fifo.rout == 0), x); histc(fifo.microT(~in & fifo.rout == 0), x)];
% normalize histogram to the noise background median
ii = (0 : 16 : 4095) < param.analysisWindow(1);
yA = 1 ./ median(y(:, ii), 2);
y = y .* repmat(yA, 1, numel(ii));
y = y / max(max(y));


ii = (0 : 16 : 4095) < param.analysisWindow(1);
X{1} = x(ii); Y{1} = y(:, ii);
ii = x >= param.analysisWindow(1) & x <= param.analysisWindow(2);
x1 = []; y1 = [];
if ~isempty(X{1}) && any(in);
    x1 = X{1}(end); y1 = Y{1}(:, end);
end
X{2} = [x1, x(ii)]; Y{2} = [y1, y(:, ii)];
ii = x > param.analysisWindow(2);
x1 = []; y1 = [];
if ~isempty(X{2}) && any(ii);
    x1 = X{2}(end); y1 = Y{2}(:, end);
end
X{3} = [x1, x(ii)]; Y{3} = [y1, y(:, ii)];
gr = [0.8, 0.8, 0.8];               % gray color
lgr = [232, 232, 232] / 255;        % light-gray color
bl = [0, 0, 1];                     % blue color
lbl = [191, 191, 255] / 255;        % light-blue color
gn = [34, 139, 34] / 255;           % green color
lgn = [152, 178, 200] / 255;        % light-green color

col = {gr, gr; bl, gn; gr, gr};         % color cell
colf = {lgr, lgr; lbl, lgn; lgr, lgr};  % face color cell

hp = zeros(size(col));

for i = 1 : 3
    % If nothing to plot just skip to the next histogram segment
    if isempty(X{i})
        continue
    end
    for j = 1 : size(y, 1)
        % Histogram area
        area(X{i}, Y{i}(j, :), 'EdgeColor', 'none', 'FaceColor', colf{i, j});
        % Histogram outline
        hp(i, j) = plot(X{i}, Y{i}(j, :), 'Color', col{i, j}, 'LineWidth', 2);
    end
end

%% Generate a legend
if numel(X{1}) || numel(X{3})
    % legend with the gray line
    hp = [hp(2, :), hp(1)];
    leg = {'bursts', 'background', 'NA'};
else
    % legend without the gray line
    hp = hp(2, :);
    leg = {'bursts', 'background'};
end

tit = 'Normalized Fluorescence Decay';
if ~any(figs.hAxes == gca)
    ylab = 'Photon Frequency';
    pos = [0.6, 0.72, 0.22, 0.08];
else
    ylab = 'Ph Frequency';
    pos = [0.67, 0.5, 0.22, 0.08];
end
xlab = 'Micro Time (counts)';

legend(hp, leg, 'FontName', 'FixedWidth', 'Location', pos);


% if param.os
%     tit = [tit, '                '];
%     ylab = [ylab, '      '];
%     xlab = [xlab, '           '];
% end

title(tit, 'FontName', 'FixedWidth');
ylabel(ylab, 'FontName', 'FixedWidth');
xlabel(xlab, 'FontName', 'FixedWidth');

% Draw ticks
text(0, min(get(hAxes, 'YLim')) - diff(get(hAxes, 'YLim')) / 33, '0', ...
    'FontName', 'FixedWidth', 'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top')
text(4095, min(get(hAxes, 'YLim')) - diff(get(hAxes, 'YLim')) / 33, '4095', ...
    'FontName', 'FixedWidth', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top')

set(hAxes, 'Box', 'on', 'LineWidth', 1, 'XLim', [0 4095], ...
    'XTick', [], 'YTick', [], 'FontName', 'FixedWidth', ...
    'ButtonDownFcn', @mouseclick_callback)
set(get(hAxes, 'Children'), 'ButtonDownFcn', @mouseclick_callback);
