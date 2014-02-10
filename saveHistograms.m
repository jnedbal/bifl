function saveHistograms
global param
global figs
global data %#ok<NUSED>
global fifo %#ok<NUSED>


%% Save results
fprintf('Creating Ensemble Properties PDF file for %s.ens.pdf\n', ...
    param.fname);

set(gcf, 'PaperPositionMode', 'auto')
print(gcf, [param.fname '.ens.pdf'], '-dpdf')
%export_fig(gcf, [param.fname '.ens.pdf'], '-pdf')

%% On linux the graphs look ugly, therefore I will fix them
% if param.os
%     param.os = false;
%     for i = 1 : 4
%         drawScatter(i, figs.hAxes(figs.type.scatter(i)))
%     end
%     set(figs.hTitle(2), 'Position', [0.5, 1])
%     drawDecay(figs.hAxes(figs.type.decay));
%     displayReport(figs.hAxes(figs.type.report));
%     drawnow
% end

%% Add buttons
figs.hButton = ...
    uicontrol('Units', 'pixels', ...
              'Style', 'pushbutton', ...
              'String', 'Accept Gates', ...
              'Position', [40, 20, 120, 20], ...
              'Callback', @buttonpress_callback, ...
              'FontName', 'FixedWidth', ...
              'Tag', 'Accept Gates');

%% Save the figure
set(figs.hMainFig(2), 'Pointer', 'arrow')
fprintf('Saving Ensemble Properties figure %s.ens.fig\n', param.fname);
saveas(gcf, [param.fname '.ens.fig'])
set(figs.hMainFig(2), 'Pointer', 'watch')

%% Save workspace
fprintf('Saving workspace to a MAT file for %s.mat\n', param.fname);
save([param.fname '.mat'], '-v7.3', 'param', 'data', 'figs', 'fifo');

%% Return the mouse pointer  to normal
set(figs.hMainFig, 'Pointer', 'arrow')
