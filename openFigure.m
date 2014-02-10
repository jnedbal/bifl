function openFigure(gcbo, ~)
global param    %#ok<NUSED>
global figs
global data     %#ok<NUSED>
global fifo     %#ok<NUSED>

%% We need to remove selGates to make sure that we are not carrying over 
%  gate selection from the workspace 28.6.2013
if isfield(figs, 'selGates')
    figs = rmfield(figs, 'selGates');
end

% already existing figure has the name in its tag
% newly created figure has got an empty tag

fn = get(gcbo, 'Tag');
if isempty(fn)
    % skip the file loading if the figure is being created
    return
end

% load the associated data when figure is being opened from a file
fprintf('Loading data from %s.mat file...\n', fn);
load(fn);

%% Update the handles of the figures
switch get(gcbo, 'Name')
    case 'Burst Ensemble Properties'
        figs.hMainFig(2) = gcbo;
    case 'Burst Segmentation'
        figs.hMainFig(1) = gcbo;
end
