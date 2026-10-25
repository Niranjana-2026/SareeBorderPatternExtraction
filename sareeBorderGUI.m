function fig = sareeBorderGUI()
% SAREEBORDERGUI Desktop GUI for Saree Border Pattern Extraction & Similarity Comparison.
%
% Syntax:
%   sareeBorderGUI()
%   fig = sareeBorderGUI()
%
% Description:
%   A comprehensive MATLAB desktop application created with uifigure, uiaxes,
%   and modern UI components that allows users to:
%     1. Load and display two saree images side by side.
%     2. Automatically detect or manually crop decorative saree border regions.
%     3. Adjust border orientation (auto, bottom, top, left, right) and width.
%     4. View extracted border patterns in high resolution.
%     5. Quantitatively compare pattern similarity across Color, Texture (GLCM),
%        Edge density/directionality, and Structural descriptors.
%     6. Export comparison graphics and structured reports to disk.
%     7. Reset or adjust analysis parameters interactively.
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    % 1. Create main Figure
    fig = uifigure('Name', 'Saree Border Pattern Extraction & Design Similarity Comparison', ...
                   'Position', [80, 50, 1240, 780], ...
                   'Color', [0.95, 0.96, 0.98]);

    % Initialize application state in UserData
    app.img1Raw = [];
    app.img2Raw = [];
    app.prep1 = [];
    app.prep2 = [];
    app.border1 = [];
    app.border2 = [];
    app.feat1 = [];
    app.feat2 = [];
    app.compResult = [];
    app.scriptDir = fileparts(mfilename('fullpath'));
    fig.UserData = app;

    % =========================================================================
    % HEADER BANNER
    % =========================================================================
    headerPanel = uipanel(fig, 'Position', [10, 715, 1220, 55], ...
                          'BackgroundColor', [0.15, 0.22, 0.35], ...
                          'BorderType', 'none');
    uilabel(headerPanel, 'Position', [15, 24, 750, 26], ...
            'Text', 'SAREE BORDER PATTERN EXTRACTION & DESIGN SIMILARITY SYSTEM', ...
            'FontName', 'Segoe UI', 'FontSize', 15, 'FontWeight', 'bold', ...
            'FontColor', [1.0, 1.0, 1.0]);
    uilabel(headerPanel, 'Position', [16, 4, 750, 18], ...
            'Text', 'Automated Border Detection, Haralick Texture Analysis, Color Histograms & Multi-Feature Comparison', ...
            'FontName', 'Segoe UI', 'FontSize', 10, 'FontColor', [0.75, 0.85, 0.95]);

    % Status Pill on Header
    statusLabel = uilabel(headerPanel, 'Position', [820, 12, 380, 30], ...
                          'Text', 'Status: Ready. Upload Saree 1 and Saree 2 to begin.', ...
                          'FontName', 'Segoe UI', 'FontSize', 10, 'FontColor', [0.9, 0.9, 0.6], ...
                          'HorizontalAlignment', 'right');

    % =========================================================================
    % LEFT PANEL: SAREE 1
    % =========================================================================
    panel1 = uipanel(fig, 'Position', [10, 175, 595, 535], ...
                     'Title', ' SAREE 1 (REFERENCE DESIGN) ', ...
                     'FontName', 'Segoe UI', 'FontSize', 11, 'FontWeight', 'bold', ...
                     'BackgroundColor', [1.0, 1.0, 1.0]);

    % Saree 1 Controls
    btnUpload1 = uibutton(panel1, 'push', 'Position', [15, 475, 120, 30], ...
                          'Text', 'Upload Saree 1', 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.2, 0.45, 0.75], 'FontColor', [1 1 1]);

    uilabel(panel1, 'Position', [145, 480, 70, 20], 'Text', 'Orientation:');
    ddOrient1 = uidropdown(panel1, 'Position', [215, 477, 100, 26], ...
                           'Items', {'auto', 'bottom', 'top', 'left', 'right'}, ...
                           'Value', 'auto');

    uilabel(panel1, 'Position', [325, 480, 45, 20], 'Text', 'Width:');
    sliderWidth1 = uislider(panel1, 'Position', [375, 492, 110, 3], ...
                            'Limits', [0.10, 0.45], 'Value', 0.22);

    btnExtract1 = uibutton(panel1, 'push', 'Position', [495, 475, 90, 30], ...
                           'Text', 'Extract', 'FontWeight', 'bold', ...
                           'BackgroundColor', [0.18, 0.60, 0.35], 'FontColor', [1 1 1]);

    btnManual1 = uibutton(panel1, 'push', 'Position', [495, 440, 90, 26], ...
                          'Text', 'Manual Crop', 'FontSize', 10, ...
                          'BackgroundColor', [0.92, 0.94, 0.96]);

    lblFile1 = uilabel(panel1, 'Position', [15, 442, 470, 20], ...
                       'Text', 'No image loaded', 'FontColor', [0.5, 0.5, 0.5], 'FontSize', 9);

    % Axes 1: Original Saree 1
    ax1 = uiaxes(panel1, 'Position', [15, 175, 565, 260]);
    title(ax1, 'Original Saree 1 (Detected Border in Neon Green)', 'FontSize', 9);
    ax1.XTick = []; ax1.YTick = []; ax1.Box = 'on';

    % Axes 2: Extracted Border 1
    axBorder1 = uiaxes(panel1, 'Position', [15, 35, 565, 130]);
    title(axBorder1, 'Extracted Border 1 Pattern Detail', 'FontSize', 9);
    axBorder1.XTick = []; axBorder1.YTick = []; axBorder1.Box = 'on';

    lblFeat1 = uilabel(panel1, 'Position', [15, 8, 565, 20], ...
                       'Text', 'Border 1 Features: (Not yet extracted)', ...
                       'FontColor', [0.3, 0.3, 0.4], 'FontSize', 9);

    % =========================================================================
    % RIGHT PANEL: SAREE 2
    % =========================================================================
    panel2 = uipanel(fig, 'Position', [615, 175, 615, 535], ...
                     'Title', ' SAREE 2 (TARGET FOR COMPARISON) ', ...
                     'FontName', 'Segoe UI', 'FontSize', 11, 'FontWeight', 'bold', ...
                     'BackgroundColor', [1.0, 1.0, 1.0]);

    % Saree 2 Controls
    btnUpload2 = uibutton(panel2, 'push', 'Position', [15, 475, 120, 30], ...
                          'Text', 'Upload Saree 2', 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.2, 0.45, 0.75], 'FontColor', [1 1 1]);

    uilabel(panel2, 'Position', [145, 480, 70, 20], 'Text', 'Orientation:');
    ddOrient2 = uidropdown(panel2, 'Position', [215, 477, 100, 26], ...
                           'Items', {'auto', 'bottom', 'top', 'left', 'right'}, ...
                           'Value', 'auto');

    uilabel(panel2, 'Position', [325, 480, 45, 20], 'Text', 'Width:');
    sliderWidth2 = uislider(panel2, 'Position', [375, 492, 110, 3], ...
                            'Limits', [0.10, 0.45], 'Value', 0.22);

    btnExtract2 = uibutton(panel2, 'push', 'Position', [505, 475, 95, 30], ...
                           'Text', 'Extract', 'FontWeight', 'bold', ...
                           'BackgroundColor', [0.18, 0.60, 0.35], 'FontColor', [1 1 1]);

    btnManual2 = uibutton(panel2, 'push', 'Position', [505, 440, 95, 26], ...
                          'Text', 'Manual Crop', 'FontSize', 10, ...
                          'BackgroundColor', [0.92, 0.94, 0.96]);

    lblFile2 = uilabel(panel2, 'Position', [15, 442, 480, 20], ...
                       'Text', 'No image loaded', 'FontColor', [0.5, 0.5, 0.5], 'FontSize', 9);

    % Axes 3: Original Saree 2
    ax2 = uiaxes(panel2, 'Position', [15, 175, 585, 260]);
    title(ax2, 'Original Saree 2 (Detected Border in Neon Green)', 'FontSize', 9);
    ax2.XTick = []; ax2.YTick = []; ax2.Box = 'on';

    % Axes 4: Extracted Border 2
    axBorder2 = uiaxes(panel2, 'Position', [15, 35, 585, 130]);
    title(axBorder2, 'Extracted Border 2 Pattern Detail', 'FontSize', 9);
    axBorder2.XTick = []; axBorder2.YTick = []; axBorder2.Box = 'on';

    lblFeat2 = uilabel(panel2, 'Position', [15, 8, 585, 20], ...
                       'Text', 'Border 2 Features: (Not yet extracted)', ...
                       'FontColor', [0.3, 0.3, 0.4], 'FontSize', 9);

    % =========================================================================
    % BOTTOM ACTION & RESULTS PANEL
    % =========================================================================
    bottomPanel = uipanel(fig, 'Position', [10, 10, 1220, 158], ...
                          'BackgroundColor', [1.0, 1.0, 1.0], ...
                          'BorderType', 'line');

    % Primary Action Button
    btnCompare = uibutton(bottomPanel, 'push', 'Position', [20, 90, 190, 48], ...
                          'Text', 'COMPARE DESIGNS', 'FontSize', 13, 'FontWeight', 'bold', ...
                          'BackgroundColor', [0.85, 0.30, 0.15], 'FontColor', [1 1 1]);

    % Reset & Save Buttons
    btnSave = uibutton(bottomPanel, 'push', 'Position', [20, 50, 190, 32], ...
                       'Text', 'Save Comparison & Report', 'FontSize', 10, ...
                       'BackgroundColor', [0.3, 0.5, 0.7], 'FontColor', [1 1 1]);

    btnReset = uibutton(bottomPanel, 'push', 'Position', [20, 14, 190, 28], ...
                        'Text', 'Reset All', 'FontSize', 10, ...
                        'BackgroundColor', [0.90, 0.90, 0.92]);

    % Similarity Results Badges
    pnlScore = uipanel(bottomPanel, 'Position', [225, 14, 210, 124], ...
                       'BackgroundColor', [0.96, 0.98, 1.0], 'BorderType', 'line');
    uilabel(pnlScore, 'Position', [10, 95, 190, 20], ...
            'Text', 'OVERALL SIMILARITY', 'FontWeight', 'bold', ...
            'FontColor', [0.15, 0.25, 0.45], 'HorizontalAlignment', 'center');
    lblOverallScore = uilabel(pnlScore, 'Position', [10, 38, 190, 50], ...
                              'Text', '-- %', 'FontSize', 32, 'FontWeight', 'bold', ...
                              'FontColor', [0.1, 0.4, 0.8], 'HorizontalAlignment', 'center');
    lblQualitative = uilabel(pnlScore, 'Position', [5, 6, 200, 28], ...
                             'Text', 'Awaiting comparison', 'FontSize', 9, ...
                             'HorizontalAlignment', 'center', 'FontColor', [0.4, 0.4, 0.5]);

    % Sub-Metric Breakdown Badges
    pnlMetrics = uipanel(bottomPanel, 'Position', [445, 14, 450, 124], ...
                         'BackgroundColor', [0.98, 0.99, 1.0], 'BorderType', 'line');
    uilabel(pnlMetrics, 'Position', [15, 96, 420, 20], ...
            'Text', 'QUANTITATIVE FEATURE SIMILARITY BREAKDOWN:', ...
            'FontWeight', 'bold', 'FontSize', 10, 'FontColor', [0.2, 0.25, 0.35]);

    lblColorScore = uilabel(pnlMetrics, 'Position', [15, 68, 200, 22], ...
                            'Text', 'Color Palette (HSV)    : -- %', 'FontSize', 10);
    lblTextureScore = uilabel(pnlMetrics, 'Position', [15, 42, 200, 22], ...
                              'Text', 'Weave Texture (GLCM)   : -- %', 'FontSize', 10);
    lblEdgeScore = uilabel(pnlMetrics, 'Position', [225, 68, 210, 22], ...
                           'Text', 'Edge & Motif Angles : -- %', 'FontSize', 10);
    lblStructScore = uilabel(pnlMetrics, 'Position', [225, 42, 210, 22], ...
                             'Text', 'Entropy & Solidity  : -- %', 'FontSize', 10);

    lblFormulaNote = uilabel(pnlMetrics, 'Position', [15, 8, 420, 26], ...
                             'Text', 'Score Formula: 0.35*Color + 0.30*Texture + 0.20*Edge + 0.15*Structural', ...
                             'FontSize', 9, 'FontColor', [0.45, 0.45, 0.55]);

    % Quick Demo / Benchmark Launcher on bottom right
    pnlQuick = uipanel(bottomPanel, 'Position', [905, 14, 305, 124], ...
                       'BackgroundColor', [0.95, 0.97, 0.96], 'BorderType', 'line');
    uilabel(pnlQuick, 'Position', [10, 96, 280, 20], ...
            'Text', 'QUICK ACTIONS & BENCHMARKS:', 'FontWeight', 'bold', 'FontSize', 10);
    btnLoadSilkDemo = uibutton(pnlQuick, 'push', 'Position', [10, 62, 135, 28], ...
                               'Text', 'Load Silk Sample', 'FontSize', 9);
    btnLoadCottonDemo = uibutton(pnlQuick, 'push', 'Position', [155, 62, 140, 28], ...
                                 'Text', 'Load Cotton Sample', 'FontSize', 9);
    btnLoadHandloomDemo = uibutton(pnlQuick, 'push', 'Position', [10, 24, 135, 28], ...
                                   'Text', 'Load Handloom', 'FontSize', 9);
    btnLoadDesignerDemo = uibutton(pnlQuick, 'push', 'Position', [155, 24, 140, 28], ...
                                   'Text', 'Load Designer', 'FontSize', 9);

    % =========================================================================
    % ATTACH EVENT CALLBACKS
    % =========================================================================

    % Upload Button 1
    btnUpload1.ButtonPushedFcn = @(src, event) onUploadImage(1);
    % Upload Button 2
    btnUpload2.ButtonPushedFcn = @(src, event) onUploadImage(2);

    % Extract Button 1
    btnExtract1.ButtonPushedFcn = @(src, event) onExtractBorder(1);
    % Extract Button 2
    btnExtract2.ButtonPushedFcn = @(src, event) onExtractBorder(2);

    % Manual Crop 1
    btnManual1.ButtonPushedFcn = @(src, event) onManualCrop(1);
    % Manual Crop 2
    btnManual2.ButtonPushedFcn = @(src, event) onManualCrop(2);

    % Compare Button
    btnCompare.ButtonPushedFcn = @(src, event) onCompareDesigns();

    % Save Button
    btnSave.ButtonPushedFcn = @(src, event) onSaveResults();

    % Reset Button
    btnReset.ButtonPushedFcn = @(src, event) onReset();

    % Quick Benchmarks
    btnLoadSilkDemo.ButtonPushedFcn = @(src, event) onLoadBenchmark('silk', 1);
    btnLoadCottonDemo.ButtonPushedFcn = @(src, event) onLoadBenchmark('cotton', 2);
    btnLoadHandloomDemo.ButtonPushedFcn = @(src, event) onLoadBenchmark('handloom', 1);
    btnLoadDesignerDemo.ButtonPushedFcn = @(src, event) onLoadBenchmark('designer', 2);

    % =========================================================================
    % CALLBACK IMPLEMENTATIONS
    % =========================================================================

    function onUploadImage(idx)
        filterList = {'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Supported Image Files (*.jpg, *.png, *.tif)'};
        [fileName, pathName] = uigetfile(filterList, sprintf('Select Saree Image %d', idx), app.scriptDir);
        if isequal(fileName, 0)
            return; % User canceled
        end

        fullPath = fullfile(pathName, fileName);
        loadImageIntoSlot(fullPath, idx);
    end

    function loadImageIntoSlot(filePath, idx)
        updateStatus(sprintf('Loading Saree %d: %s ...', idx, filePath));
        try
            img = imread(filePath);
            appData = fig.UserData;
            prep = preprocessSareeImage(img);

            if idx == 1
                appData.img1Raw = img;
                appData.prep1 = prep;
                [~, fn, ext] = fileparts(filePath);
                lblFile1.Text = sprintf('%s%s (%dx%d)', fn, ext, prep.origSize(2), prep.origSize(1));
                imshow(prep.original, 'Parent', ax1);
                title(ax1, 'Saree 1 Original (Click Extract to detect border)', 'FontSize', 9);
                cla(axBorder1);
                lblFeat1.Text = 'Border 1 Features: (Ready for extraction)';
            else
                appData.img2Raw = img;
                appData.prep2 = prep;
                [~, fn, ext] = fileparts(filePath);
                lblFile2.Text = sprintf('%s%s (%dx%d)', fn, ext, prep.origSize(2), prep.origSize(1));
                imshow(prep.original, 'Parent', ax2);
                title(ax2, 'Saree 2 Original (Click Extract to detect border)', 'FontSize', 9);
                cla(axBorder2);
                lblFeat2.Text = 'Border 2 Features: (Ready for extraction)';
            end

            fig.UserData = appData;
            updateStatus(sprintf('Saree %d successfully loaded.', idx));
            % Auto-extract immediately for convenience
            onExtractBorder(idx);
        catch ME
            uialert(fig, ME.message, 'Image Load Error');
            updateStatus(sprintf('Error loading Saree %d.', idx));
        end
    end

    function onExtractBorder(idx)
        appData = fig.UserData;
        if idx == 1
            if isempty(appData.prep1)
                uialert(fig, 'Please upload Saree 1 before extracting.', 'No Image Loaded');
                return;
            end
            orient = ddOrient1.Value;
            widthFrac = sliderWidth1.Value;
            updateStatus('Extracting decorative border for Saree 1...');
            try
                bData = extractSareeBorder(appData.prep1, 'Orientation', orient, 'BorderWidthFraction', widthFrac);
                feat = extractPatternFeatures(bData.borderRGB);

                appData.border1 = bData;
                appData.feat1 = feat;

                imshow(bData.annotatedImage, 'Parent', ax1);
                title(ax1, sprintf('Saree 1: %s border detected (conf: %.2f)', bData.orientation, bData.confidence), 'FontSize', 9);
                imshow(bData.borderRGB, 'Parent', axBorder1);
                title(axBorder1, sprintf('Border 1 Crop [%dx%d]', size(bData.borderRGB, 2), size(bData.borderRGB, 1)), 'FontSize', 9);
                lblFeat1.Text = sprintf('Border 1: %s', feat.summary);

                fig.UserData = appData;
                updateStatus('Border 1 extraction complete.');
            catch ME
                uialert(fig, ME.message, 'Extraction Error');
            end
        else
            if isempty(appData.prep2)
                uialert(fig, 'Please upload Saree 2 before extracting.', 'No Image Loaded');
                return;
            end
            orient = ddOrient2.Value;
            widthFrac = sliderWidth2.Value;
            updateStatus('Extracting decorative border for Saree 2...');
            try
                bData = extractSareeBorder(appData.prep2, 'Orientation', orient, 'BorderWidthFraction', widthFrac);
                feat = extractPatternFeatures(bData.borderRGB);

                appData.border2 = bData;
                appData.feat2 = feat;

                imshow(bData.annotatedImage, 'Parent', ax2);
                title(ax2, sprintf('Saree 2: %s border detected (conf: %.2f)', bData.orientation, bData.confidence), 'FontSize', 9);
                imshow(bData.borderRGB, 'Parent', axBorder2);
                title(axBorder2, sprintf('Border 2 Crop [%dx%d]', size(bData.borderRGB, 2), size(bData.borderRGB, 1)), 'FontSize', 9);
                lblFeat2.Text = sprintf('Border 2: %s', feat.summary);

                fig.UserData = appData;
                updateStatus('Border 2 extraction complete.');
            catch ME
                uialert(fig, ME.message, 'Extraction Error');
            end
        end
    end

    function onManualCrop(idx)
        appData = fig.UserData;
        if idx == 1
            if isempty(appData.prep1), return; end
            currAx = ax1;
            currPrep = appData.prep1;
        else
            if isempty(appData.prep2), return; end
            currAx = ax2;
            currPrep = appData.prep2;
        end

        updateStatus(sprintf('Click and drag a rectangle on Saree %d image to crop border...', idx));
        try
            if exist('drawrectangle', 'file')
                roi = drawrectangle(currAx);
                pos = roi.Position; % [x y w h]
                delete(roi);
            else
                % Interactive rect fallback
                pos = [1, currPrep.resizedSize(1) * 0.7, currPrep.resizedSize(2), currPrep.resizedSize(1) * 0.28];
            end

            bData = extractSareeBorder(currPrep, 'ManualBBox', pos);
            feat = extractPatternFeatures(bData.borderRGB);

            if idx == 1
                appData.border1 = bData;
                appData.feat1 = feat;
                imshow(bData.annotatedImage, 'Parent', ax1);
                imshow(bData.borderRGB, 'Parent', axBorder1);
                lblFeat1.Text = sprintf('Border 1 (Manual): %s', feat.summary);
            else
                appData.border2 = bData;
                appData.feat2 = feat;
                imshow(bData.annotatedImage, 'Parent', ax2);
                imshow(bData.borderRGB, 'Parent', axBorder2);
                lblFeat2.Text = sprintf('Border 2 (Manual): %s', feat.summary);
            end

            fig.UserData = appData;
            updateStatus(sprintf('Manual border crop applied for Saree %d.', idx));
        catch ME
            uialert(fig, ME.message, 'Manual Crop Error');
        end
    end

    function onCompareDesigns()
        appData = fig.UserData;
        if isempty(appData.feat1) || isempty(appData.feat2)
            uialert(fig, 'Please extract borders for both Saree 1 and Saree 2 before comparing.', 'Comparison Incomplete');
            return;
        end

        updateStatus('Comparing border designs using quantitative multi-feature analysis...');
        try
            res = compareSareeBorders(appData.feat1, appData.feat2);
            appData.compResult = res;
            fig.UserData = appData;

            % Update Score Display
            lblOverallScore.Text = sprintf('%.1f%%', res.overallSimilarityPct);
            if res.overallSimilarityPct >= 75
                lblOverallScore.FontColor = [0.1, 0.65, 0.25]; % Green
            elseif res.overallSimilarityPct >= 50
                lblOverallScore.FontColor = [0.85, 0.55, 0.1]; % Orange
            else
                lblOverallScore.FontColor = [0.80, 0.20, 0.15]; % Red
            end

            lblQualitative.Text = res.interpretation;
            lblColorScore.Text   = sprintf('Color Palette (HSV)    : %5.1f%%', res.colorSimilarityPct);
            lblTextureScore.Text = sprintf('Weave Texture (GLCM)   : %5.1f%%', res.textureSimilarityPct);
            lblEdgeScore.Text    = sprintf('Edge & Motif Angles : %5.1f%%', res.edgeSimilarityPct);
            lblStructScore.Text  = sprintf('Entropy & Solidity  : %5.1f%%', res.structuralSimilarityPct);

            updateStatus(sprintf('Comparison Complete: %.1f%% overall similarity (%s)', ...
                res.overallSimilarityPct, res.interpretation));
        catch ME
            uialert(fig, ME.message, 'Comparison Error');
        end
    end

    function onSaveResults()
        appData = fig.UserData;
        if isempty(appData.compResult)
            uialert(fig, 'Please perform comparison before saving results.', 'Nothing to Save');
            return;
        end

        outDir = fullfile(app.scriptDir, 'output');
        compDir = fullfile(outDir, 'comparisons');
        repDir = fullfile(outDir, 'reports');
        if ~exist(compDir, 'dir'), mkdir(compDir); end
        if ~exist(repDir, 'dir'), mkdir(repDir); end

        timestamp = datestr(now, 'yyyymmdd_HHMMSS');

        % 1. Save side-by-side comparison figure
        compFigPath = fullfile(compDir, sprintf('comparison_%s.png', timestamp));
        hFigExport = figure('Visible', 'off', 'Position', [100, 100, 1100, 600]);
        subplot(2, 2, 1);
        imshow(appData.border1.annotatedImage);
        title('Saree 1 Annotated Border', 'FontSize', 10);
        subplot(2, 2, 2);
        imshow(appData.border2.annotatedImage);
        title('Saree 2 Annotated Border', 'FontSize', 10);
        subplot(2, 2, 3);
        imshow(appData.border1.borderRGB);
        title('Border 1 Crop', 'FontSize', 10);
        subplot(2, 2, 4);
        imshow(appData.border2.borderRGB);
        title(sprintf('Border 2 Crop (Similarity: %.1f%%)', appData.compResult.overallSimilarityPct), 'FontSize', 10);
        saveas(hFigExport, compFigPath);
        close(hFigExport);

        % 2. Save structured text report
        repFilePath = fullfile(repDir, sprintf('report_%s.txt', timestamp));
        fid = fopen(repFilePath, 'w');
        if fid ~= -1
            fprintf(fid, '%s\n', appData.compResult.reportText);
            fclose(fid);
        end

        uialert(fig, sprintf('Results saved successfully:\n1. %s\n2. %s', compFigPath, repFilePath), 'Results Saved');
        updateStatus(sprintf('Results saved to output/ folder (%s)', timestamp));
    end

    function onReset()
        appData = fig.UserData;
        appData.img1Raw = [];
        appData.img2Raw = [];
        appData.prep1 = [];
        appData.prep2 = [];
        appData.border1 = [];
        appData.border2 = [];
        appData.feat1 = [];
        appData.feat2 = [];
        appData.compResult = [];
        fig.UserData = appData;

        cla(ax1); cla(ax2); cla(axBorder1); cla(axBorder2);
        lblFile1.Text = 'No image loaded';
        lblFile2.Text = 'No image loaded';
        lblFeat1.Text = 'Border 1 Features: (Not yet extracted)';
        lblFeat2.Text = 'Border 2 Features: (Not yet extracted)';
        lblOverallScore.Text = '-- %';
        lblOverallScore.FontColor = [0.1, 0.4, 0.8];
        lblQualitative.Text = 'Awaiting comparison';
        lblColorScore.Text   = 'Color Palette (HSV)    : -- %';
        lblTextureScore.Text = 'Weave Texture (GLCM)   : -- %';
        lblEdgeScore.Text    = 'Edge & Motif Angles : -- %';
        lblStructScore.Text  = 'Entropy & Solidity  : -- %';
        updateStatus('Interface reset. Upload new images to begin.');
    end

    function onLoadBenchmark(category, slotIdx)
        datasetDir = fullfile(app.scriptDir, 'dataset');
        catDir = fullfile(datasetDir, category);
        % Check if files exist
        if ~exist(catDir, 'dir') || isempty(dir(catDir))
            prepareDataset();
        end
        files = dir(fullfile(catDir, '*.png'));
        if isempty(files)
            files = dir(fullfile(catDir, '*.jpg'));
        end
        if ~isempty(files)
            targetPath = fullfile(catDir, files(1).name);
            loadImageIntoSlot(targetPath, slotIdx);
        else
            uialert(fig, sprintf('No images found in dataset/%s/. Please run downloadDataset.m.', category), 'Dataset Empty');
        end
    end

    function updateStatus(msg)
        statusLabel.Text = sprintf('Status: %s', msg);
        drawnow;
    end
end
