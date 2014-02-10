function [x, y] = xy4scatter(in)
global data

switch in
    case 1
        % Scatter plot of burst photon number (kCounts) vs. 
        % burst duration (ms)
        x = 1000 * data.burstDuration;
        y = data.burstPhotons / 1000;
    case 2
        % Scatter plot of average burst photon frequency (MHz) vs. 
        % burst duration (ms)
        x = 1000 * data.burstDuration;
        y = data.burstFrequency * 1e-6;
    case 3
        % Scatter plot of average burst photon frequency (MHz) vs.
        % burst photon number (kCounts)
        x = data.burstPhotons / 1000;
        y = data.burstFrequency * 1e-6;
    case 4
        % Scatter plot of 90 percentile of burst photon frequency (MHz) vs.
        % burst photon count (kCounts)
        x = data.burstPhotons / 1000;
        y = data.burst90percentile * 1e-6;
end