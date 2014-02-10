function characterizeBursts
global param
global data
global fifo

fprintf('Analyzing each burst in %s\n', param.fname);

%% Burst duration in seconds
data.burstDuration = (fifo.macroT(data.bursts(2, :)) - fifo.macroT(data.bursts(1, :))) * fifo.MTC;

%% Create empty arrays for storing data
%  Average photon frequency, 90% percentile frequency and microtime
%  histogram

% mean burst frequency
data.burstFrequency = zeros(size(data.burstDuration));
% 0.9 percentile of burst frequency
data.burst90percentile = data.burstFrequency;
% phasor component 1
data.phasorG = data.burstFrequency;
% phasor component 2
data.phasorS = data.burstFrequency;
% size of 2D histograms
data.square = ceil(sqrt(numel(data.burstDuration)));
% 2D picture of microtime histograms for saving to ICS files
% fourth dimension is the detection channel number
fifo.rChan = unique(fifo.rout);
data.utimeHist = zeros([data.square, 256, data.square, numel(fifo.rChan)]);
% gate of bursts, all tru to start with
data.gate = true(size(data.burstDuration));

%% Go through each burst and calculate its properties
for i = 1 : size(data.bursts, 2)
    % Index values for each burst
    in = data.bursts(1, i) : data.bursts(2, i);
    % Macrotimes in burst
    burst = fifo.macroT(in);
    % Macrotime difference in burst
    burst = burst(2 : end) - burst(1 : end - 1);

    % mean burst frequency
    data.burstFrequency(i) = mean(1 ./ burst);

    % 0.9 percentile of burst frequency
    burst = sort(burst);
    data.burst90percentile(i) = burst(round(0.1 * numel(burst) + 0.5));

    % 2D picture of microtime histograms
    for j = 1 : numel(fifo.rChan)
        data.utimeHist( ...
            ceil(i / data.square), :, mod(i - 1, data.square) + 1, j) = ...
            hist(fifo.microT(in(fifo.rout(in) == fifo.rChan(j))), ...
                 7.5 : 16 : 4095);
    end

    % burst microtimes
    mT = fifo.microT(in);
    % select microtimes that fall within the analysis window
    mT(mT < param.analysisWindow(1) | mT > param.analysisWindow(2)) = [];
    % Convert microtimes from binary to seconds
    mT = double(mT - param.analysisWindow(1)) * 1e-8 / 4095;

    % phasor components from:
    %   Phasor-based single-molecule fluorescence lifetime imaging using a
    %   wide-field photon-counting detector.
    data.phasorG(i) = sum(cos(param.phasorFreq * mT)) / numel(mT);
    data.phasorS(i) = sum(sin(param.phasorFreq * mT)) / numel(mT);
    
    % Estimated lifetimes from:
    %   Phasor-based single-molecule fluorescence lifetime imaging using a
    %   wide-field photon-counting detector.
end
data.tau = data.phasorS ./ data.phasorG / param.phasorFreq;

% Convert mean burst frequency to Herz
data.burstFrequency = data.burstFrequency / fifo.MTC;

% Convert 0.9tile of frequency to Herz
data.burst90percentile = 1 ./ (data.burst90percentile * fifo.MTC);