function lifetimes = importTRI2txt(path, fitTypes, chName)
% lifetimes = importTRI2txt(path, fitTypes, chname)
%   The function recursively searches for paths matching one of the
%   following names: "bayes", "phasor", "marquardt". It performs the
%   recursive search starting with the folder specified in PATH or the 
%   current folder if none specified. 
%   It then looks for files ending with "txt" extension and tries to import
%   their content into a "lifetimes" struct.
%
%   path        A path to start recursive search for directories with
%               lifetimes data.
%   fitTypes    A cells with names of the folders with different types of
%               fits. Default values are {'bayes', 'phasor', 'marquardt'}.
%   chName      A channel name wildcard. It distinguishes ICS file results
%               from the same dataset, but different detector. Default
%               value is ''.

if nargin == 0
    path = '.';
end

if nargin < 2
    fitTypes = {'bayes', 'phasor', 'marquardt'};
end

if nargin < 3
    chName = '';
end

% Get all recursive paths starting with the folder "path"
paths = textscan(genpath(path), '%s', 'delimiter', pathsep);
b = zeros(1, numel(fitTypes));
headers = {'Image:', 'Dimensions:', 'Info:'};
for i = 1 : numel(paths{1})
    type = paths{1}{i} ...
                 (((find(paths{1}{i} == filesep, 1, 'last') + 1) : end));
    if ~any(strcmp(fitTypes, type))
        continue
    end
    files = dir([paths{1}{i} filesep '*' chName '.txt']);
    if isempty(files)
        continue;
    end
    for j = 1 : numel(files)
        fid = fopen([paths{1}{i} filesep files(j).name]);
        tl = '';
        while (isempty(strfind(tl, 'TRI2 (')) && ~feof(fid))
            tl = fgetl(fid);
        end
        projname = tl(1 : (find(tl == pathsep, 1, 'first') - 1));
        if isempty(projname)
            fclose(fid);
            continue
        end
        u = 6;
        header = cell(1, 6);
        while (isempty(strfind(tl, 'x	y	')) && ~feof(fid))
            tl = fgetl(fid);
            for k = 1 : 3
                if strfind(tl, headers{k}) == 1
                    u = u + 1;
                    header{u} = tl(numel(headers{k}) + 2 : end);
                end
            end
        end
        params = textscan(tl, '%s', 'delimiter', '\t');
        params = regexprep(params{1}, '[ -]', '_');
        values = textscan(fid, '%f', 'delimiter', '\t');
        values = values{1};
        values = reshape(values, numel(params), numel(values) / numel(params));
        in = strcmp(fitTypes, type);
        b(in) = b(in) + 1;
        lifetimes.(type)(b(in)).name = projname;
        u = 0;
        for k = 1 : numel(params)
            lifetimes.(type)(b(in)).(params{k}) = values(k, :);
            for m = 1 : 3
                u = u + 1;
                lifetimes.(type)(b(in)).(headers{m}(1 : end - 1)){k} = header{u};
            end
        end
        fclose(fid);
    end
end