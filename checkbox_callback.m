function checkbox_callback(gcbo, ~)

global figs

% Find which axes we are associated with
for in = figs.type.scatter
    inG = find(figs.gates(in).hCheck == gcbo);
    if ~isempty(inG)
        break;
    end
end

% Delete all associated objects
figs.gates(in).checked(inG) = get(gcbo, 'Value');

if figs.gates(in).checked(inG)
    col = figs.col{inG};
else
    col = [0.5 0.5 0.5];
end


% Delete rectangle if it is a rectangle
if figs.gates(in).gates(inG) == 1
    gt = sum(figs.gates(in).gates(1 : inG) == 1);
    setColor(figs.gates(in).hRect(gt), col);

% Delete ellipse if it is an ellipse
elseif figs.gates(in).gates(inG) == 2
    gt = sum(figs.gates(in).gates(1 : inG) == 2);
    setColor(figs.gates(in).hElli(gt), col);
end
