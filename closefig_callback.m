function closefig_callback(gcbo, ~)
global figs

figs.hFig(figs.hFig == gcbo) = 0;
delete(gcbo);

