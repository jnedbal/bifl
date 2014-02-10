function delButton_callback(gcbo, ~)
global figs

% Find which axes we are associated with
for in = figs.type.scatter
    inG = find(figs.gates(in).hDelBut == gcbo);
    if ~isempty(inG)
        break;
    end
end

% Delete all associated objects

% Delete rectangle if it is a rectangle
if figs.gates(in).gates(inG) == 1
    gt = sum(figs.gates(in).gates(1 : inG) == 1);
    delete(figs.gates(in).hRect(gt));
    figs.gates(in).hRect(gt) = [];
    figs.gates(in).nrRect = figs.gates(in).nrRect - 1;

% Delete ellipse if it is an ellipse
elseif figs.gates(in).gates(inG) == 2
    gt = sum(figs.gates(in).gates(1 : inG) == 2);
    delete(figs.gates(in).hElli(gt));
    figs.gates(in).hElli(gt) = [];
    figs.gates(in).nrElli = figs.gates(in).nrElli - 1;
end

% Delete the gate from list of gates
figs.gates(in).gates(inG) = [];

% Delete the gate position from the list of gates
figs.gates(in).pos(inG, :) = [];

% Delete the gate name from the list
figs.gates(in).gName(inG) = [];

% Delete the checked state from the list
figs.gates(in).checked(inG) = [];

% Delete the checkbox
delete(figs.gates(in).hCheck(inG));
figs.gates(in).hCheck(inG) = [];

% Delete the edit boxes
for i = 1 : 4
    delete(figs.gates(in).hEdit(inG, i));
end
figs.gates(in).hEdit(inG, :) = [];

% Delete the delete the gate name
delete(figs.gates(in).hName(inG));
figs.gates(in).hName(inG) = [];

% Delete the delete button itself
delete(figs.gates(in).hDelBut(inG));
figs.gates(in).hDelBut(inG) = [];

% Move all lower properties up a level
for i = inG : numel(figs.gates(in).gates)
    % Move the delete boxes
    pos = get(figs.gates(in).hDelBut(i), 'Position');
    pos(2) = pos(2) + 0.19;
    set(figs.gates(in).hDelBut(i), 'Position', pos);
    
    % Move the check boxes
    pos = get(figs.gates(in).hCheck(i), 'Position');
    pos(2) = pos(2) + 0.19;
    set(figs.gates(in).hCheck(i), 'Position', pos);

    % Move the position text boxes
    for j = 1 : 4
        pos = get(figs.gates(in).hEdit(i, j), 'Position');
        pos(2) = pos(2) + 0.19;
        set(figs.gates(in).hEdit(i, j), 'Position', pos);
    end

    % Move the gate name text box
    pos = get(figs.gates(in).hName(i), 'Position');
    pos(2) = pos(2) + 0.19;
    set(figs.gates(in).hName(i), 'Position', pos);
end

% Rename and recolor gates
% Move all lower properties up a level
for i = inG : numel(figs.gates(in).gates)
    % Re-color Check box
    set(figs.gates(in).hCheck(i), 'ForegroundColor', figs.col{i})

    % Work out the color that needs to be used
    if figs.gates(in).checked(i)
        col = figs.col{i};
    else
        col = [0.5 0.5 0.5];
    end

    % Now try to find the index of the gate
    % Try if it is any of the rectangular gates
    if figs.gates(in).gates(i) == 1
        % Find the hRect index
        inG = sum(figs.gates(in).gates(1 : i) == 1);
        % recolor
        setColor(figs.gates(in).hRect(inG), col)
    elseif figs.gates(in).gates(i) == 2
        % Find the hElli index
        inG = sum(figs.gates(in).gates(1 : i) == 2);
        % recolor
        setColor(figs.gates(in).hElli(inG), col)
    end

    % Rename gates
    gOld = get(figs.gates(in).hCheck(i), 'String');
    gNew = sprintf('%s%g', gOld(1), inG);
    set(figs.gates(in).hCheck(i), 'String', gNew)
    set(figs.gates(in).hName(i), 'String', ...
        regexprep(get(figs.gates(in).hName(i), 'String'), gOld, gNew))
    
end

% Make sure buttons creating new regions are enabled
set(figs.hChildern(1, in), 'Enable', 'on');
set(figs.hChildern(2, in), 'Enable', 'on');