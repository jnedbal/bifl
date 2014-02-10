function burstSeg_histc
%BURSTSEG_HIST Photon burst segmentation routine based of histogramming and
%              subsequent median filtering
%
%   Usage:
%   [STARTS, ENDS, BIN] = BURSTSEG_HIST(BINSIZE, MFK, THRES)
%           BINSIZE: Defines the size of the bin in seconds. Smaller bins
%           lead to higher memory consumption, but allow finer sampling and
%           improved signal-to-noise ratio. Suggested value of 1e-5.
%           MFK: Median filter kernel The histogram is smoothed out with an
%           edge-preserving median filter before thresholding. Suggested
%           value of 100.
%           THRES: Threshold for burst segmentation. Suggested value of 3.
%
%           STARTS: Starts of bursts in seconds.
%           ENDS: Ends of bursts in seconds.
%           BIN: Filtered histogram.

global fifo
global param
global data
global figs

%% Each figure is assigned an index to be identified
figs.type.bursts = 1 : 4;
figs.type.avgBurst = 5;

% Create the histogram bins in seconds

% ***** Commented out 15.5.2013 for memory issues *****
% X = binsize / 2 : binsize : fifo.macroT(end) * fifo.MTC - binsize / 2;
% ***** Commented out 15.5.2013 for memory issues *****

% Calculate the histogram of photon arrivals
% ***** Commented out 15.5.2013 for memory issues *****
% binR = hist(fifo.macroT * fifo.MTC, X);
% ***** Commented out 15.5.2013 for memory issues *****

data.X = 0 : param.binsize : ceil(fifo.macroT(end) * fifo.MTC / param.binsize) * param.binsize;

binR = histc(fifo.macroT * fifo.MTC, data.X);
% Apply median filter with kernel mfk to the histogram
% if mfk
    %data.bHist = int32(medif(dip_image(binR), param.medif));
    data.bHist = int32(fastmedfilt1d(binR, param.medif))';
% else
%     bHist = int32(binR);
% end
binR = int32(binR);

%% Threshold and segment into bursts
in = [0, int8(data.bHist > param.thres), 0];
in = in(1 : end - 1) - in(2 : end);
data.burstStarts = find(in == -1);        % Starts of bursts
data.burstEnds = find(in == 1) - 1;       % Ends of bursts

fprintf('%g bursts identified (%g starts, %g ends)\n', ...
    mean([numel(data.burstStarts), numel(data.burstEnds)]), numel(data.burstStarts), numel(data.burstEnds));


%% Calculate number of photons in bursts
%  smallest odd number equal to or larger than median burst length 
data.burstPhotons = 1 : numel(data.burstStarts);
for i = data.burstPhotons
    data.burstPhotons(i) = sum(binR(data.burstStarts(i) : data.burstEnds(i)));
end

%% Check that bursts are containing at least hvMin photons
in = data.burstPhotons < param.hvMin;
data.burstStarts(in) = [];
data.burstEnds(in) = [];
data.burstPhotons(in) = [];

fprintf('%g bursts with at least %g photons\n', numel(data.burstStarts), param.hvMin);
if isempty(data.burstStarts)
    data.bursts = [];
    data.burstShapes = [];
    return
end

%% Calculate mean burst shape
%  smallest odd number equal to or larger than median burst length 
mbl = floor(median(data.burstEnds - data.burstStarts) / 2) * 2 + 1;
data.burstShapes = zeros(numel(data.burstStarts), mbl);
%  half value of mbl
mbl = floor(mbl / 2);
burstlimits = round(...
    [min([mean([data.burstStarts; data.burstEnds]) - median(data.burstEnds - data.burstStarts) / 2 - 5; data.burstStarts]); ...
     max([mean([data.burstStarts; data.burstEnds]) + median(data.burstEnds - data.burstStarts) / 2 + 5; data.burstEnds])]);
% Make sure burstlimits are within the range of the histogram
burstlimits = max(burstlimits, 1);
burstlimits = min(burstlimits, numel(binR));

for i = 1 : numel(data.burstStarts)
    data.burstShapes(i, :) = ...
        extractburst(binR(burstlimits(1, i) : burstlimits(2, i)), mbl);
end


%% We make a histogram with bin edges specified by burst starts and ends.
tic
edges = [data.burstStarts - 1; data.burstEnds] * param.binsize;
edges = edges(:)';
% Histogram of photons falliong into burst-sized bins
[~, bins] = histc(fifo.macroT * fifo.MTC, edges);

% Some bins have zeros photons in them for some reason

[~, iends] = unique(bins, 'last');
%% Sometimes there is a bug in the histogram production. I thought it is
% due to segmentation into erratic bursts with zero photons, but there is
% probably an additional problem that I do not understand. Therefore, if
% the segmentation does not work, the brute-force algorithm will be
% applied.
if numel(iends) ~= numel(data.burstStarts) * 2
    %% Try to solve the problem by adding virtual photons in the gaps.
    fprintf('Error: There are gaps in the burst histogram\n');
    fprintf('       An ettempt to fill them will be made\n');
    in1 = bins(2 : end) - bins(1 : end - 1);
    in = unique(in1);
    for i = in(in > 1);
        in2 = find(in1 == i);
        bins = [bins, zeros(1, numel(in2) * (i - 1))]; %#ok<AGROW>
        for j = fliplr(in2) + 1
            bins(j + 1 : end) = bins(j : end - 1);
            bins(j + (0 : i - 2)) = bins(j + (0 : i - 2) - 1) + (1 : (i - 1));
        end
    end
    [~, iends] = unique(bins, 'last');
end

if numel(iends) ~= numel(data.burstStarts) * 2
    %% Brute force algorithm
    warning(['Filling gaps in histogram did not help. ', ...
             'Robust brute force algorithm will be applied.']);
    data.bursts = zeros(2, numel(data.burstStarts));
    for i = 1 : numel(data.burstStarts)
        data.bursts(1, i) = find(fifo.macroT >= (data.burstStarts(i) - 1) * param.binsize / fifo.MTC, 1, 'first');
        data.bursts(2, i) = find(fifo.macroT < data.burstEnds(i) * param.binsize / fifo.MTC, 1, 'last');
    end
    % burstphotons = diff(bursts) + 1;
else
    %% Fast algorithm
    iends(1) = find(bins ~= 0, 1);
    data.bursts = reshape(iends, 2, numel(iends) / 2);
    data.bursts(1, :) = data.bursts(1, :) + 1;
    data.bursts(1) = data.bursts(1) - 1;
end
toc

% 
% for i = 1 : numel(starts)
%     starts(i) = find(fifo.macroT > (X(starts(i)) - binsize / 2) / fifo.MTC, 1, 'first');
%     ends(i) = find(fifo.macroT < (X(ends(i)) + binsize / 2) / fifo.MTC, 1, 'last');
% end

%% Calculate the number of photons in a burst
% if nargout == 4
%     burstphotons = 1 : numel(starts);
%     if exist('binR', 'var')
%         for i = burstphotons
%             burstphotons(i) = sum(binR(starts(i) : ends(i)));
%         end
%     else
%         for i = burstphotons
%             burstphotons(i) = sum(bin(starts(i) : ends(i)));
%         end
%     end
% end
% tic
% %% Separate photons into bursts
% if nargout > 4
%     bursts = zeros(2, numel(starts));
%     for i = 1 : numel(starts)
%         bursts(1, i) = find(fifo.macroT >= (starts(i) - 1) * binsize / fifo.MTC, 1, 'first');
%         bursts(2, i) = find(fifo.macroT < ends(i) * binsize / fifo.MTC, 1, 'last');
%     end
%     burstphotons = diff(bursts) + 1;
% end
% toc
% close all
% 
% bar(X(1:100000), binR(1:100000), 1)
% hold on
% plot(fifo.MTC * fifo.macroT(bursts(1,:)), -0.05 * ones(length(bursts)), 'c+')
% plot(fifo.MTC * fifo.macroT(1:100000), 0.1 * ones(1, 100000), 'g+')
% plot(fifo.MTC * fifo.macroT(burstsA(1,:)), zeros(length(burstsA)), 'r+')
% plot((starts - 1)*binsize, 0.05* ones(length(starts)), 'm+')
% plot(X(starts), 0.15* ones(length(starts)), 'y+')

%beep

function out = extractburst(burst, medlen)
burst = [zeros(1, medlen), burst, zeros(1, medlen)];
center = round(sum(burst .* (1 : int32(numel(burst)))) / sum(burst));
%if center <= medlen
out = burst(center - medlen : center + medlen);