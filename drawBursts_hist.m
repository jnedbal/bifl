function drawBursts_hist
global data
global figs
global param

%% Check if it is a linux computer
if isequal(computer, 'GLNXA64') || isequal(computer, 'GLNX86')
    param.os = true;
else
    param.os = false;
end

%% Create a new figure
figs.hMainFig = figure('Position', [100 50 640 800], 'Color', [1 1 1], ...
                       'Name', 'Burst Segmentation', 'Toolbar', 'none', ...
                       'Resize', 'off', 'CreateFcn', @openFigure, ...
                       'NumberTitle', 'off', 'Pointer', 'watch');
set(gcf, 'Tag', param.fname)

%% Create an invisible axis for title
axes('Units', 'pixels', 'Position', [72 785 506 19], 'Xlim', [0 1], ...
     'Ylim', [0 1], 'Box', 'off', 'Color', 'w', 'clipping', 'off', ...
     'Tag', 'Title Axis', 'YTick', [], 'XTick', [], 'XColor', 'w', ...
     'YColor', 'w');

txt = sprintf('Burst Segmentation (%s)', ...
     regexprep([param.fname param.ext], '_', '\\_'));
figs.hTitle = text(0.5, 0, txt, ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', ...
     'FontName', 'FixedWidth', 'FontWeight', 'bold');
% txt = sprintf('Burst Segmentation (%s)', [param.fname param.ext]);
% 
% uicontrol('Units', 'pixels', ...
%           'Style', 'text', ...
%           'String', txt, ...
%           'Position', [0 779 640 19], ...
%           'FontName', 'FixedWidth', ...
%           'BackgroundColor', 'none', ...
%           'HorizontalAlignment', 'center');


figs.cols = {'b-', 'c-', 'g-', 'y-', 'm-', 'r-'};

%% Four plots will be drawn, choose the starting and ending coordinates of
%  each of these plots
if numel(data.burstStarts) > 1
    starts = [1, 1, data.burstStarts(2) data.burstStarts(end - 1)];
    ends = [numel(data.X), round(1 / param.binsize), ...
            data.burstEnds(2), data.burstEnds(end - 1)];
    % half-length of burst in seconds
    hlb = [0, 0, ...
           (data.burstEnds(2) - data.burstStarts(2)) / 2, ...
           (data.burstEnds(end - 1) - data.burstStarts(end - 1)) / 2];
else
    starts = [1, 1, data.burstStarts(1)];
    ends = [numel(data.X), round(1 / param.binsize), ...
            data.burstEnds(1)];
    % half-length of burst in seconds
    hlb = [0, 0, (data.burstEnds(1) - data.burstStarts(1)) / 2];
end
starts = round(starts - hlb);
ends = round(ends + hlb);

    


% Make sure starts and ends are not out of limits
figs.ends = int32(min(ends, numel(data.X)));
figs.starts = int32(max(starts, 1));

figs.startsO = figs.starts;
figs.endsO = figs.ends;

%% Draw all axes
pos = [ 72, 640, 506, 110; ...
        72, 450, 506, 110; ...
        72, 260, 205, 110; ...
        72,  70, 205, 110; ...
       372,  70, 205, 300];
figs.hAxes = zeros(1, 5);
figs.hGaxes = zeros(1, 5);
figs.hFig = figs.hAxes;
figs.hChildern = zeros(7, 5);

% Titles for axes. The second line is number of spaces needed to center it
% in linux
figs.tits = ...
        {sprintf('Entire Experiment (%d Bursts)', ...
         numel(data.burstStarts)), 'First Second of the Experiment', ...
         'Second Burst', 'Second from Last Burst', ...
         'Average Burst Shape'; ...
         21, 21, 10, 14, 13};

% Correct if only one burst is present
if numel(starts == 3)
    figs.tits{1, 3} = 'First Burst';
end

figs.xlabs = {'Time (s)', 'Time (s)', 'Time (s)', 'Time (s)', ...
              'Time (ms)'; ...
              6, 6, 6, 6, 8};
figs.ylabs = {'Photon #', 'Photon #', 'Photon #', 'Photon #', ...
              'Photon Count (A.U.)'; ...
              4, 4, 4, 4, 9};

switch param.pumpString
    case ' Current Flow Rate [ul/min]'
        figs.y2labs = repmat({'Flow Rate'}, 1, 5);
    case ' Chamber Pressure [mbar]'
        figs.y2labs = repmat({'Pump Pressure'}, 1, 5);
    otherwise
        figs.y2labs = repmat({param.pumpString(2 : end)}, 1, 5);
end
% make sure to reset ylim value
figs.ylimflow = [];

for i = [figs.type.bursts, figs.type.avgBurst];
    % Correct if only one burst is present
    if numel(starts == 3) && i == 4
        continue;
    end
    
    figs.hAxes(i) = axes('Units', 'Pixels', 'Tag', num2str(i), ...
                         'Position', pos(i, :)); %#ok<LAXES>
    if i < 5
        figs.hGaxes(i) = axes('Units', 'Pixels', 'Tag', num2str(i), ...
                              'Position', pos(i, :), ...
                              'color', 'none', 'ButtonDownFcn', ...
                              @mouseclick_callback); %#ok<LAXES>
    end
    drawBurst(i, figs.hAxes(i), figs.hGaxes(i));
end

figs.selBursts = [1, 1, 2, numel(data.burstStarts) - 1];

