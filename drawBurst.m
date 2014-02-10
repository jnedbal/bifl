function drawBurst(i, hAxes, hGaxes)
global figs
global data
global param

axes(hAxes);


% if param.os
%     tit = [figs.tits{1, i}, repmat(' ', 1, figs.tits{2, i})];
%     xlab = [figs.xlabs{1, i}, repmat(' ', 1, figs.xlabs{2, i})];
%     ylab = [figs.ylabs{1, i}, repmat(' ', 1, figs.ylabs{2, i})];
%     if param.flow
%         y2lab = [figs.y2labs{1, i}, repmat(' ', 1, figs.y2labs{2, i})];
%     end
% else
    tit = figs.tits{1, i};
    xlab = figs.xlabs{1, i};
    ylab = figs.ylabs{1, i};
    if param.flow
        y2lab = figs.y2labs{1, i};
    end
% end

title(tit, 'FontName', 'FixedWidth');
xlabel(xlab, 'FontName', 'FixedWidth');
ylabel(ylab, 'FontName', 'FixedWidth');
set(hAxes, 'FontName', 'FixedWidth', 'LineWidth', 1)
hold on
box on

if i < 5
    % we will plot points of the graph different to its neighbors
    in = figs.starts(i) : figs.ends(i);
    y = [0, data.bHist(in), 0, 0];
    in = in(any([y(2 : end - 2) - y(3 : end - 1); y(1 : end - 3) - y(2 : end - 2)]));
    
    % x limits
    xl = data.X([figs.starts(i), figs.ends(i)]) + param.binsize * [-0.5, 0.5];

    plot(data.X(in), data.bHist(in), 'Color', [0.5 0.5 0.5])

    for j = find(data.burstStarts < figs.ends(i) & data.burstEnds > figs.starts(i))
        in = data.burstStarts(j) : data.burstEnds(j);
        plot(data.X(in), data.bHist(in), figs.cols{mod(j, numel(figs.cols)) + 1})
    end
    plot(xl, param.thres * [1 1], 'k--', ...
        'LineWidth', 2)
    text(xl(1), param.thres + 0.02 * diff(get(hAxes, 'YLim')), ...
         sprintf(' %g', param.thres), ...
         'FontName', 'FixedWidth', 'VerticalAlignment', 'baseline');
    set(hAxes, 'XLim', xl)

else
    X = (0 : size(data.burstShapes, 2) - 1) * param.binsize * 1000;
    Y = mean(data.burstShapes, 1);
    X = [X, fliplr(X)];
    Y = [Y + std(data.burstShapes, 0, 1), ...
         fliplr(Y - std(data.burstShapes, 0, 1))];
    fill(X, Y, [0.8 0.8 0.8], 'EdgeColor', 'none');
    hold on
    X = (0 : size(data.burstShapes, 2) - 1) * param.binsize * 1000;
    Y = mean(data.burstShapes, 1);
    plot(X, Y, 'k-', 'LineWidth', 2)
    set(hAxes, 'XLim', X([1 end]), ...
        'YLim', [0, max(get(hAxes, 'YLim'))], 'XGrid','on')
end

if any(figs.hAxes == hAxes)
    % Make axes clickable
    set(hAxes, 'ButtonDownFcn', @mouseclick_callback);
    set(get(hAxes, 'Children'), 'ButtonDownFcn', @mouseclick_callback);
end

%% Draw flow curve if requested
if ~param.flow || i > 4
    % Make sure invisible figure is invisible
    if ishandle(hGaxes) && hGaxes > 0
        set(hGaxes, 'color', 'none', 'XTick', [], 'YTick', [])
    end
    % Stop program if not needed
    return
end

axes(hGaxes);
tag = get(hGaxes, 'Tag');       % we need to reset the tag

col = str2num(param.pumpTag); %#ok<ST2NM>
in = ~isnan(data.flowValue(:, col));
plot(data.flowTime(in), data.flowValue(in, col), 'r-', 'LineWidth', 2, ...
     'ButtonDownFcn', @mouseclick_callback)
ylim = get(hGaxes, 'YLim');
set(hGaxes, 'YLim', [max(0, ylim(1)), ylim(2)], ...
    'XLim', xl, 'color', 'none', 'XTick', [], ...
    'FontName', 'FixedWidth', 'YAxisLocation', 'right', ...
    'YColor', 'r', 'Box', 'off', 'ButtonDownFcn', @mouseclick_callback, ...
    'Tag', tag);
ylabel(y2lab, 'FontName', 'FixedWidth');
if isempty(figs.ylimflow)
    figs.ylimflow = get(hGaxes, 'YLim');
    figs.ytickflow = get(hGaxes, 'YTick');
else
    set(hGaxes, 'YLim', figs.ylimflow)
    set(hGaxes, 'YTick', figs.ytickflow)
end

