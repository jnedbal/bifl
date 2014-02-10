function acceptGates(gcbo)
global figs
global param
global data
global fifo %#ok<NUSED>

% check if there are any selected gates
fname = fname4gates('selGates', figs.type.scatter);
% % create filename
% fname = param.fname;
% % each gate is inctroduced by its group name
% gates = {'gA', 'gB', 'gC', 'gD'};
% if isfield(figs, 'selGates')
%     for i = figs.type.scatter
%         % if scatter plots do not have any selected gates, skip them
%         if i > numel(figs.selGates)
%             break
%         end
%         % expand the filename with the names of the gates
%         for j = find(figs.selGates(i).checked)
%             fname = sprintf('%s__%s_%s', fname, ...
%                             gates{i - figs.type.scatter(1) + 1}, ...
%                             figs.selGates(i).gName{j});
%         end
%     end
% end

% give a dialog for choosing a filename
oldDir = pwd; cd(param.folder);
[fname, PathName] = uiputfile('*.ens.fig', 'Save files with gates', ...
                              [fname '.ens.fig']);
cd(oldDir);
                          
% stop if cancel button is pressed
if isequal(fname, 0)
    return
end

%% Check if any of the files already exists
% Get the extension
if max(strfind(fname, '.ens.fig')) == numel(fname) - 7
    ext = '.ens.fig';
else
    [~, ~, ext] = fileparts(fname);
    if isempty(ext)
        fname = [fname, '.ens.fig'];
        ext = '.ens.fig';
    end
end

% Get the filename without the extension
if numel(fname) == numel(ext)
    errordlg('You need a nonempty file name', 'Save files with gates')
    return
end

% New extensions
nExts = {'.ens.pdf', '.ens.fig', '.gates.mat', ''};
quest = repmat({fname}, 1, numel(nExts));
for i = 1 : numel(nExts)
    fn = regexprep(fname, ext, nExts{i});
    if exist([PathName fn], 'file')
        quest{i} = fn;
    else
        quest{i} = '';
    end
end
quest(cellfun(@isempty,  quest)) = [];
if ~isempty(quest)
    if numel(quest) == 1
        e = '';
    else
        e = 's';
    end
    quest = horzcat( ...
        {sprintf('Do you wish to overwrite the following file%s?', e)}, ...
        quest);
    A = questdlg(quest, 'Save files with gates', 'Yes', 'No', 'No');
    if isequal(A, 'No') || isequal(A, '')
        return
    end
end

% By this point we should be ready to create the files

%% First close all open figures with gates
for i = [figs.type.scatter, figs.type.decay, figs.type.phasor]
    if figs.hFig(i)
        closefig_callback(figs.hFig(i), [])
    end
end

%% Work out the gates
gateBursts;


%% If on Linux, redraw the images so they print to PDF
% if isequal(computer, 'GLNXA64') || isequal(computer, 'GLNX86')
%     param.os = true;
%     for i = 1 : 4
%         drawScatter(i, figs.hAxes(figs.type.scatter(i)))
%         axes(figs.hGaxes(figs.type.scatter(i))); %#ok<LAXES>
%     end
% 
%     set(figs.hTitle(2), 'Position', [0.4, 1])
% end
drawDecay(figs.hAxes(figs.type.decay));
drawPhasor(figs.hAxes(figs.type.phasor));
displayReport(figs.hAxes(figs.type.report));

%% Give the tag the name of the mat file
set(gcf, 'Tag', regexprep(fname, ext, nExts{3}))

%% Save results
% Remove the Accept Gates button from the screen for printing
set(gcbo, 'Visible', 'off')

fn = regexprep(fname, ext, nExts{1});
fprintf('Creating Ensemble Properties PDF file for %s\n', fn);

%export_fig(gcf, [PathName fn], '-pdf')
print(gcf, [PathName fn], '-dpdf')

% Return the Accept Gates button from the screen for printing
set(gcbo, 'Visible', 'on')

%% On linux the graphs look ugly, therefore I will fix them
% if param.os
%     param.os = false;
%     for i = 1 : 4
%         drawScatter(i, figs.hAxes(figs.type.scatter(i)))
%         axes(figs.hGaxes(figs.type.scatter(i))); %#ok<LAXES>
%     end
%     set(figs.hTitle(2), 'Position', [0.5, 1])
%     drawDecay(figs.hAxes(figs.type.decay));
%     displayReport(figs.hAxes(figs.type.report));
%     drawnow
% end

%% Save the figure
fn = regexprep(fname, ext, nExts{2});
fprintf('Saving Ensemble Properties figure %s\n', fn);
saveas(gcf, [PathName fn])



% ICS filename
fn = regexprep(fname, ext, nExts{4});

exportICS(data.utimeHist .* repmat(data.mask, [1, 1, 1, numel(fifo.rChan)]),  [PathName fn])

%% Save workspace
fn = regexprep(fname, ext, nExts{3});
fprintf('Saving gates a MAT file for %s\n', fn);
save([PathName fn], '-v7.3', 'figs', 'data', 'param', 'fifo');


