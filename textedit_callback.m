function textedit_callback(gcbo, ~)
global figs

% Find which axes we are associated with
for in = figs.type.scatter
    inG = find(figs.gates(in).hEdit' == gcbo);
    if ~isempty(inG)
        break;
    end
end

%if no axes are associated try to scan if we are editting the gate name box
if isempty(inG)
    for in = figs.type.scatter
        inG = find(figs.gates(in).hName' == gcbo);
        if ~isempty(inG)
            figs.gates(in).gName{inG} = get(gcbo, 'String');
            return
        end
    end
end
% Get coordinates of the textbox handles
inY = ceil(inG / 4);
inX = inG - 4 * (inY - 1);


% Get the limits of the axes we are working in
xl = get(figs.hChildern(10, in), 'XLim');
yl = get(figs.hChildern(10, in), 'YLim');

% Convert the value to a number
val = str2num(get(gcbo, 'String')); %#ok<ST2NM>
if isempty(val)
    set(gcbo, 'String', get(gcbo, 'Tag'))
    return
end

val = round2places(val, 3);

switch inX
    case 1
        %val = log2lin(val, xl);
        if val > figs.gates(in).pos(inY, 3)
            figs.gates(in).pos(inY, 1) = figs.gates(in).pos(inY, 3);
        elseif val > xl(2)
            figs.gates(in).pos(inY, 1) = xl(2);
        elseif val < xl(1)
            figs.gates(in).pos(inY, 1) = xl(1);
        else
            figs.gates(in).pos(inY, 1) = val;
        end
    case 2
        %val = log2lin(val, xl);
        if val < figs.gates(in).pos(inY, 1)
            figs.gates(in).pos(inY, 3) = figs.gates(in).pos(inY, 1);
        elseif val > xl(2)
            figs.gates(in).pos(inY, 3) = xl(2);
        elseif val < xl(1)
            figs.gates(in).pos(inY, 3) = xl(1);
        else
            figs.gates(in).pos(inY, 3) = val;
        end
    case 3
        %val = log2lin(val, xl);
        if val > figs.gates(in).pos(inY, 4)
            figs.gates(in).pos(inY, 2) = figs.gates(in).pos(inY, 1);
        elseif val > yl(2)
            figs.gates(in).pos(inY, 2) = yl(2);
        elseif val < yl(1)
            figs.gates(in).pos(inY, 2) = yl(1);
        else
            figs.gates(in).pos(inY, 2) = val;
        end
    case 4
        %val = log2lin(val, xl);
        if val < figs.gates(in).pos(inY, 2)
            figs.gates(in).pos(inY, 4) = figs.gates(in).pos(inY, 2);
        elseif val > yl(2)
            figs.gates(in).pos(inY, 4) = yl(2);
        elseif val < yl(1)
            figs.gates(in).pos(inY, 4) = yl(1);
        else
            figs.gates(in).pos(inY, 4) = val;
        end
end
set(gcbo, 'String', num2str(val))
pos(1, [1 3]) = log2lin(figs.gates(in).pos(inY, [1 3]), xl);
pos(1, [2 4]) = log2lin(figs.gates(in).pos(inY, [2 4]), yl);
pos(3) = pos(3) - pos(1);
pos(4) = pos(4) - pos(2);

% Work out the handle of the gate
inG = sum(figs.gates(in).gates(1 : inY) == figs.gates(in).gates(inY));
if figs.gates(in).gates(inY) == 1
    h = figs.gates(in).hRect(inG);
elseif figs.gates(in).gates(inY) == 2
    h = figs.gates(in).hElli(inG);
end
regionResize(pos, h);

end


function out = log2lin(in, lims)
    out = (log10(in) - log10(lims(1))) / (log10(lims(2)) - log10(lims(1)));
end


function out = round2places(in, pl)
    coef = 10 .^ (floor(log10(abs(in))) - pl + 1);
    out = round(in ./ coef) .* coef;
end