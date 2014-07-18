function bifl(fn)
global fifo
global param
global data
%global figs %#ok<NUSED>

% Go to the directory of the file and separate the filename from the
% extension
[path, param.fname, param.ext] = fileparts(fn);
if ~isempty(path)
    fprintf('Changing to directory %s.\n', path);
    cd(path);
end

%% Parameters
if ~exist('param', 'var')
    % histogram bin size in seconds
    param.binsize = 2e-5;
    % median filter kernel before segmentation
    param.medif = 20;
    % threshold for bursts segmentation
    param.thres = 1;
    % Minimum number of photons in a burst
	param.hvMin = 300;
    % Select range for analysis
    param.analysisWindow = [740, 3730];
    %param.analysisWindow = [0 4095];
    % Select phasor frequency
    param.phasorFreq = 2 * pi * 8e+7;
end

if param.hvMin < 30
    warning(['Bursts with less than 30 photons are useless.\n', ...
             'Setting hvMin to 30.']);
    param.hvMin = 30;
end


fprintf('Analysing %s%s\n', param.fname, param.ext);


fifo = SPC830read([param.fname param.ext]);

%% Load Mitos P-Pump of Flow Sensor data
readMitos

%% Burst segmentation can be done either by one over dT analysis or by
%  photon time binning. One over dT is used if binsize is 0.

if param.binsize
    %% Histogramming analysis
    burstSeg_histc;
    if isempty(data.burstStarts)
        return
    end
    drawBursts_hist;
else
    %% One over dT analysis
    %[st, en, mf, bp] = burstSeg_dT(medfil, 0, thres, hvMin);
    %drawBursts_dT(mf, st, en, fname, thres);
end

saveBursts;

characterizeBursts;

exportICS(data.utimeHist, param.fname);

drawHistograms;

saveHistograms;



