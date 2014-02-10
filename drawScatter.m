function drawScatter(in, hAxes)
global figs

[x, y] = xy4scatter(in);

axes(hAxes);
cla(hAxes);

tag = get(hAxes, 'Tag');
if ~ isempty(x)
    dscatter(x', y', 'logxlogy', true)
end
set(hAxes, 'Tag', tag);

dscatterticks;
if strcmp(get(hAxes, 'yscale'), 'linear')
    if iscell(figs.ylabs{1, in + 5})
        ylab = figs.ylabs{1, in + 5}{2};
        tit = figs.tits{1, in + 5}{2};
    else
        ylab = figs.ylabs{1, in + 5};
        tit = figs.tits{1, in + 5};
    end
    set(gca, 'YTick', []);
else
    if iscell(figs.ylabs{1, in + 5})
        ylab = figs.ylabs{1, in + 5}{1};
        tit = figs.tits{1, in + 5}{1};
    else
        ylab = figs.ylabs{1, in + 5};
        tit = figs.tits{1, in + 5};
    end
end
xlab = figs.xlabs{1, in + 5};

dscatterlabels(tit, ylab, xlab);

set(hAxes, 'FontName', 'FixedWidth', 'LineWidth', 1, 'Box', 'on', ...
    'ButtonDownFcn', @mouseclick_callback)
set(get(hAxes, 'Children'), 'ButtonDownFcn', @mouseclick_callback);
