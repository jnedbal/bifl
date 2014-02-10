function param2editbox
global param
global h

set(h.Dir(2), 'String', param.folder);
pos1 = get(h.Dir(2), 'Extent');
pos2 = get(h.Dir(2), 'Position');
set(h.Dir(2), 'Position', [pos2([1 2]), pos1([3 4])]);

par = {'binsize', 'medif', 'thres', 'hvMin', 'phasorFreq', ...
       'analysisWindow'};
coef = [1e-6, 1, 1, 1, 2e+6 * pi, 1];
u = 0;
for i = 1 : numel(par)
    u = u + 1;
    if isfield(param, par{u})
        p = getfield(param, par{i});
        for j = 1 : numel(p)
            if j > 1
                u = u + 1;
            end
            set(h.ParamVal(u), 'String', num2str(p(j) / coef(i)));
        end
    end
end

if isfield(param, 'PDFs')
    set(h.PDFs, 'Value', param.PDFs)
end

%% Dynamically layout the controls on the page
arrangeFlow;

