function biflguicreatecheckbox
global h
global param

% Delete all existing checkboxes
if isfield(h, 'File')
    for i = 1 : numel(h.File)
        try %#ok<TRYNC>
            delete(h.File(i))
        end
    end
end
files = dir(param.folder);
files = struct2cell(files);

% find files with scp extention
scps = find(cellfun(@(x) strcmpi(x(max(1, numel(x) - 2) : end), 'spc'), files(1, :)));
% find files with set extention
sets = cellfun(@(x) any(strcmpi(files(1, :), [x(1 : end - 3) 'set'])), files(1, scps));

files = files(:, scps(sets));

h.File = zeros(1, size(files, 2));

% check if files are already listed exist
checked = repmat({1}, 1, size(files, 2));
if isfield(param, 'files')
    for j = 1 : size(files, 2)
        for i = 1 : size(param.files, 2)
            if isequal(param.files{1, i}, files{1, j})
                checked{j} = param.files{2, i};
            end
        end
    end
end

param.files = vertcat(files(1, :), checked);

for i = 1 : size(files, 2)
    h.File(i) = uicontrol('Units', 'pixels', ...
                         'Style', 'checkbox', ...
                         'String', param.files{1, i}, ...
                         'Position', [20, 670 - 20 * i, 600, 19], ...
                         'FontName', 'FixedWidth', ...
                         'BackgroundColor', 'w', ...
                         'Callback', @biflguicheckbox_callback, ...
                         'HorizontalAlignment', 'left', ...
                         'Value', param.files{2, i}, ...
                         'ToolTipString', sprintf('%s; %5.2f MB', ...
                            files{2, i}, files{3, i} * 1e-6));
end

end


function biflguicheckbox_callback(gcbo, ~)
global param
global h

param.files{2, h.File == gcbo} = get(gcbo, 'Value');
end