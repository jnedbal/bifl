function es = enableState(from, to)
global data

es = repmat({'on'}, 1, 8);
% zoom out button
if to - from + 1 >= numel(data.bHist)
    es{1} = 'off';
end

% zoom in button
if to - from <= 10
    es{8} = 'off';
end

% move left buttons
if from <= 1
    es{2} = 'off';
    es{3} = 'off';
end

% move right buttons
if to >= numel(data.bHist)
    es{6} = 'off';
    es{7} = 'off';
end
