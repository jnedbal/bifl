function arrangeFlow
global h
global param

% %% First we need to work out the radio button that is currently pressed
% % Index of the selected radio button
% rin = get(h.pumpRadio(h.pumpRadio ~= 0), 'Value');
% % Tag with link to file of the selected radio button
% rtg = get(h.pumpRadio(h.pumpRadio ~= 0), 'Tag');
% % Title of the selected radio button
% rst = get(h.pumpRadio(h.pumpRadio ~= 0), 'String');
% if iscell(rin)
%     rin = cellfun(@any, rin);
%     if any(rin)
%         rtg = rtg{rin};
%         rst = rst{rin};
%     else
%         rtg = '';
%         rst = '';
%     end
% end

if ~isfield(param, 'pumpTag')
    param.pumpTag = '';
end
if ~isfield(param, 'pumpString')
    param.pumpString = '';
end
if ~isfield(param, 'pumpTitle')
    param.pumpTitle = {};
end
if ~isfield(param, 'pumpFolder')
    param.pumpFolder = {};
end
if ~isfield(param, 'pumpFile')
    param.pumpFile = {};
end
if ~isfield(param, 'pumpColumn')
    param.pumpColumn = {};
end


%% Now we clear all the buttons, radiobuttons and labels
if isfield(h, 'pumpBut')
    delete(h.pumpBut(ishandle(h.pumpBut) & h.pumpBut > 0));
    h.pumpBut = [];
end
if isfield(h, 'pumpDelBut')
    delete(h.pumpDelBut(ishandle(h.pumpDelBut) & h.pumpDelBut > 0));
    h.pumpDelBut = [];
end
if isfield(h, 'pumpLab')
    delete(h.pumpLab(ishandle(h.pumpLab) & h.pumpLab > 0));
    h.pumpLab = [];
end
if isfield(h, 'pumpRadio')
    delete(h.pumpRadio(ishandle(h.pumpRadio) & h.pumpRadio > 0 & ...
                       [false, true(1, numel(h.pumpRadio) - 1)]));
    h.pumpRadio = h.pumpRadio(1);
end

%% Work out tops of the sections
top = 722;

%% Create the push buttons and labels
for i = 1 : min(numel(param.pumpFolder) + 1, 4)
    %% Create a push button to select a CSV File
    h.pumpBut(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'pushbutton', ...
                             'Position', [20, top - 30 * i, 150, 19], ...
                             'String', 'Select a CSV File', ...
                             'HorizontalAlignment', 'left', ...
                             'FontName', 'FixedWidth', ...
                             'Tag', 'Choose Flow Sensor File', ...
                             'Callback', @biflguibutton_callback);

    %% Create a label with the filename
    if i <= numel(param.pumpFile)
        txt = sprintf('File: %s', param.pumpFile{i});
    else
        txt = 'File:';
    end
    h.pumpLab(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'Text', ...
                             'Position', [190, top - 30 * i, 590, 19], ...
                             'String', txt, ...
                             'BackgroundColor', 'w', ...
                             'HorizontalAlignment', 'left', ...
                             'FontName', 'FixedWidth');
end

%% Create a push button to delete section
for i = 1 : numel(param.pumpFolder)
    h.pumpDelBut(i) = uicontrol('Units', 'pixels', ...
                             'Style', 'pushbutton', ...
                             'Position', [560, top - 30 * i, 60, 19], ...
                             'String', 'Delete', ...
                             'HorizontalAlignment', 'left', ...
                             'FontName', 'FixedWidth', ...
                             'Tag', 'Delete Pump Section', ...
                             'Callback', @biflguibutton_callback);
end

%% Create radio buttons
[titles, in] = unique(vertcat(param.pumpTitle{:}));
column = vertcat(param.pumpColumn{:});
column = column(in);
top = top - 30 * min(numel(param.pumpFolder) + 1, 4) - 10;
for i = 1 : numel(titles)
    h.pumpRadio(i + 1) = uicontrol('Units', 'pixels', ...
                                   'Style', 'radiobutton', ...
                                   'String', [' ' titles{i}], ...
                                   'BackgroundColor', 'w', ...
                                   'FontName', 'FixedWidth', ...
                                   'Callback', @biflguiradio_callback, ...
                                   'Tag', num2str(column(i)));
    % Align the radio button
    ext = get(h.pumpRadio(i + 1), 'Extent');
    ext = [20, top - 30 * i, ext(3) + 15, ext(4)];
    set(h.pumpRadio(i + 1), 'Position', ext)

    % Make sure the correct button is selected
    if isequal([' ' titles{i}], param.pumpString)
        set(h.pumpRadio(h.pumpRadio ~= 0), 'Value', 0)
        set(h.pumpRadio(i + 1), 'Value', 1)
        param.pumpString = get(h.pumpRadio(i + 1), 'String');
        param.pumpTag = get(h.pumpRadio(i + 1), 'Tag');
    end
end


%% Check that a radion button is selected or else select No Trace
rin = get(h.pumpRadio(h.pumpRadio ~= 0), 'Value');
if iscell(rin)
    if any(cellfun(@any, rin))
        return
    end
else
    if rin
        return
    end
end
set(h.pumpRadio(1), 'Value', 1)
param.pumpString = get(h.pumpRadio(1), 'String');
param.pumpTag = get(h.pumpRadio(1), 'Tag');