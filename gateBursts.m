function gateBursts
global data
global figs

data.gate = true(1, size(data.bursts, 2));

for in = figs.type.scatter
    [x, y] = xy4scatter(in - figs.type.scatter(1) + 1);

    if in > numel(figs.selGates)
        break
    end
    
    % Run through the rectangular gates
    inG = find(figs.selGates(in).gates == 1 & figs.selGates(in).checked);
    for j = 1 : numel(inG)
        pos = figs.selGates(in).pos(inG(j), :);
        data.gate = data.gate & ...
                (x > pos(1) & x < pos(3) & y > pos(2) & y < pos(4));
    end

    % Run through the elliptical gates
    inG = find(figs.selGates(in).gates == 2 & figs.selGates(in).checked);
    for j = 1 : numel(inG)
        % Get axis limits
        xl = get(figs.hAxes(in), 'XLim');
        yl = get(figs.hAxes(in), 'YLim');
        % Convert X and Y coordinates to the linear scale
        xLin = log2lin(x, xl);
        yLin = log2lin(y, yl);

        % Get the positions on the linear scale 0 to 1
        pos = pos_log2lin(figs.selGates(in).pos(inG(j), :), figs.hAxes(in));

        % Ellipse parameters on the linear scale
        xAx = pos(3) / 2;               % x axis
        yAx = pos(4) / 2;               % y axis
        xCen = pos(1) + xAx;     % x center
        yCen = pos(2) + yAx;     % y center
        data.gate = data.gate & ...
            (((xLin - xCen) / xAx) .^ 2 + ((yLin - yCen) / yAx) .^ 2 <= 1);
    end
end

% get microtime histogram

gate = find(~data.gate);
data.mask = ones(data.square);
data.mask(gate) = 0; %#ok<FNDSB>
data.mask = repmat(data.mask, [1, 1, 256]);
data.mask = permute(data.mask, [2, 3, 1]);


end



function out = log2lin(in, lims)
    out = (log10(in) - log10(lims(1))) / (log10(lims(2)) - log10(lims(1)));
end