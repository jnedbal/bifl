function drawPhasor(hAxes)
global data

cla(hAxes);
axes(hAxes);

hold on

% Axes limits
xl = [-0.1, 1.1];
yl = [-0.1, 0.6];

%% Draw the universal semicircle
x = -0.5 : 0.001 : 0.5;
y = sqrt(0.25 - x .^ 2);
plot(x + 0.5, y, 'b-', 'LineWidth', 1)

%% Draw cartesian coordinates
plot(xl, [0, 0], 'k-');
plot([0, 0], yl, 'k-');

%% Draw grids
for i = 0.1 : 0.1 : 1
    plot([i, i], yl, 'k:');
    if i < 0.6
        plot(xl, [i, i], 'k:');
    end
end

%% Generate a scatter plot of bursts
if any(data.gate)
    dscatter(data.phasorG(data.gate)', data.phasorS(data.gate)')
end

tit = 'Phasor Plot';
% if param.os
    tit = [tit, ''];
% end

title(tit, 'FontName', 'FixedWidth');

set(hAxes, 'XTick', [], 'YTick', [], 'XLim', [-0.1, 1.1], ...
    'YLim', [-0.1, 0.6], 'Box', 'on', ...
    'ButtonDownFcn', @mouseclick_callback);

ylabel('s(\omega)')
xlabel('g(\omega)')

set(get(hAxes, 'Children'), 'ButtonDownFcn', @mouseclick_callback);
