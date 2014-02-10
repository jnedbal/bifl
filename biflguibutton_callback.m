function biflguibutton_callback(gcbo, ~)
global param
global h

switch gcbo
    case h.Dir(3)
        folder_name = uigetdir(param.folder, 'BIFL Analysis Options');
        if isequal(folder_name, 0)
            return
        end
        param.folder = folder_name;
        if exist([param.folder '/bifl.mat'], 'file')
            a = questdlg( ...
                'Do you want to load settings previous settings?', ...
                'BIFL Analysis Options', 'Yes', 'No', 'No');
            if isequal(a, 'Yes')
                ptmp = load([param.folder '/bifl.mat']);
                ps = {'binsize', 'medif', 'PDFs', 'thres', 'hvMin', ...
                      'phasorFreq', 'analysisWindow', 'files', 'flow', ...
                      'flowFile', 'flowFolder', 'pumpFile', ...
                      'pumpFolder', 'pumpTitle'};
                for i = 1 : numel(ps)
                    if ~isfield(ptmp.param, ps{i})
                        continue
                    end
                    param = setfield(param, ps{i}, ...
                        getfield(ptmp.param, ps{i})); %#ok<GFLD,SFLD>
                end
                param.folder = folder_name;
            end
        end
        param2editbox;
        biflguicreatecheckbox;
        set(h.Dir(2), 'String', folder_name)

        %% Make sure the visibility is all correct
        biflguibutton_callback(h.Tab(1));
    case h.Start
        % update files
        for j = 1 : numel(h.File)
            param.files{2, j} = get(h.File(j), 'Value');
        end
        % update the generate PDF checkbox
        param.PDFs = get(h.PDFs, 'Value');
        % update the flow file selection
        param.flow = ~isempty(param.pumpTag);
        param.binsize = ...
            str2num(get(h.ParamVal(1), 'String')) / 1e+6; %#ok<*ST2NM>
        param.medif = str2num(get(h.ParamVal(2), 'String'));
        param.thres = str2num(get(h.ParamVal(3), 'String'));
        param.hvMin = str2num(get(h.ParamVal(4), 'String'));
        param.phasorFreq = ...
            str2num(get(h.ParamVal(5), 'String')) * 2e+6 * pi;
        param.analysisWindow(1) = str2num(get(h.ParamVal(6), 'String'));
        param.analysisWindow(2) = str2num(get(h.ParamVal(7), 'String'));
        save([param.folder '/bifl.mat'], 'param');

        curfold = pwd;
        cd(param.folder);

        % Check if directory with analysis parameter name exists
        nfn = sprintf('bs%03gus_mf%03g_th%05.3f_hv%04g_fr%03gMHz', ...
            param.binsize / 1e-6, ...
            param.medif, ...
            param.thres, ...
            param.hvMin, ...
            param.phasorFreq / 2e+6 / pi);
        if ~exist(nfn, 'dir')
            mkdir(nfn);
        end

        % String holding links to all create PDF files for their subsequent merging
        psnames = '';

        fIn = find(cell2mat(param.files(2, :)));
        set(h.Fig, 'Pointer', 'watch');
        drawnow
        for i = fIn
            % Run bifl analysis

            bifl(param.files{1, i})
            
            % close figure if more are to be processed
            if ishandle(h.Fig) && i < fIn(end)
                set(h.Fig, 'HandleVisibility', 'off');
                close all;
                set(h.Fig, 'HandleVisibility', 'on');
            end

            if ~param.PDFs
                % when combined PDF is not needed
                continue
            end

            % root of filename
            [~, rn] = fileparts(param.files{1, i});

            % if bifl did not produce anything, jump to the next file
            if ~exist(sprintf('%s.seg.pdf', rn), 'file')
                continue
            end

            % Move all project files into its own directory
            for j = fliplr(dir([rn, '.*'])')
                if ~(isequal(j.name(end - 2 : end), 'set') || ...
                    isequal(j.name(end - 2 : end), 'spc'))
                    movefile(j.name, sprintf('%s/%s', nfn, j.name));
                end
                % list all PDF files
                if isequal(j.name(end - 2 : end), 'pdf')
                    psnames = sprintf('%s %s/%s', psnames, nfn, j.name);
                end
            end
            % Move all project files into its own directory
            for j = fliplr(dir([rn, '_Ch*.ics'])')
                movefile(j.name, sprintf('%s/%s', nfn, j.name));
            end
        end
        set(h.Fig, 'Pointer', 'arrow');

        if ~param.PDFs
            % when combined PDF is not needed
            cd(curfold);
            return
        end

        %% **********************************************
        %  *  Merge PDF outputs into a single document  *
        %  **********************************************

        % filename of the resulting PDF file
        fn = sprintf('%g-%02g-%02g-%02g-%02g-%02g.pdf', round(clock));
        fprintf('Combining all PDF files into %s...\n', fn)

        % Make sure to run the correct version of ghostscript
        if isequal(computer, 'PCWIN')
            gs = 'gswin32';
        elseif isequal(computer, 'GLNXA64') || isequal(computer, 'GLNX86')
            gs = 'gs';
        end

        % Run ghostscript
        system(sprintf(['%s -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite ', ...
                        '-sOutputFile=%s %s'], gs, fn, psnames));
        cd(curfold);


    case h.Reset
        param.analysisWindow = [720, 3730];
        param.binsize = 2e-5;
        param.medif = 20;
        param.thres = 1;
        param.hvMin = 300;
        param.phasorFreq = 2 * pi * 2 * 8e+7;
        param.files(2, :) = repmat({1}, 1, size(param.files, 2));
        param2editbox;
        %set(h.File, 'Value', 1);
        set(h.PDFs, 'Value', 1);

    case {h.Tab(1), h.Tab(2), h.Tab(3)}
        %% Changing the tabs
        in = find(h.Tab == gcbo);

        set(h.Tab, 'FontWeight', 'normal', 'Value', 0)
        set(h.Tab(in), 'FontWeight', 'bold', 'Value', 1)

        switch in
            case 1
                % Make controls visible
                set(h.Dir, 'Visible', 'on')
                set(h.File, 'Visible', 'on');

                % Make controls invisible
                set(h.ParamLab, 'Visible', 'off');
                set(h.ParamVal, 'Visible', 'off');
                set(h.ParamUns, 'Visible', 'off');
                set(h.PDFs, 'Visible', 'off');
                set(h.Reset, 'Visible', 'off');
                set(h.pumpBut, 'Visible', 'off');
                if isfield(h, 'pumpDelBut')
                    set(h.pumpDelBut, 'Visible', 'off');
                end
                set(h.pumpLab, 'Visible', 'off');
                set(h.pumpRadio(h.pumpRadio > 0), 'Visible', 'off');

            case 2
                % Make controls visible
                set(h.ParamLab, 'Visible', 'on');
                set(h.ParamVal, 'Visible', 'on');
                set(h.ParamUns, 'Visible', 'on');
                set(h.PDFs, 'Visible', 'on');
                set(h.Reset, 'Visible', 'on');

                % Make controls invisible
                set(h.Dir, 'Visible', 'off')
                set(h.File, 'Visible', 'off');
                set(h.pumpBut, 'Visible', 'off');
                if isfield(h, 'pumpDelBut')
                    set(h.pumpDelBut, 'Visible', 'off');
                end
                set(h.pumpLab, 'Visible', 'off');
                set(h.pumpRadio(h.pumpRadio > 0), 'Visible', 'off');

            case 3
                % Make controls visible
                set(h.pumpBut, 'Visible', 'on');
                if isfield(h, 'pumpDelBut')
                    set(h.pumpDelBut, 'Visible', 'on');
                end
                set(h.pumpLab, 'Visible', 'on');
                set(h.pumpRadio(h.pumpRadio > 0), 'Visible', 'on');

                % Make controls invisible
                set(h.Dir, 'Visible', 'off');
                set(h.File, 'Visible', 'off');
                set(h.ParamLab, 'Visible', 'off');
                set(h.ParamVal, 'Visible', 'off');
                set(h.ParamUns, 'Visible', 'off');
                set(h.PDFs, 'Visible', 'off');
                set(h.Reset, 'Visible', 'off');
        end

    case num2cell(h.pumpBut)
        in = find(h.pumpBut == gcbo);       % Button index
        %% Select CSV files for pump pressure of flow speed
        if isfield(param, 'pumpFolder')
            if iscell(param.pumpFolder)
                if in > numel(param.pumpFolder) && in > 1
                    folder_name = param.pumpFolder{end};
                elseif in > 1
                    folder_name = param.pumpFolder{in};
                else
                    folder_name = param.folder;
                end
            else
                folder_name = param.pumpFolder;
                param = rmfield(param, 'pumpFolder');
                param = rmfield(param, 'pumpFile');
            end
        else
            folder_name = param.folder;
        end
        [filename, folder_name] = ...
            uigetfile('*.csv', get(gcbo, 'Tag'), folder_name);
        if isequal(folder_name, 0)
            return
        end
        
        %% Read the titles
        try
            fid = fopen([folder_name filename], 'r');
            titles = fgetl(fid);
            firstLine = fgetl(fid);
            fclose(fid);
            titles(regexp(titles, ',[A-Z]')) = '@';
            titles = textscan(titles, '%s', 'Delimiter', '@');
            titles = titles{1}(2 : end - 1);
            firstLine = textscan(firstLine, '%s', 'Delimiter', ',');
            firstLine = firstLine{1}(2 : end);
            column = find(~cellfun(@isempty, firstLine));
            titles = titles(column);
        catch %#ok<CTCH>
            warning('An incompatible file was chosen...')
            return
        end
        if isempty(titles)
            warning('An incompatible file was chosen...')
            return
        end
        param.pumpFolder{in} = folder_name;
        param.pumpFile{in} = filename;
        param.pumpTitle{in} = titles;
        param.pumpColumn{in} = column;

        arrangeFlow;

    case num2cell(h.pumpDelBut)
        in = h.pumpDelBut == gcbo;       % Button index
        %% Delte sections
        param.pumpFolder(in) = [];
        param.pumpFile(in) = [];
        param.pumpTitle(in) = [];
        param.pumpColumn(in) = [];

        arrangeFlow;
end