function readMitos
global fifo
global param
global data

data.flowTime = [];
data.flowValue = zeros(0, 5);
for i = 1 : numel(param.pumpFile)
    fname = horzcat(param.pumpFolder{i}, param.pumpFile{i});

    if exist(fname, 'file')
        fprintf('Importing flow data from %s\n', fname);
    else
        warning('Flow data file %s does not exist\nSkipping...\n', fname);
        param.flow = 0;
        return
    end

    % Open and load the file
    fid = fopen(fname);
        % First line contains the column titles
        titles = fgetl(fid);
        % The rest is a comma separated list of values
        b = textscan(fid, '%s', 'delimiter', ',');
    fclose(fid);
    % Convert the row into a cell matrix
    B = reshape(b{1}, 6, numel(b{1}) / 6);
    % Divide the titles
    titles(regexp(titles, ',[A-Z]')) = '@';
    titles = textscan(titles, '%s', 'Delimiter', '@');
    % Get date format string
    fstr = titles{1}{1};
    titles = titles{1}(2 : end - 1);

    % Format the date format string for Matlab
    fstr = fstr(strfind(fstr, ', ') + 2 : strfind(fstr, ']"') - 1);
    fstr = horzcat(lower(fstr(1 : strfind(fstr, ' '))), ...
                   upper(fstr(strfind(fstr, ' ') + 1 : end)));

    % Get the serial date of the flow measurements
    % data.flowTime = cellfun(@(x) datenum(x, 'dd/mm/yyyy HH:MM:SS'), B(1, :));
    data.flowTime = vertcat(data.flowTime, ...
                            cellfun(@(x) datenum(x, fstr), B(1, :))');

    % Get the flow parameters. NaNs appear where there is no data
    data.flowValue = vertcat(data.flowValue, ...
                             str2double(B(2 : end, :))');
end

% Convert the serial date to seconds
data.flowTime = data.flowTime * 86400;
% Get the start of the experiment in the serial date
expL = round(fifo.macroT(end) * fifo.MTC);     % length of experiment
data.flowTime = data.flowTime - 86400 * ...
    datenum([fifo.set.Date fifo.set.Time], 'yyyy-mm-ddHH:MM:SS') + expL;

%data.flowTime = data.flowTime -  17338;

% Select only those times that fit into the experimental time window
in = data.flowTime >= -1.5 & data.flowTime <= expL + 1.5;
in(max(find(in, 1, 'first') - 1, 1)) = true;
in(min(find(in, 1, 'last') + 1, numel(in))) = true;

data.flowTime = data.flowTime(in);
data.flowValue = data.flowValue(in, :);
[data.flowTime, in] = sort(data.flowTime);
data.flowValue = data.flowValue(in, :);

% if param.flow == 1
%     data.flowValue = cellfun(@str2double, B(5, in));
% elseif param.flow == 2
%     data.flowValue = cellfun(@str2double, B(2, in));
% end

if isempty(data.flowTime)
    if exist('fname', 'var')
        warning(['Flow data file %s does not contain information\n', ...
                 '  for the duration of this experiment\n', ...
                 'Skipping...\n'], fname);
    end
    param.flow = 0;
end