function [starts, ends, oodT, burstphotons] = burstSeg_dT(mfk, gfk, thres, hvMin)
global fifo

% calculate one-over-dT (oodT) between neighboring events
oodT = dip_image(1 ./ (fifo.macroT(2 : end) - fifo.macroT(1 : end - 1)));

if mfk
    % plot 1/dT after median filtering
    oodT = double(medif(oodT, mfk));
end

if gfk
    % plot 1/dT after median filtering
    oodT = double(gaussf(oodT, gfk));
end


%% Threshold and segment into bursts
in = int8([false, logical(oodT > thres), false]);
in = in(1 : end - 1) - in(2 : end);
starts = find(in == -1);        % Starts of bursts
ends = find(in == 1) - 1;       % Ends of bursts

fprintf('%g bursts identified (%g starts, %g ends)\n', ...
    mean([numel(starts), numel(ends)]), numel(starts), numel(ends));

%% Calculate the number of photons in a burst
burstphotons = ends - starts + 1;

%% Check that bursts are containing at least hvMin photons
in = burstphotons < hvMin;
starts(in) = [];
ends(in) = [];
burstphotons(in) = [];

fprintf('%g bursts with at least %g photons\n', numel(starts), hvMin);