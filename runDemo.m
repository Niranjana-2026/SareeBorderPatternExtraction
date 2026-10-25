function demoResult = runDemo()
% RUNDEMO Executes an automated end-to-end demonstration of saree border extraction and comparison.
%
% Syntax:
%   runDemo
%   demoResult = runDemo()
%
% Description:
%   This script runs a non-interactive demonstration of the entire pipeline:
%     1. Validates dataset availability (generates calibration samples if needed).
%     2. Loads two distinct saree designs (e.g., Silk vs Handloom).
%     3. Preprocesses both images (grayscale, denoising, contrast enhancement).
%     4. Detects and extracts decorative border regions.
%     5. Extracts 49-D multi-descriptor feature vectors (Color, GLCM, Edge, Structural).
%     6. Computes quantitative weighted similarity score.
%     7. Exports visualization graphic to output/comparisons/demo_comparison.png.
%     8. Exports report to output/reports/demo_report.txt.
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    fprintf('==============================================================================\n');
    fprintf('  RUNNING AUTOMATED SAREE BORDER PATTERN EXTRACTION DEMO                      \n');
    fprintf('==============================================================================\n');

    scriptDir = fileparts(mfilename('fullpath'));
    dsDir = fullfile(scriptDir, 'dataset');
    outDir = fullfile(scriptDir, 'output');
    compDir = fullfile(outDir, 'comparisons');
    repDir = fullfile(outDir, 'reports');

    if ~exist(compDir, 'dir'), mkdir(compDir); end
    if ~exist(repDir, 'dir'), mkdir(repDir); end

    % 1. Ensure dataset is prepared
    summary = prepareDataset();

    % 2. Select two sample images for demonstration
    silkFiles = dir(fullfile(dsDir, 'silk', '*.png'));
    if isempty(silkFiles), silkFiles = dir(fullfile(dsDir, 'silk', '*.jpg')); end

    handloomFiles = dir(fullfile(dsDir, 'handloom', '*.png'));
    if isempty(handloomFiles), handloomFiles = dir(fullfile(dsDir, 'handloom', '*.jpg')); end

    cottonFiles = dir(fullfile(dsDir, 'cotton', '*.png'));
    if isempty(cottonFiles), cottonFiles = dir(fullfile(dsDir, 'cotton', '*.jpg')); end

    if ~isempty(silkFiles) && ~isempty(handloomFiles)
        file1 = fullfile(dsDir, 'silk', silkFiles(1).name);
        file2 = fullfile(dsDir, 'handloom', handloomFiles(1).name);
        name1 = ['Silk: ', silkFiles(1).name];
        name2 = ['Handloom: ', handloomFiles(1).name];
    elseif ~isempty(silkFiles) && ~isempty(cottonFiles)
        file1 = fullfile(dsDir, 'silk', silkFiles(1).name);
        file2 = fullfile(dsDir, 'cotton', cottonFiles(1).name);
        name1 = ['Silk: ', silkFiles(1).name];
        name2 = ['Cotton: ', cottonFiles(1).name];
    else
        allImgs = dir(fullfile(dsDir, 'processed', '*.png'));
        if isempty(allImgs), allImgs = dir(fullfile(dsDir, 'processed', '*.jpg')); end
        file1 = fullfile(dsDir, 'processed', allImgs(1).name);
        file2 = fullfile(dsDir, 'processed', allImgs(min(2, length(allImgs))).name);
        name1 = allImgs(1).name;
        name2 = allImgs(min(2, length(allImgs))).name;
    end

    fprintf('\nSelected Comparison Pair:\n');
    fprintf('  Sample 1: %s\n', name1);
    fprintf('  Sample 2: %s\n\n', name2);

    % 3. Preprocess Images
    fprintf('Step 1: Preprocessing Saree Images (Denoising & Contrast Enhancement)...\n');
    prep1 = preprocessSareeImage(file1);
    prep2 = preprocessSareeImage(file2);
    fprintf('  Sample 1 dimensions: %dx%d (scaled to %dx%d)\n', ...
        prep1.origSize(2), prep1.origSize(1), prep1.resizedSize(2), prep1.resizedSize(1));
    fprintf('  Sample 2 dimensions: %dx%d (scaled to %dx%d)\n', ...
        prep2.origSize(2), prep2.origSize(1), prep2.resizedSize(2), prep2.resizedSize(1));

    % 4. Border Extraction
    fprintf('\nStep 2: Detecting & Extracting Decorative Border Regions...\n');
    border1 = extractSareeBorder(prep1, 'Orientation', 'auto');
    border2 = extractSareeBorder(prep2, 'Orientation', 'auto');
    fprintf('  Border 1: Detected %s border [%dx%d pixels] (Confidence: %.2f)\n', ...
        border1.orientation, size(border1.borderRGB, 2), size(border1.borderRGB, 1), border1.confidence);
    fprintf('  Border 2: Detected %s border [%dx%d pixels] (Confidence: %.2f)\n', ...
        border2.orientation, size(border2.borderRGB, 2), size(border2.borderRGB, 1), border2.confidence);

    % 5. Feature Extraction
    fprintf('\nStep 3: Extracting Quantitative Visual Features...\n');
    feat1 = extractPatternFeatures(border1.borderRGB);
    feat2 = extractPatternFeatures(border2.borderRGB);
    fprintf('  Border 1: %s\n', feat1.summary);
    fprintf('  Border 2: %s\n', feat2.summary);

    % 6. Similarity Comparison
    fprintf('\nStep 4: Computing Weighted Multi-Feature Similarity Score...\n');
    result = compareSareeBorders(feat1, feat2, 'SaveReport', true, 'OutputDir', repDir);

    fprintf('\n==============================================================================\n');
    fprintf('                           DEMO COMPARISON RESULTS                            \n');
    fprintf('==============================================================================\n');
    fprintf('  OVERALL SIMILARITY SCORE : %.2f%%\n', result.overallSimilarityPct);
    fprintf('  QUALITATIVE ASSESSMENT   : %s\n', result.interpretation);
    fprintf('------------------------------------------------------------------------------\n');
    fprintf('  Color Palette Similarity (HSV)    : %6.2f%%\n', result.colorSimilarityPct);
    fprintf('  Textile Texture Similarity (GLCM) : %6.2f%%\n', result.textureSimilarityPct);
    fprintf('  Edge & Motif Angle Similarity     : %6.2f%%\n', result.edgeSimilarityPct);
    fprintf('  Structural / Entropy Similarity   : %6.2f%%\n', result.structuralSimilarityPct);
    fprintf('==============================================================================\n');

    % 7. Save Demo Comparison Figure
    figOut = figure('Visible', 'off', 'Position', [100, 100, 1100, 650]);
    subplot(2, 2, 1);
    imshow(border1.annotatedImage);
    title(sprintf('Saree 1: %s', name1), 'Interpreter', 'none', 'FontSize', 10);

    subplot(2, 2, 2);
    imshow(border2.annotatedImage);
    title(sprintf('Saree 2: %s', name2), 'Interpreter', 'none', 'FontSize', 10);

    subplot(2, 2, 3);
    imshow(border1.borderRGB);
    title('Extracted Border 1 Pattern', 'FontSize', 10);

    subplot(2, 2, 4);
    imshow(border2.borderRGB);
    title(sprintf('Extracted Border 2 Pattern (Similarity: %.2f%%)', result.overallSimilarityPct), 'FontSize', 10);

    compImgPath = fullfile(compDir, 'demo_comparison.png');
    saveas(figOut, compImgPath);
    close(figOut);

    fprintf('\nSaved Artifacts:\n');
    fprintf('  Comparison Graphic: %s\n', compImgPath);
    fprintf('  Detailed Report   : %s\n\n', result.reportFilePath);

    demoResult.sample1 = name1;
    demoResult.sample2 = name2;
    demoResult.border1 = border1;
    demoResult.border2 = border2;
    demoResult.features1 = feat1;
    demoResult.features2 = feat2;
    demoResult.similarity = result;
    demoResult.comparisonImage = compImgPath;
end
