function par = analyzeLifetimes(par)
% par = analyzeLifetimes(par)
%   A script to process data from TRI2 analysis of flow cytometry bursts.
%   It creates 2D histograms of burst parameters vs. lifetimes. It
%   processes all lifetime data in .txt files in a batch.
%
%   Run this script in the directory, which contains the results.
%   It creates PDF, EPS and PNG files with the results.
%
%   Script can run without any parameters or parameters in the struct par.
%   It returns par with either the user supplied data or the default.
%
%   par.folder      A folder to be analyzed for directories containing MAT 
%                   files resulting from biflgui for for analysis. Default 
%                   value pwd, i.e. current folder.
%
%   par.wildcard    A file wildcard for files to analyze. These files must
%                   be results of biflgui analysis. Default value
%                   '*.gates.mat'.
%
%   par.replacements    replacement strings for filenames
%                       a cell with two columns. The left column contains 
%                       strings in filenames to be replaced by strings in
%                       the second column. Default value: cell(0, 2).
%                       Example value: {'gC_MOST.gates.mat', ''; ...
%                                       '03__', 'MCF7-EGFR:0:pY72'; ...
%                                       '04__', 'MCF7-EGFR:EGF:pY72'; ...
%                                       '05__', 'MCF7-EGFR:0:0'; ...
%                                       '06__', 'MCF7-EGFR:EGF:0'; ...
%                                       '07__', 'MCF7-GFP:0:0'; ...
%                                       '08__', 'MCF7-GFP:EGF:pY72'; ...
%                                       '09__', 'HEK293-EGFR:0:0'; ...
%                                       '10__', 'HEK293-EGFR:EGF:pY72'};
%
%   par.texout      Struct with parameters of the tex output.
%       par.texout.name     tex filename. Default 'lifetimeOverview'.
%       par.texout.author   Document author. Default 'Jakub Nedbal'.
%       par.texout.title    Document title. Default 'Lifetime summary'.
%       par.texout.imscale  Scaling factor for images. Default value 1.2.
%
%   par.fs          Files size used in graphs. Default value 24.
%
%   par.pos         Positions and sizes of axes used for drawing the plots.
%                   Default value: [150, 150, 330, 330; ...
%                                   150, 480, 330, 50; ...
%                                   480, 150, 50, 330; ...
%                                   150, 150, 380, 380];
%
%   par.ttick       Ticks of lifetime axis. Default value [1.5, 2, 2.5, 3].
%
%   par.nbins       Number of bins in 1D histograms. Default value 31.
%.
%   par.plotTypes   Types of plots to produce and their properties.
%                   a four row cell with following information in the rows:
%                       1. type of data (burstDuration, burstFrequency, 
%                          burstPhotons or burst90percentile)
%                       2. multiplication coefficient (1e3, 1e-6, 1e-3 or
%                          1e-6)
%                       3. y axis ticks
%                       4. y axis label
%                   Default values: 
%                   {'burstDuration', 'burstFrequency', 'burstPhotons'; ...
%                    1e3, 1e-6, 1e-3; ...
%                    2 : 10, [0.5:0.1:1, 2, 3], [0.6:0.1:0.9, 1:10]; ...
%                    'Burst Duration [ms]', 'Mean Count Rate [MHz]', ...
%                     'Burst Photons [kCounts]'};
%
%   par.fitTypes    Types of lifetime fits. The txt files with lifetimes 
%                   created by Tri2 should be in folders with the same
%                   names. Default values {'phasor', 'bayes', 'marquardt'}.
%
%   par.correctRot  When true, this switch rotates the cloud of points
%                   around its center to line it up with the axes
%
%   par.scatter     Cell of scatter parameters
%
% 8.10.2013 ver. 1, rev. 1: Original file
% 2.12.2013 ver. 1, rev. 2: Added functionality to align clouds of points
%
% copyright Jakub Nedbal 2013
% license: GNU-GPL v3

% par is a struct with all the necessary parameters of the analysis
% if par does not exist, create it
if ~exist('par', 'var')
    par.folder = pwd;
end

% folder of directories containing MAT files for analysis
if ~isfield(par, 'folder')
    par.folder = pwd;
end

% folder to trawl for data
if ~isfield(par, 'wildcard')
    par.wildcard = '*.gates.mat';
end

% replacement strings for filenames
% a cell with two columns. The left column contains character arrays of
% strings to replace with strings in character arrays in the second column
if ~isfield(par, 'replacements')
    par.replacements = cell(0, 2);
%     replacements = {'gC_MOST.gates.mat', ''; ...
%                     '03__', 'MCF7-EGFR:0:pY72'; ...
%                     '04__', 'MCF7-EGFR:EGF:pY72'; ...
%                     '05__', 'MCF7-EGFR:0:0'; ...
%                     '06__', 'MCF7-EGFR:EGF:0'; ...
%                     '07__', 'MCF7-GFP:0:0'; ...
%                     '08__', 'MCF7-GFP:EGF:pY72'; ...
%                     '09__', 'HEK293-EGFR:0:0'; ...
%                     '10__', 'HEK293-EGFR:EGF:pY72'};
end

% name of an ouput tex file
if ~isfield(par, 'texout')
    par.texout.name = 'lifetimeOverview';
    par.texout.author = 'Jakub Nedbal';
    par.texout.title = 'Lifetime Summary';
    par.texout.imscale = 1.2;
else
    if ~isfield(par.texout, 'name')
        par.texout.name = 'lifetimeOverview';
    end
    if ~isfield(par.texout, 'author')
        par.texout.author = 'Jakub Nedbal';
    end
    if ~isfield(par.texout, 'title')
        par.texout.title = 'Lifetime Summary';
    end
    if ~isfield(par.texout, 'imscale')
        par.texout.imscale = 1.2;
    end
end

% font size used in the graphics
if ~isfield(par, 'fs')
    par.fs = 24;
end

% position and size of axis used for drawing the plots
if ~isfield(par, 'pos')
    par.pos = [150, 150, 330, 330; ...
               150, 480, 330, 50; ...
               480, 150, 50, 330; ...
               150, 150, 380, 380];
end

% lifetime axis ticks
if ~isfield(par, 'ttick')
    par.ttick = 1.5 : 0.5 : 3;
end
tlim = par.ttick([1 end]);

% number of bins per histogram
if ~isfield(par, 'nbins')
    par.nbins = 31;
end

% types of plots to produce and their properties.
% a four row cell with following information in the rows:
%   1. type of data (burstDuration, burstFrequency or burstPhotons)
%   2. multiplication coefficient (1e3, 1e-6 or 1e-3)
%   3. y axis ticks
%   4. y axis label
if ~isfield(par, 'plotTypes')
    par.plotTypes = {'burstDuration', 'burstFrequency', 'burstPhotons'; ...
                     1e3, 1e-6, 1e-3; ...
                     2 : 10, [0.5:0.1:1, 2, 3], [0.6:0.1:0.9, 1:10]; ...
                     'Burst Duration [ms]', 'Mean Count Rate [MHz]', ...
                     'Burst Photons [kCounts]'};
end

% types of lifetime fits
% the files with lifetimes should be in folders with the same names
if ~isfield(par, 'fitTypes')
    par.fitTypes = {'phasor', 'bayes', 'marquardt'};
end

% fit type titles
if ~isfield(par, 'fitTitles')
    par.fitTitles = {'Phasor', 'Bayesian', 'Marquardt-Levenberg'};
end

% channel name wildcard
if ~isfield(par, 'chName')
    par.chName = '';
end

% channel name wildcard
if ~isfield(par, 'rChan')
    par.rChan = [];
end

% rotate the cloud to align it with the axes
if ~isfield(par, 'correctRot')
    par.correctRot = false(1, size(par.plotTypes, 2));
end

% create empty scattter parameters if none exist
if ~isfield(par, 'scatter')
    par.scatter = {};
end


% lifetime ticks and limits
x = linspace(tlim(1), tlim(2), par.nbins);

% fit type titles


close all
figure('Color', 'w', 'Position', [70 70, 600, 600]);
ha = zeros(3, 1);
for m = 1 : 3
    ha(m) = axes; %#ok<LAXES>
    set(ha(m), 'Units', 'pixels', 'Position', par.pos(m, :), ...
        'FontSize', par.fs, 'Color', 'none', 'Box', 'on', ...
        'ActivePositionProperty', 'Position')
end


cIn = zeros(1, numel(par.fitTypes));
tauhist = cell(1, numel(par.fitTypes));
taunames = tauhist;
taufnames = tauhist;
files = dir([par.folder filesep par.wildcard]);
% load the lifetime values
lifetimes = importTRI2txt(par.folder, par.fitTypes, par.chName);
% distinguish between old (single channel) ICS files and current
% (multi-channel) ICS files New ones need for last characters truncated
% from the name of the ICS file

for jj = 1 : numel(files)
    % load the experimental data
    load([par.folder filesep files(jj).name], 'data', 'param', 'fifo', ...
         'figs')
    for k = 1 : numel(par.fitTypes)
        if ~isfield(lifetimes, par.fitTypes{k})
            continue
        end

        in = find(strcmp(cellfun(@(x) regexprep(x, '_Ch[0-3]', ''), ...
                                 {lifetimes.(par.fitTypes{k}).name}, ...
                                 'UniformOutput', false), ...
                         files(jj).name(1 : end - 10)));
        if numel(in) ~= 1
            fprintf('Cannot load lifetimes for %s in folder %s\n', ...
                files(jj).name(1 : end - 10), par.folder);
            continue
        end
        % calculate the indices of the fitted transients
        ii = lifetimes.(par.fitTypes{k})(in).x * data.square + 1 + ...
             lifetimes.(par.fitTypes{k})(in).y;
        % the number of transients in the fit might be higher than the
        % number of bursts due to the fact that transients are organized
        % in a square grid. The last transients are just zeros. Remove
        % those from the gate
        ii = ii(1 : numel(data.gate));
        % create a gate of fits without a failure
        tri2.gate = lifetimes.(par.fitTypes{k})(in).Intensity(ii) > 0;
        % check if all fitted points are those that havebeen gated
        if ~isequal(tri2.gate, data.gate)
             warning(['In file %s, the gates from Tri2 do not ', ...
                      'match the local gates!\n'], fnT);
        end
        % Make an intersection of the original gate and gate of
        % successfully fitted transients
        tri2.gate = tri2.gate & data.gate;
        % all the lifetime values
        tri2.tau = lifetimes.(par.fitTypes{k})(in).Tau(ii);
        % Create all types of plots listed in par.plotTypes
        for m = 1 : size(par.plotTypes, 2)
            % check if the desired plot is a phasor plot
            if strcmpi(par.plotTypes{1, m}, 'phasor')
                % phasor coordinates
                if (isfield(lifetimes.(par.fitTypes{k}), 'u') && ...
                        isfield(lifetimes.(par.fitTypes{k}), 'v'))
                    tri2.u = lifetimes.(par.fitTypes{k})(in).u(ii);
                    tri2.v = lifetimes.(par.fitTypes{k})(in).v(ii);
                else
                    % if this dataset does not contain phasor data, ignore
                    continue
                end
                delete(get(ha(1), 'Children'));
                delete(get(ha(2), 'Children'));
                delete(get(ha(3), 'Children'));
                delete(cell2mat(get(ha, 'Title')))
                delete(cell2mat(get(ha, 'YLabel')))
                delete(cell2mat(get(ha, 'XLabel')))
                axes(ha(1)); %#ok<LAXES>
                set(ha(1), 'YScale', 'linear')
                hold on;
                plot([-0.1 1.1], [0 0], 'k-')
                plot([0 0], [-0.1 0.6], 'k-')
                plot(0.5 * sin(pi * (-0.5 : 0.01 : 0.5)) + 0.5, ...
                     0.5 * cos(pi * (-0.5 : 0.01 : 0.5)), 'k-')
                dscatter(tri2.u(tri2.gate)', tri2.v(tri2.gate)');
                set(ha(1), 'Position', par.pos(1, :) .* ...
                    [1 1 1 0] + [0 0 0 par.pos(1, 3) * 7 / 12], ...
                    'XLim', [-0.1 1.1], 'YLim', [-0.1 0.6], ...
                    'XTick', [], 'YTick', [], 'Box', 'on')
                set(ha([2 3]), 'Visible', 'off');
                % Increment the counting index for each type of lifetime 
                % determination method
                cIn(k) = cIn(k) + 1;
                % save the name for each histogram into a cell
                taunames{k}{cIn(k)} = files(jj).name;
                % rename the name of each histogram according to rules
                % given in par.replacements
                for n = 1 : size(par.replacements, 1)
                    taunames{k}{cIn(k)} = ...
                        regexprep(taunames{k}{cIn(k)}, ...
                                  par.replacements{n, 1}, ...
                                  par.replacements{n, 2});
                end
                % Give it a title
                ht = title(par.fitTitles{k});

                % Save the output
                % Create the file name
                fn = [par.folder filesep files(jj).name];
                % replace the ending of the source file with an ending
                % representing the fitting method and the type of plot
                fn = regexprep(fn, '.gates.mat', ...
                    ['_' par.plotTypes{1, m} '_' par.fitTypes{k}]);
                % Save the filename for later
                taufnames{k}{cIn(k)} = fn;
                % Set paper parameters
                set(gcf, 'PaperPosition', [-2 -2 15.2 16.6], ...
                    'PaperSize', [13.2 14.6])
                % Export figures
                print(gcf, [fn '.eps'], '-depsc2')
                print(gcf, [fn '.pdf'], '-dpdf')
                print(gcf, [fn '.png'], '-dpng', '-r150')
                set(ha([2 3]), 'Visible', 'on');
                set(ha(1), 'Position', par.pos(1, :));
                delete(ht);
                hold off
                continue
            end
            % X-axis shows the lifetimes
            X = tri2.tau(tri2.gate);
            % Y-axis shows the burst parameters
            Y = par.plotTypes{2, m} * ...
                data.(par.plotTypes{1, m})(tri2.gate);
            % make sure nano of the points are NaN
            dIn = isnan(X) | isnan(Y);
            X(dIn) = [];
            Y(dIn) = [];
            % recall axis ha(1)
            axes(ha(1)); %#ok<LAXES>
            % clear its content
            cla;
            %[wcoeff,score,latent,tsquared,explained] = pca([X', Y']  ,'VariableWeights','variance')
            if par.correctRot(m)
                % convert Y coordinates to logarithmic
                Y = log10(Y);
                % Move point cloud to [0 0]
                xCen = mean(X);
                yCen = mean(Y);
                X = X - xCen;
                Y = Y - yCen;
                % Get angle of rotation
                pA = polyfit(X, Y, 1);
                pA = atan(pA(1));
                % Rotate the cloud
                X = X * cos(pA) - Y * sin(pA);
                Y = X * sin(pA) + Y * cos(pA);
                % Move cloud back to where it belongs
                X = X + xCen;
                Y = Y + yCen;
                % Return Y back to linear scale
                Y = 10 .^ Y;
            end
            % create a 2D histogram
            dscatter(X', Y', 'logy', true, par.scatter{:})
            hold on
            % If surf plot is shown, organize it to look nice
            if any(cellfun(@(x) isequal(x, 'surf'), par.scatter))
                view(2);
                hp = findobj(gca, 'type', 'surface');
                set(hp, 'EdgeColor', 'none')
                zz = get(hp, 'ZData');
                zz(zz < max(zz(:)) / 100) = NaN;
                set(hp, 'ZData', zz);
                at = plot(X', Y', 'b.');
                set(at, 'Visible', 'off')
            end
            if any(cellfun(@(x) isequal(x, 'contour'), par.scatter))
                at = plot(X', Y', 'b.');
                set(at, 'Visible', 'off')
            end
            % set the axis properties
            set(gca, 'XLim', tlim, 'XTick', par.ttick, ...
                'YLim', par.plotTypes{3, m}([1 end]), 'YTick', [], ...
                'FontSize', par.fs);
            % get coordinates of the y-axis ticks on the logarithmic
            % axis
            [ytick, Ytick] = logscale(par.plotTypes{3, m}([1 end]));
            % get rid of the yticks outiside the limits
            ytick(ytick < par.plotTypes{3, m}(1)) = [];
            % plot the tick and the value if in Ytick or at the limits
            for n = 1 : numel(ytick)
                % plot line
                plot(tlim(1) + [0, diff(tlim) / 50], ...
                     ytick(n) * [1 1], 'k-')
                % print the tick value
                if n == 1 || n == numel(ytick) || any(ytick(n) == Ytick)
                    text(tlim(1) - diff(tlim) / 50, ytick(n), ...
                         num2str(ytick(n)), 'VerticalAlignment', ...
                         'middle', 'HorizontalAlignment', 'right', ...
                         'FontSize', par.fs);
                end
            end
            % Label the axes
            ylabel({par.plotTypes{4, m}, ''}, 'FontSize', par.fs)
            xlabel('Lifetime [ns]', 'FontSize', par.fs)

            % create a 1-D histogram of lifetimes above the X-axis
            axes(ha(2)); %#ok<LAXES>
            cla
            % calculate the histogram
            hx = histc(X, x);
            % plot the histogram
            plot(x, hx, 'LineWidth', 2)
            % set axis properties
            set(gca, 'YTick', [], 'XTick', [], 'XLim', tlim, ...
                'YLim', [0, 1.2 * max(hx)])
            % Give it a title
            title(par.fitTitles{k});
            % Increment the counting index for each type of lifetime 
            % determination method
            cIn(k) = cIn(k) + 1;
            % save the lifetime histogram into a cell
            tauhist{k}(cIn(k), 1 : numel(x)) = hx;
            % save the name for each histogram into a cell
            taunames{k}{cIn(k)} = files(jj).name;
            % rename the name of each histogram according to rules
            % given in par.replacements
            for n = 1 : size(par.replacements, 1)
                taunames{k}{cIn(k)} = ...
                    regexprep(taunames{k}{cIn(k)}, ...
                              par.replacements{n, 1}, ...
                              par.replacements{n, 2});
            end

            % create a 1-D histogram of burst properties along the
            % Y-axis
            axes(ha(3)); %#ok<LAXES>
            cla
            % create logarithmically spaced histogram bins
            y = logspace(log10(par.plotTypes{3, m}(1)), ...
                         log10(par.plotTypes{3, m}(end)), par.nbins);
            % create a histogram of burst properties
            hy = histc(Y, y);
            % plot the histogram
            plot(hy, y, 'LineWidth', 2)
            % set the axis properties
            set(gca, 'YScale', 'log', 'YTick', [], 'XTick', [], ...
                'YLim', par.plotTypes{3, m}([1 end]), ...
                'XLim', [0, 1.2 * max(hy)])

            % Save the output
            % Create the file name
            fn = [par.folder filesep files(jj).name];
            % replace the ending of the source file with an ending
            % representing the fitting method and the type of plot
            fn = regexprep(fn, '.gates.mat', ...
                ['_' par.plotTypes{1, m} '_' par.fitTypes{k} 'Tau']);
            % Save the filename for later
            taufnames{k}{cIn(k)} = fn;
            % Set paper parameters
            set(gcf, 'PaperPosition', [-2 -2 15.2 16.6], ...
                'PaperSize', [13.2 14.6])
            % Export figures
            print(gcf, [fn '.eps'], '-depsc2')
            print(gcf, [fn '.pdf'], '-dpdf')
            print(gcf, [fn '.png'], '-dpng', '-r150')
            saveas(gcf, [fn '.fig'])
            fprintf('%s (%s): mean: %g,\tstd: %g,\tsem: %g\t95conf: %g\n',  taunames{k}{end}, par.fitTypes{k}, mean(X), std(X), std(X) / sqrt(numel(X)), t_confidence_interval(X));
        end
    end
end
% check if anything has been done, otherwise quit
if ~exist('in', 'var')
    return
end



% Create an overview figure with all lifetime histograms
close all
% Create a new figure
figure('Color', 'w', 'Position', [70 70, 600, 600]);
% Create the axis
axes;
% Create a tex output with the results
fid = fopen([par.folder filesep par.texout.name '.tex'], 'w');
fprintf(fid, '\\documentclass[11pt]{article}\n');
fprintf(fid, '\\title{\\textbf{%s}}\n', par.texout.title);
fprintf(fid, '\\author{%s}\n', par.texout.author);
fprintf(fid, '\\date{%s}\n', date);
fprintf(fid, '\\usepackage{graphicx,rotating}\n');
fprintf(fid, '\\usepackage[margin=2cm]{geometry}');
fprintf(fid, '\\begin{document}\n');
fprintf(fid, '\\maketitle\n');

% Vector with indices of lifetime analysis methods
tauMet = find(~cellfun(@isempty, tauhist));
% Number of plotTypes minus phasor
nrCols = size(par.plotTypes, 2) - ...
    sum(strcmpi(par.plotTypes(1, :), 'phasor'));
for jj = tauMet
    
    nrColThis = nrCols + double(...
        any(strcmpi(fieldnames(lifetimes.(par.fitTypes{jj})), 'u')) && ...
        any(strcmpi(fieldnames(lifetimes.(par.fitTypes{jj})), 'v')));
    % clear the axes
    cla;
    % set the axis properties
    set(gca, 'Units', 'pixels', 'Position', par.pos(4, :), ...
        'FontSize', par.fs, 'Color', 'none', 'Box', 'on', ...
        'ActivePositionProperty', 'Position')
    % create a filename with the summary based on the fit type
    fn = [par.folder filesep par.fitTypes{jj} '_summary'];
    % Extract the histogram of lifetimes
    taus = tauhist{jj}';
    % Make sure to remove empty data for the phasors
    if nrColThis ~= nrCols
        in = find(repmat(strcmpi(par.plotTypes(1, :), 'phasor'), 1, ...
            size(taus, 2) / nrColThis));
    else
        in = [];
    end
    taus(:, in) = [];
    taus = taus(:, 2 : nrCols : end);
    % normalize the histogram of lifetimes
    taus = taus ./ repmat(sum(taus), size(taus, 1), 1);
    % plot the histogram of lifetimes
    plot(x, taus, 'LineWidth', 2)
    % set axis properties
    set(gca, 'YTick', [], 'YLim', [0, 1.2 * max(taus(:))], ...
        'XTick', par.ttick, 'XGrid', 'on', 'XLim', tlim);
    % Extract the names of graphs for a legend
    leg = taunames{jj};
    leg(in) = [];
    leg = leg(2 : nrCols : end);
    % Create a legend based on the replaced strings in source filenames
    legend(leg, 'FontSize', par.fs / 4)
    % Create small tick-marks
    hold on
    for i = x;
        plot([i, i], [0 max(taus(:)) / 50], 'k-')
    end
    % Label the axes and the title
    xlabel('Lifetime [ns]');
    ylabel('Normalized frequency [RU]');
    title(par.fitTitles{jj})
    % Set paper properties
    set(gcf, 'PaperPosition', [-2 -2 15.2 16.6], 'PaperSize', [13.2 14.6])
    % Export the figure
    print(gcf, [fn '.eps'], '-depsc2')
    print(gcf, [fn '.pdf'], '-dpdf')
    print(gcf, [fn '.png'], '-dpng', '-r150')
    saveas(gcf, [fn '.fig'])

    if isfield(par, 'finalFunc')
        finalFunc;
    end

    fprintf(fid, '\\section{%s Lifetime Analysis}\n', par.fitTitles{jj});

    for k = 1 : numel(taunames{jj}) / nrColThis
        fprintf(fid, '\\begin{tabular}{@{}%s@{}}\n', ...
                repmat('c', 1, 1 + nrColThis));
        lab = regexprep(taunames{jj}{1 + (k - 1) * nrColThis}, '\_', '\\_');
        [~, lab] = fileparts(lab);
        [~, lab] = fileparts(lab);
        fprintf(fid, '\\begin{sideways}%s\\end{sideways}', lab);
        for m = 1 : nrColThis
            fprintf(fid, ' & \\includegraphics[scale=%g]{%s%s%s.pdf}', ...
                    par.texout.imscale / nrColThis, pwd, filesep, ...
                    taufnames{jj}{(k - 1) * nrColThis + m});
        end
        fprintf(fid, ' \\\\\n\\end{tabular}\n\\newline\n');
    end
end
fprintf(fid, '\\section{Overlaid Histograms}\n');
if isfield(par, 'finalFunc')
    fprintf(fid, '\\begin{tabular}{@{}%s@{}}\n', ...
        repmat('c', 1, numel(combfnames))); %#ok<USENS>
    for m = 1 : numel(combfnames)
        if m > 1
            fprintf(fid, ' & ');
        end
        fprintf(fid, '\\includegraphics[scale=%g]{%s%s%s}', ...
                par.texout.imscale / nrColThis, pwd, filesep, ...
                combfnames{m});
    end
    fprintf(fid, ' \\\\\n\\end{tabular}\n\\newline\n');
end
fprintf(fid, '\\section{Summarizing Lifetime Histograms}\n');
fprintf(fid, '\\begin{tabular}{@{}%s@{}}\n', ...
        repmat('c', 1, numel(tauMet)));
for jj = tauMet
    fn = [par.folder filesep par.fitTypes{jj} '_summary'];
    fprintf(fid, '\\includegraphics[scale=%g]{%s%s%s.pdf}', ...
            par.texout.imscale / numel(tauMet), pwd, filesep, fn);
    if jj < numel(tauMet)
        fprintf(fid, ' & ');
    end
end
fprintf(fid, ' \\\\\n\\end{tabular}\n');

fprintf(fid, '\\end{document}\n');
% Close the tex file
fclose(fid);

try
    system(sprintf('pdflatex -output-directory %s %s%s%s.tex', ...
                   par.folder, par.folder, filesep, par.texout.name));
catch
    warning('Could not produce output PDF file using pdflatex');
end

