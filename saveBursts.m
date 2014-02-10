function saveBursts
global param
global figs

%% Save results
fprintf('Creating Burst Segmentation PDF file %s.seg.pdf\n', param.fname);
set(gcf, 'PaperPositionMode', 'auto')
print(gcf, [param.fname '.seg.pdf'], '-dpdf')
% fprintf('Saving variables to a MAT file for %s\n', fname);
% save([fname 'mat'], 'param', 'data', 'figs');

%% On linux the graphs look ugly, therefore I will fix them
% if param.os
%     for i = 1 : 5
%         axes(figs.hAxes(i)); %#ok<LAXES>
%         tit = figs.tits{1, i};
%         xlab = figs.xlabs{1, i};
%         ylab = figs.ylabs{1, i};
%         title(tit, 'FontName', 'FixedWidth');
%         xlabel(xlab, 'FontName', 'FixedWidth');
%         ylabel(ylab, 'FontName', 'FixedWidth');
%     end
%     if param.flow
%         for i = 1 : 4
%             axes(figs.hGaxes(i)); %#ok<LAXES>
%             y2lab = figs.y2labs{1, i};
%             ylabel(y2lab, 'FontName', 'FixedWidth');
%         end
%     end
%     set(figs.hTitle, 'Position', [0.5, 0])
% end
% param.os = false;


%% Save the figure
set(figs.hMainFig(1), 'Pointer', 'arrow')
fprintf('Saving Burst Segmentation figure %s.seg.fig\n', param.fname);
saveas(figs.hMainFig(1), [param.fname '.seg.fig'])
set(figs.hMainFig(1), 'Pointer', 'watch')
