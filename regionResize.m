function regionResize(p, handle)
global figs

% find in which axis we are drawing
in = find(figs.hChildern(11, :) == gca);

% Now try to find the index of the gate
% Try if it is any of the rectangular gates
inG = eq(figs.gates(in).hRect, handle);
if any(inG)
    % Find the overall index of the gate
    inG = sum(find(figs.gates(in).gates == 1) .* inG);
else
    % Try if it is any of the elliptical gates
    inG = eq(figs.gates(in).hElli, handle);
    inG = sum(find(figs.gates(in).gates == 2) .* inG);
end

% Get the limits of the axes we are working in
xl = get(figs.hChildern(10, in), 'XLim');
yl = get(figs.hChildern(10, in), 'YLim');

% Map the linear positional value 0 to 1 onto the logarithmic axis
x = round2places(lin2log([p(1), p(1) + p(3)], xl), 3);
y = round2places(lin2log([p(2), p(2) + p(4)], yl), 3);

% Make sure we do not go over or below the axis limits
x = [max(x(1), xl(1)), min(x(2), xl(2))];
y = [max(y(1), yl(1)), min(y(2), yl(2))];

% Update the coordinates
set(figs.gates(in).hEdit(inG, 1), 'String', num2str(x(1)))
set(figs.gates(in).hEdit(inG, 2), 'String', num2str(x(2)))
set(figs.gates(in).hEdit(inG, 3), 'String', num2str(y(1)))
set(figs.gates(in).hEdit(inG, 4), 'String', num2str(y(2)))
set(figs.gates(in).hEdit(inG, 1), 'Tag', num2str(x(1)))
set(figs.gates(in).hEdit(inG, 2), 'Tag', num2str(x(2)))
set(figs.gates(in).hEdit(inG, 3), 'Tag', num2str(y(1)))
set(figs.gates(in).hEdit(inG, 4), 'Tag', num2str(y(2)))

% Convert back to the linear scale of 0 to 1
xx = log2lin(x, xl);
yy = log2lin(y, yl);

% Update the gate, but this does not work!!
setPosition(handle, [xx(1), yy(1), diff(xx), diff(yy)])

% Store the gate position
figs.gates(in).pos(inG, 1 : 4) = [x(1), y(1), x(2), y(2)];

end


function out = lin2log(in, lims)
    out = (10 .^ (log10(lims(2) / lims(1)) * in)) * lims(1);
end

function out = log2lin(in, lims)
    out = (log10(in) - log10(lims(1))) / (log10(lims(2)) - log10(lims(1)));
end

function out = round2places(in, pl)
    coef = 10 .^ (floor(log10(abs(in))) - pl + 1);
    out = round(in ./ coef) .* coef;
end