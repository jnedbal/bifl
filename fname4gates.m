function fname = fname4gates(fromGates, plots)

global param
global figs

% create filename
fname = param.fname;
% each gate is inctroduced by its group name
gateNames = {'gA', 'gB', 'gC', 'gD'};
if isfield(figs, fromGates)
    for i = plots
        % if scatter plots do not have any selected gates, skip them
        if i > numel(getfield(figs, fromGates))
            break
        end
        % expand the filename with the names of the gates
        for j = find(getfield(figs, fromGates, {i}, 'checked'))
            fname = sprintf('%s__%s_%s', fname, ...
                gateNames{i - figs.type.scatter(1) + 1}, ...
                cell2mat(getfield(figs, fromGates, {i}, 'gName', {j})));
        end
    end
end