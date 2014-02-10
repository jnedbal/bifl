function biflgui
clear global h
clear global param
global param
global h

close all

if exist('bifl.mat', 'file')
    load('bifl.mat')
end

param.folder = pwd;


h.Fig = figure('Position', [50 50 640 800], ...
              'Name', 'BIFL Analysis Options', 'Color', [1 1 1], ...
              'Toolbar', 'none', 'Resize', 'off', 'Units', 'pixels', ...
              'NumberTitle', 'off');

top = 800;
% maxW = 640;

%% Create tabs
h.Tab(1) = uicontrol('Units', 'pixels', ...
                     'Style', 'togglebutton', ...
                     'String', 'Files', ...
                     'FontName', 'FixedWidth', ...
                     'FontWeight', 'bold', ...
                     'BackgroundColor', 'w', ...
                     'HorizontalAlignment', 'left', ...
                     'Callback', @biflguibutton_callback, ...
                     'Value', 1);
ext = get(h.Tab(1), 'Extent');
pos = [20, top - 30, ext(3) + 10, 22];
set(h.Tab(1), 'Position', pos); 

h.Tab(2) = uicontrol('Units', 'pixels', ...
                     'Style', 'togglebutton', ...
                     'String', 'Parameters', ...
                     'FontName', 'FixedWidth', ...
                     'BackgroundColor', 'w', ...
                     'HorizontalAlignment', 'left', ...
                     'Callback', @biflguibutton_callback, ...
                     'Value', 0);
ext = get(h.Tab(2), 'Extent');
pos = [pos(3) + pos(1), top - 30, ext(3) + 10, 22];
set(h.Tab(2), 'Position', pos);

h.Tab(3) = uicontrol('Units', 'pixels', ...
                     'Style', 'togglebutton', ...
                     'String', 'Flow', ...
                     'FontName', 'FixedWidth', ...
                     'BackgroundColor', 'w', ...
                     'HorizontalAlignment', 'left', ...
                     'Callback', @biflguibutton_callback, ...
                     'Value', 0);
ext = get(h.Tab(3), 'Extent');
pos = [pos(3) + pos(1), top - 30, ext(3) + 10, 22];
set(h.Tab(3), 'Position', pos);

%% Select directory with files
h.Dir(1) = uicontrol('Units', 'pixels', ...
                     'Style', 'text', ...
                     'String', 'Current Directory:', ...
                     'Position', [20 top - 80 200 19], ...
                     'FontName', 'FixedWidth', ...
                     'BackgroundColor', 'w', ...
                     'HorizontalAlignment', 'left');

h.Dir(2) = uicontrol('Units', 'pixels', ...
                    'Style', 'text', ...
                    'String', param.folder, ...
                    'Position', [20 top - 110 400 19], ...
                    'FontName', 'FixedWidth', ...
                    'BackgroundColor', 'w', ...
                    'HorizontalAlignment', 'left');
pos = get(h.Dir(2), 'Extent');
set(h.Dir(2), 'Position', [20, top - 91 - pos(4), pos(3), pos(4)])
% maxW = max(maxW, 40 + pos(3));

h.Dir(3) = uicontrol('Units', 'pixels', ...
                    'Style', 'pushbutton', ...
                    'String', 'Change', ...
                    'Position', [220 top - 78 100 19], ...
                    'Callback', @biflguibutton_callback, ...
                    'FontName', 'FixedWidth');



labels = {'Histogram bin size:', 'Median filter kernel:', ...
          'Burst threshold:', 'Minimum burst photons:', ...
          'Phasor frequency:', 'Microtime window from:', ...
          'Microtime window to:'};
units = {[char(181) 's'], '', '', '', 'MHz', '', ''};
values = [20, 20, 1, 300, 160, 720, 3730];
h.ParamLab = zeros(size(labels));
h.ParamVal = zeros(size(labels));
h.ParamUns = zeros(size(labels));

x = 20;
for i = 1 : numel(labels)
    y = top - 50 - 30 * i;
    h.ParamLab(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'text', ...
                             'String', labels{i}, ...
                             'Position', [x, y, 180, 19], ...
                             'FontName', 'FixedWidth', ...
                             'BackgroundColor', 'w', ...
                             'HorizontalAlignment', 'left');

    h.ParamVal(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'edit', ...
                             'String', num2str(values(i)), ...
                             'Position', [190 + x, y + 3, 50, 19], ...
                             'FontName', 'FixedWidth', ...
                             'BackgroundColor', 'w', ...
                             'HorizontalAlignment', 'left');

    h.ParamUns(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'text', ...
                             'String', units{i}, ...
                             'Position', [250 + x, y, 30, 19], ...
                             'FontName', 'FixedWidth', ...
                             'BackgroundColor', 'w', ...
                             'HorizontalAlignment', 'left');
end

h.PDFs = uicontrol('Units', 'pixels', ...
                    'Style', 'checkbox', ...
                    'String', 'Combine into PDF', ...
                    'Position', [x y-30 150 19], ...
                    'Callback', @biflguicheckbox_callback, ...
                    'FontName', 'FixedWidth', ...
                    'BackgroundColor', 'w');

h.Reset = uicontrol('Units', 'pixels', ...
                    'Style', 'pushbutton', ...
                    'String', 'Reset', ...
                    'Position', [x y-60 240 19], ...
                    'Callback', @biflguibutton_callback, ...
                    'FontName', 'FixedWidth');

h.Start = uicontrol('Units', 'pixels', ...
                    'Style', 'pushbutton', ...
                    'String', 'Start Analysis', ...
                    'Position', [20 20 600 19], ...
                    'Callback', @biflguibutton_callback, ...
                    'FontName', 'FixedWidth');


%% Create a button box for pump graph
h.pumpRadio = uicontrol('Units', 'pixels', ...
                        'Style', 'radiobutton', ...
                        'Position', [20 top - 78 96 19], ...
                        'String', ' No trace', ...
                        'BackgroundColor', 'w', ...
                        'FontName', 'FixedWidth', ...
                        'Callback', @biflguiradio_callback, ...
                        'Value', 1);

% h.pumpRadio(2) = uicontrol('Units', 'pixels', ...
%                            'Style', 'radiobutton', ...
%                            'Position', [20 top - 108 112 19], ...
%                            'String', ' Flow speed', ...
%                            'BackgroundColor', 'w', ...
%                            'FontName', 'FixedWidth', ...
%                            'Callback', @biflguiradio_callback);
% 
% h.pumpRadio(3) = uicontrol('Units', 'pixels', ...
%                            'Style', 'radiobutton', ...
%                            'Position', [20 top - 168 136 19], ...
%                            'String', ' Pump pressure', ...
%                            'BackgroundColor', 'w', ...
%                            'FontName', 'FixedWidth', ...
%                            'Callback', @biflguiradio_callback);

h.pumpLab(1) = uicontrol('Units', 'pixels', ...
                         'Style', 'Text', ...
                         'Position', [190 top - 106 590 19], ...
                         'String', 'File:', ...
                         'BackgroundColor', 'w', ...
                         'HorizontalAlignment', 'left', ...
                         'FontName', 'FixedWidth');

% h.pumpLab(2) = uicontrol('Units', 'pixels', ...
%                          'Style', 'Text', ...
%                          'Position', [190 top - 198 590 19], ...
%                          'String', 'File:', ...
%                          'BackgroundColor', 'w', ...
%                          'HorizontalAlignment', 'left', ...
%                          'FontName', 'FixedWidth');

h.pumpBut(1) = uicontrol('Units', 'pixels', ...
                         'Style', 'pushbutton', ...
                         'Position', [20 top - 108 150 19], ...
                         'String', 'Select a CSV File', ...
                         'HorizontalAlignment', 'left', ...
                         'FontName', 'FixedWidth', ...
                         'Tag', 'Choose Flow Sensor File', ...
                         'Callback', @biflguibutton_callback);

% h.pumpBut(2) = uicontrol('Units', 'pixels', ...
%                          'Style', 'pushbutton', ...
%                          'Position', [20 top - 198 150 19], ...
%                          'String', 'Select CSV File', ...
%                          'HorizontalAlignment', 'left', ...
%                          'FontName', 'FixedWidth', ...
%                          'Tag', 'Choose Pump Pressure File', ...
%                          'Callback', @biflguibutton_callback);

% Initialize some button group properties. 
% set(h,'SelectionChangeFcn',@selcbk);
% set(h,'SelectedObject',[1 0 0]);  % No selection
% set(h,'Visible','on');


biflguicreatecheckbox;

param2editbox;

%% Make sure the visibility is all correct
biflguibutton_callback(h.Tab(1));

end
