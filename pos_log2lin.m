function pos = pos_log2lin(pos, handle)

% program breaks if no gate is created
if isempty(pos)
    return
end

% Convert positions to linear scale
xl = get(handle, 'XLim');
yl = get(handle, 'YLim');
pos(:, [1 3]) = log2lin(pos(:, [1 3]), xl);
pos(:, [2 4]) = log2lin(pos(:, [2 4]), yl);
pos(:, 3) = pos(:, 3) - pos(:, 1);
pos(:, 4) = pos(:, 4) - pos(:, 2);

end


function out = log2lin(in, lims)
    out = (log10(in) - log10(lims(1))) / (log10(lims(2)) - log10(lims(1)));
end