function redrawBursts(in)
global figs
global data

% axes childern
cla(figs.hChildern(10, in), 'reset')
cla(figs.hChildern(11, in), 'reset')
%% Run the individual functions
switch find(figs.hChildern(1 : 8, in) == gcbo)
    % minus button, increase to 150 %
    case 1
        range = mean(double([figs.starts(in), figs.ends(in)])) + ...
            double(figs.ends(in) - figs.starts(in)) * [-3 3] / 4;
        figs.starts(in) = int32(max(range(1), 1));
        figs.ends(in) = int32(min(range(2), numel(data.bHist)));

    % plus button, decrease to 67 %
    case 8
        range = mean(double([figs.starts(in), figs.ends(in)])) + ...
            double(figs.ends(in) - figs.starts(in)) * [-1 1] / 3;
        figs.starts(in) = max(range(1), 1);
        figs.ends(in) = min(range(2), numel(data.bHist));
        
    % << button, move by 50 % left
    case 2
        dT = min(figs.starts(in) - 1, (figs.ends(in) - figs.starts(in)) / 2);
        figs.starts(in) = figs.starts(in) - dT;
        figs.ends(in) = figs.ends(in) - dT;

    % < button, move by 10 % left
    case 3
        dT = min(figs.starts(in) - 1, (figs.ends(in) - figs.starts(in)) / 10);
        figs.starts(in) = figs.starts(in) - dT;
        figs.ends(in) = figs.ends(in) - dT;

    % > button, move by 10 % right
    case 6
        dT = min(numel(data.bHist) - figs.ends(in), (figs.ends(in) - figs.starts(in)) / 10);
        figs.starts(in) = figs.starts(in) + dT;
        figs.ends(in) = figs.ends(in) + dT;

    % >> button, move by 50 % right
    case 7
        dT = min(numel(data.bHist) - figs.ends(in), (figs.ends(in) - figs.starts(in)) / 2);
        figs.starts(in) = figs.starts(in) + dT;
        figs.ends(in) = figs.ends(in) + dT;   

    % reset button
    case 4
        figs.starts(in) = figs.startsO(in);
        figs.ends(in) = figs.endsO(in);
end

drawBurst(in, figs.hChildern(10, in), figs.hChildern(11, in));

% update enable states of the buttons
es = enableState(figs.starts(in), figs.ends(in));
for i = [1 2 3 6 7 8]
    set(figs.hChildern(i, in), 'Enable', es{i});
end
