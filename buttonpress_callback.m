function buttonpress_callback(gcbo, ~)
global figs
global param


%% Figure handle to which the button belongs to
hFig = get(gcbo, 'Parent');

%% Index of the plot the button belongs to
in = find(figs.hFig == hFig);

switch get(gcbo, 'String')
    case 'print'
        %% If print button was pressed
        tit = regexprep(figureTitle(in), ' ', '-');
        fname = sprintf('%s_%s.eps', param.fname, tit);
        [fname, PathName] = uiputfile('*.eps', ...
                                      'Save files with gates', fname);

        % stop if cancel button is pressed
        if isequal(fname, 0)
            return
        end
        set(findobj(gcf, 'Type', 'uicontrol'), 'Visible', 'off');
        print(gcf, [PathName fname], '-depsc')
        set(findobj(gcf, 'Type', 'uicontrol'), 'Visible', 'on');
        return

    case 'Accept Gates'
        %% If Accept Gates button was pressed
        acceptGates(gcbo);
        return
end


%% update scatter plots
if any(figs.type.bursts == in)
    redrawBursts(in);
end

%% If button is on the scatter plot screen
if any(figs.type.scatter == in)
    type = get(gcbo, 'String');
    switch type
        case {'rectangle', 'ellipse'}
            % Generate a cell with colors of gates
            figs.col = {'b', 'r', [0.2, 0.6, 0], [0.8, 0.8, 0.2]};

            pos = [0.1, 0.1, 0.8, 0.8];
            type = get(gcbo, 'String');
            h = createGate(pos, type, in);

            % Update the drawing and the values in the pos vector
            regionResize(pos, h)
        case 'apply'
            cla(figs.hGaxes(in));
            axes(figs.hGaxes(in));
            
            % Convert positions to linear scale 0 to 1
            pos = pos_log2lin(figs.gates(in).pos, figs.hAxes(in));

            for i = find(figs.gates(in).checked)
                rectangle('Position', pos(i, :), ...
                          'Curvature', ...
                          [1 1] * (figs.gates(in).gates(i) - 1), ...
                          'EdgeColor', figs.col{i}, ...
                          'ButtonDownFcn', @mouseclick_callback);
            end
            fields = fieldnames(figs.gates)';
            for field = fields
                figs = setfield(figs, 'selGates', {in}, field{1}, ...
                    getfield(figs, 'gates', {in}, field{1}));
            end
            closefig_callback(hFig, []);
    end
end
