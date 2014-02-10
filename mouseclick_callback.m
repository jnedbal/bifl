function mouseclick_callback(gcbo, ~)
global figs

% Work out which axes was pressed
in = find(figs.hAxes == gcbo | figs.hAxes == get(gcbo, 'Parent'));

% Check if transparent axes was pressed
if isempty(in)
    in = find(figs.hGaxes == gcbo | figs.hGaxes == get(gcbo, 'Parent'));
end

if isempty(in)
    for i = get(gcf, 'Children')';
        ii = str2double(get(i, 'Tag'));
        if isnan(ii)
            continue
        end
        if isequal(get(i, 'color'), 'none')
            figs.hGaxes(ii) = i;
        else
            figs.hAxes(ii) = i;
        end
    end
    in = find(figs.hAxes == gcbo | figs.hAxes == get(gcbo, 'Parent'));
    
    % Check if transparent axes was pressed
    if isempty(in)
        in = find(figs.hGaxes == gcbo | figs.hGaxes == get(gcbo, 'Parent'));
    end
end

% create a figure if it does not already exist
if ~(figs.hFig(in) && ishandle(figs.hFig(in)))
    % Generate title name
    tit = figureTitle(in);

    figs.hFig(in) = figure('Name', tit, ...
                           'CloseRequestFcn', @closefig_callback, ...
                           'Units', 'normalized', 'Color', [1 1 1]);
    pos = [0.15 0.3 0.7 0.6];
    figs.hChildern(10, in) = axes('Position', pos);

    % figures with burst pictures
    if any(figs.type.bursts == in)
        % reset limits to the original value
        figs.starts(in) = figs.startsO(in);
        figs.ends(in) = figs.endsO(in);
        % create a transparent figure
        figs.hChildern(11, in) = axes;
        set(figs.hChildern(11, in), 'Position', pos, 'color', 'none', ...
            'Xlim', [0 1], 'Ylim', [0 1], 'XTick', [], 'YTick', []);
        drawBurst(in, figs.hChildern(10, in), figs.hChildern(11, in));
        width = [0.05 0.05 0.05 0.1 0.1 0.05 0.05 0.05];
        xpos = [0, 0.05, 0.1, 0.15, 0.25, 0.35, 0.40, 0.45] + 0.15 + ...
            (0 : (numel(width) - 1)) * (0.7-sum(width)) / (numel(width)-1);
        txt = {'-', '<<', '<', 'reset', 'print', '>', '>>', '+'};
        % buttons enable state
        es = enableState(figs.starts(in), figs.ends(in));
        for i = 1 : 8
            figs.hChildern(i, in) = ...
                uicontrol('Units', 'normalized', ...
                          'Style', 'pushbutton', ...
                          'String', txt{i}, ...
                          'Position', [xpos(i) 0.1 width(i) 0.05], ...
                          'Callback', @buttonpress_callback, ...
                          'Enable', es{i}, ...
                          'FontName', 'FixedWidth');
        end

    % figure with average burswt image and its standard deviation
    elseif in == figs.type.avgBurst
        drawBurst(in, figs.hChildern(10, in), figs.hChildern(11, in));

    % figure with 2D histograms
    elseif any(figs.type.scatter == in)
        drawScatter(in - 5, figs.hChildern(10, in))
        axis(figs.hChildern(10, in), 'square');
        pos = get(figs.hChildern(10, in), 'Position');
        pos(1) = 0;
        set(figs.hChildern(10, in), 'Position', pos);
        figs.hChildern(11, in) = axes;
        axis(figs.hChildern(11, in), 'square')
        set(figs.hChildern(11, in), 'Position', pos, 'color', 'none', ...
            'Xlim', [0 1], 'Ylim', [0 1], 'XTick', [], 'YTick', [], ...
            'Box', 'off')
        
        xpos = [0.10 0.3 0.5 0.7];
        width = [0.15 0.15 0.15 0.15];
        txt = {'rectangle', 'ellipse', 'apply', 'print'};
        % buttons enable state
        % es = enableState(figs.starts(in), figs.ends(in));
        es = {'on', 'on', 'on', 'on'};
        for i = 1 : 4
            figs.hChildern(i, in) = ...
                uicontrol('Units', 'normalized', ...
                          'Style', 'pushbutton', ...
                          'String', txt{i}, ...
                          'Position', [xpos(i) 0.1 width(i) 0.05], ...
                          'Callback', @buttonpress_callback, ...
                          'Enable', es{i}, ...
                          'FontName', 'FixedWidth');
        end

        % Draw gates if they exist
        % First store the parameters of the gates
        if ~isfield(figs.gates(in), 'gName')
            return
        end
        pos = figs.gates(in).pos;
        gName = figs.gates(in).gName;
        gates = figs.gates(in).gates;
        checked = figs.gates(in).checked;
        if isempty(pos)
            return
        end

        % Reset gate parameters
        clearGates(in)

        % Convert positions to linear scale 0 to 1
        pos = pos_log2lin(pos, figs.hChildern(10, in));

        % Create new gates with the same parameters
        for i = 1 : numel(gName)
            % Get the right type of gate
            switch gates(i)
                case 1
                    type = 'rectangle';
                case 2
                    type = 'ellipse';
            end

            % Create the gate itself
            h = createGate(pos(i, :), type, in, gName{i}, checked(i));

            % Update the drawing and the values in the pos vector
            regionResize(pos(i, :), h)
        end

	% figure with average decay curve
    elseif in == 10
        drawDecay(figs.hChildern(10, in))

	% figure with phasor plot
    elseif in == 11
        drawPhasor(figs.hChildern(10, in))
    end
else
    figure(figs.hFig(in));
end

end
