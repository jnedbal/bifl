function [h, name, nr] = createGate(pos, type, in, gatename, checked)
global figs

if nargin < 5
    checked = 1;
end

switch type
    case 'rectangle'
        h = imrect(figs.hChildern(11, in), pos);
        figs.gates(in).nrRect = figs.gates(in).nrRect + 1;
        nr = figs.gates(in).nrElli + figs.gates(in).nrRect;
        figs.gates(in).gates(nr) = 1;
        if isempty(figs.gates(in).nrRect) || figs.gates(in).nrRect == 1
            figs.gates(in).hRect = h;
        else
            figs.gates(in).hRect(figs.gates(in).nrRect) = h;
        end
        name = sprintf('R%d', figs.gates(in).nrRect);
        addNewPositionCallback(h, @(p) regionResize(p, h));
        fcn = makeConstrainToRectFcn('imrect', [0, 1], [0, 1]);
        setPositionConstraintFcn(h, fcn);
        if checked
            col = figs.col{nr};
        else
            col = [0.5 0.5 0.5];
        end
        setColor(h, col);
    case 'ellipse'
        h = imellipse(figs.hChildern(11, in), pos);
        figs.gates(in).nrElli = figs.gates(in).nrElli + 1;
        nr = figs.gates(in).nrElli + figs.gates(in).nrRect;
        figs.gates(in).gates(nr) = 2;
        if isempty(figs.gates(in).nrElli) || figs.gates(in).nrElli == 1
            figs.gates(in).hElli = h;
        else
            figs.gates(in).hElli(figs.gates(in).nrElli) = h;
        end
        name = sprintf('E%d', figs.gates(in).nrElli);
        addNewPositionCallback(h, @(p) regionResize(p, h));
        fcn = makeConstrainToRectFcn('imellipse', [0, 1], [0, 1]);
        setPositionConstraintFcn(h, fcn);
        if checked
            col = figs.col{nr};
        else
            col = [0.5 0.5 0.5];
        end
        setColor(h, col);
end

% Vertical position of the uicontrols
vpos = 1.08 - 0.19 * nr;

% Create check boxes
if isfield(figs.gates, 'checked')
    figs.gates(in).checked(nr) = checked;
else
    figs.gates(in).checked = checked;
end
figs.gates(in).hCheck(nr) = ...
    uicontrol('Units', 'normalized', ...
              'Style', 'checkbox', ...
              'String', name, ...
              'Position', [0.6 vpos 0.08 0.05], ...
              'Callback', @checkbox_callback, ...
              'FontName', 'FixedWidth', ...
              'BackgroundColor', [1 1 1], ...
              'Value', checked, ...
              'ForegroundCOlor', figs.col{nr});

% Create position text edit boxes
hpos = [0.7 0.82 0.7 0.82];
vpos = vpos + [0 0 -0.06 -0.06];

for i = 1 : 4
    figs.gates(in).hEdit(nr, i) = ...
        uicontrol('Units', 'normalized', ...
                  'Style', 'edit', ...
                  'String', '0.1', ...
                  'Position', [hpos(i) vpos(i) 0.1 0.05], ...
                  'Callback', @textedit_callback, ...
                  'FontName', 'FixedWidth', ...
                  'BackgroundColor', [1 1 1]);
end

% Create delete button
figs.gates(in).hDelBut(nr) = ...
    uicontrol('Units', 'normalized', ...
              'Style', 'pushbutton', ...
              'String', 'del', ...
              'Position', [0.6 vpos(i) 0.07 0.05], ...
              'Callback', @delButton_callback, ...
              'FontName', 'FixedWidth');

% Create gate name text edit box
if nargin < 4
    gatename = name;
    figs.gates(in).gName{nr} = gatename;
end
if isfield(figs.gates, 'gName')
    figs.gates(in).gName{nr} = gatename;
else
    figs.gates(in).gName = gatename;
end
figs.gates(in).hName(nr) = ...
    uicontrol('Units', 'normalized', ...
              'Style', 'edit', ...
              'String', gatename, ...
              'Position', [0.6 vpos(i) - 0.06 0.32 0.05], ...
              'Callback', @textedit_callback, ...
              'FontName', 'FixedWidth', ...
              'BackgroundColor', [1 1 1]);


if nr == 4
    set(figs.hChildern(1, in), 'Enable', 'off');
    set(figs.hChildern(2, in), 'Enable', 'off');
end