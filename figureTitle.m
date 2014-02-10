function tit = figureTitle(in)
global figs

% create a new figure
if iscell(figs.tits{1, in})
    if iscell(figs.tits{1, in}{1})
        if strcmp(get(figs.hAxes(in), 'yscale'), 'linear')
            tit = 1;
        else
            tit = 2;
        end
        tit = [figs.tits{1, in}{tit}{1}, ' ', figs.tits{1, in}{tit}{2}];
    else
        tit = [figs.tits{1, in}{1}, ' ', figs.tits{1, in}{2}];
    end
else
    tit = figs.tits{1, in};
end
tit = tit(find(tit ~= ' ', 1, 'first') : find(tit ~= ' ', 1, 'last'));