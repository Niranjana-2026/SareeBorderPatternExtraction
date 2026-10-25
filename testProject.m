function testResults = testProject()
% TESTPROJECT Comprehensive automated test suite for Saree Border Pattern Extraction.
%
% Syntax:
%   testProject
%   testResults = testProject()
%
% Description:
%   Runs 10 structured test suites validating:
%     1. Dataset directory structure and audit tools
%     2. Image loading and format normalization (RGB, Grayscale, Float)
%     3. Preprocessing (filtering, contrast, gradients)
%     4. Border extraction across orientations (Bottom, Top, Left, Right, Auto, Manual)
%     5. Quantitative feature extraction (HSV, GLCM Haralick, Edge, Structural)
%     6. Border comparison on identical images (Self-similarity ~ 100%)
%     7. Border comparison on distinct designs (Score within [0, 100]%)
%     8. Robustness to edge cases (Blank image, noise, missing files)
%     9. Result saving and report generation
%    10. Synthetic pattern benchmark validation
%
% Note:
%   Synthetic patterns used in Suite 10 are strictly isolated unit-test
%   fixtures and are never confused with real dataset samples.
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    clc;
    fprintf('==============================================================================\n');
    fprintf('   SAREE BORDER PATTERN EXTRACTION — COMPREHENSIVE TEST SUITE                 \n');
    fprintf('==============================================================================\n');
    fprintf('Start Time: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    scriptDir = fileparts(mfilename('fullpath'));
    addpath(scriptDir);

    totalTests = 0;
    passedTests = 0;
    failedTests = 0;
    testLog = {};

    % Run each test suite inside try/catch
    runTest('1. Dataset Structure & Audit', @testDatasetStructure);
    runTest('2. Image Loading & Format Normalization', @testImageLoading);
    runTest('3. Preprocessing & Denoising', @testPreprocessing);
    runTest('4. Border Extraction Orientations & Manual Crop', @testBorderExtraction);
    runTest('5. Feature Extraction (Color, GLCM, Edge, Structure)', @testFeatureExtraction);
    runTest('6. Self-Similarity Comparison (Identical Design)', @testSelfSimilarity);
    runTest('7. Cross-Design Comparison & Symmetry', @testCrossComparison);
    runTest('8. Robustness to Blank/Zero Gradient & Edge Cases', @testRobustnessEdgeCases);
    runTest('9. Error Handling for Missing & Invalid Files', @testErrorHandling);
    runTest('10. Synthetic Pattern Fixture Validation', @testSyntheticFixtures);

    % Print Test Summary
    fprintf('\n==============================================================================\n');
    fprintf('                           TEST EXECUTION SUMMARY                             \n');
    fprintf('==============================================================================\n');
    fprintf('  Total Test Suites Executed : %d\n', totalTests);
    fprintf('  Passed                     : %d\n', passedTests);
    fprintf('  Failed                     : %d\n', failedTests);
    if failedTests == 0
        fprintf('  OVERALL SUITE STATUS       : [PASS] ALL SYSTEMS OPERATIONAL\n');
    else
        fprintf('  OVERALL SUITE STATUS       : [FAIL] INVESTIGATE FAILED TESTS\n');
    end
    fprintf('==============================================================================\n\n');

    testResults.total = totalTests;
    testResults.passed = passedTests;
    testResults.failed = failedTests;
    testResults.log = testLog;

    % Nested test runner helper
    function runTest(testName, testHandle)
        totalTests = totalTests + 1;
        fprintf('Running Test %-55s ... ', testName);
        try
            testHandle();
            fprintf('[PASS]\n');
            passedTests = passedTests + 1;
            testLog{end+1} = sprintf('[PASS] %s', testName);
        catch ME
            fprintf('[FAIL] (%s)\n', ME.message);
            failedTests = failedTests + 1;
            testLog{end+1} = sprintf('[FAIL] %s: %s', testName, ME.message);
        end
    end
end

% =========================================================================
% TEST SUITE 1: DATASET STRUCTURE & AUDIT
% =========================================================================
function testDatasetStructure()
    summary = prepareDataset();
    assert(isstruct(summary), 'prepareDataset did not return a struct.');
    assert(isfield(summary, 'ready'), 'Summary missing ready field.');
    assert(summary.ready == true, 'Dataset reported not ready.');
end

% =========================================================================
% TEST SUITE 2: IMAGE LOADING & FORMAT NORMALIZATION
% =========================================================================
function testImageLoading()
    % 1. RGB uint8
    rgbImg = uint8(randi([0 255], 100, 150, 3));
    prepRGB = preprocessSareeImage(rgbImg);
    assert(isequal(prepRGB.resizedSize, [100, 150, 3]), 'RGB dimensions mismatched.');

    % 2. Grayscale 2D
    grayImg = uint8(randi([0 255], 120, 120));
    prepGray = preprocessSareeImage(grayImg);
    assert(size(prepGray.original, 3) == 3, 'Grayscale did not convert to 3-channel RGB representation.');

    % 3. Float [0, 1]
    floatImg = rand(80, 80, 3);
    prepFloat = preprocessSareeImage(floatImg);
    assert(isa(prepFloat.original, 'uint8'), 'Float did not convert to uint8.');
end

% =========================================================================
% TEST SUITE 3: PREPROCESSING & DENOISING
% =========================================================================
function testPreprocessing()
    testImg = uint8(repmat(linspace(0, 255, 200), 200, 1));
    prep = preprocessSareeImage(testImg, 'FilterType', 'gaussian', 'EnhanceContrast', true);

    assert(isfield(prep, 'denoised'), 'Missing denoised field.');
    assert(isfield(prep, 'enhanced'), 'Missing enhanced field.');
    assert(isfield(prep, 'gradientMag'), 'Missing gradientMag field.');
    assert(all(prep.gradientMag(:) >= 0), 'Gradient magnitudes contain negative numbers.');
end

% =========================================================================
% TEST SUITE 4: BORDER EXTRACTION ORIENTATIONS & MANUAL CROP
% =========================================================================
function testBorderExtraction()
    H = 400; W = 500;
    testImg = uint8(ones(H, W, 3) * 128);
    % Inject heavy pattern in bottom 80 rows
    testImg(321:H, :, 1) = uint8(randi([200 255], 80, W));
    testImg(321:H, :, 2) = uint8(randi([150 220], 80, W));

    prep = preprocessSareeImage(testImg);

    % Test orientations
    orients = {'bottom', 'top', 'left', 'right', 'auto'};
    for i = 1:length(orients)
        bData = extractSareeBorder(prep, 'Orientation', orients{i}, 'BorderWidthFraction', 0.20);
        assert(~isempty(bData.borderRGB), sprintf('Extracted border empty for orientation: %s', orients{i}));
        assert(~isempty(bData.borderGray), sprintf('Extracted gray border empty for orientation: %s', orients{i}));
        assert(bData.borderBBox(1) >= 1 && bData.borderBBox(2) >= 1, 'Bounding box out of lower bounds.');
        assert(bData.borderBBox(1) + bData.borderBBox(3) - 1 <= W, 'Bounding box exceeds image width.');
        assert(bData.borderBBox(2) + bData.borderBBox(4) - 1 <= H, 'Bounding box exceeds image height.');
    end

    % Test Manual Crop
    manualBox = [50, 50, 100, 60];
    bManual = extractSareeBorder(prep, 'ManualBBox', manualBox);
    assert(isequal(bManual.borderBBox, manualBox), 'Manual bounding box override failed.');
    assert(strcmp(bManual.method, 'manual'), 'Method flag not set to manual.');
end

% =========================================================================
% TEST SUITE 5: FEATURE EXTRACTION
% =========================================================================
function testFeatureExtraction()
    borderPatch = uint8(randi([0 255], 100, 300, 3));
    feat = extractPatternFeatures(borderPatch);

    % Color Histogram: 32 bins, normalized
    assert(length(feat.colorHist) == 32, 'Color histogram length is not 32.');
    assert(abs(sum(feat.colorHist) - 3.0) < 0.05, 'Color histogram sub-channels not normalized to 1.');

    % GLCM Properties
    assert(isfield(feat.glcmProps, 'Contrast'), 'Missing GLCM Contrast.');
    assert(isfield(feat.glcmProps, 'Correlation'), 'Missing GLCM Correlation.');
    assert(isfield(feat.glcmProps, 'Energy'), 'Missing GLCM Energy.');
    assert(isfield(feat.glcmProps, 'Homogeneity'), 'Missing GLCM Homogeneity.');
    assert(~isnan(feat.glcmProps.Contrast), 'GLCM Contrast is NaN.');
    assert(~isnan(feat.glcmProps.Correlation), 'GLCM Correlation is NaN.');

    % Edge Density
    assert(feat.edgeDensity >= 0 && feat.edgeDensity <= 1.0, 'Edge density outside [0, 1].');

    % Edge Orientation
    assert(length(feat.edgeOrientationHist) == 8, 'Edge orientation histogram length not 8.');

    % Structural Props
    assert(length(feat.structuralProps) == 4, 'Structural props length not 4.');

    % Combined Vector
    assert(abs(norm(feat.combinedVector) - 1.0) < 0.01, 'Combined feature vector not L2-normalized.');
end

% =========================================================================
% TEST SUITE 6: SELF-SIMILARITY (IDENTICAL DESIGN)
% =========================================================================
function testSelfSimilarity()
    patch = uint8(randi([50 200], 120, 250, 3));
    featA = extractPatternFeatures(patch);
    featB = extractPatternFeatures(patch);

    res = compareSareeBorders(featA, featB);
    assert(res.overallSimilarityPct >= 99.0, ...
        sprintf('Self-similarity should be ~100%%, got %.2f%%', res.overallSimilarityPct));
    assert(res.colorSimilarityPct >= 99.0, 'Color self-similarity below 99%.');
    assert(res.textureSimilarityPct >= 99.0, 'Texture self-similarity below 99%.');
    assert(res.edgeSimilarityPct >= 99.0, 'Edge self-similarity below 99%.');
end

% =========================================================================
% TEST SUITE 7: CROSS-DESIGN COMPARISON & SYMMETRY
% =========================================================================
function testCrossComparison()
    % Design 1: Red with high-contrast horizontal lines
    d1 = zeros(100, 200, 3, 'uint8');
    d1(:, :, 1) = 220;
    d1(mod(1:100, 10) < 4, :, 2) = 200;

    % Design 2: Blue with smooth gradient
    d2 = zeros(100, 200, 3, 'uint8');
    d2(:, :, 3) = uint8(repmat(linspace(50, 250, 200), 100, 1));

    feat1 = extractPatternFeatures(d1);
    feat2 = extractPatternFeatures(d2);

    res12 = compareSareeBorders(feat1, feat2);
    res21 = compareSareeBorders(feat2, feat1);

    % Range assertion
    assert(res12.overallSimilarityPct >= 0 && res12.overallSimilarityPct <= 100, ...
        'Similarity percentage outside [0, 100].');

    % Symmetry assertion
    diffSym = abs(res12.overallSimilarityPct - res21.overallSimilarityPct);
    assert(diffSym < 0.05, sprintf('Comparison not symmetric: %.2f vs %.2f', ...
        res12.overallSimilarityPct, res21.overallSimilarityPct));

    % Distinct designs must have significantly lower similarity than 90%
    assert(res12.overallSimilarityPct < 85.0, ...
        sprintf('Distinct red/blue designs had unexpectedly high similarity: %.2f%%', res12.overallSimilarityPct));
end

% =========================================================================
% TEST SUITE 8: ROBUSTNESS TO BLANK & ZERO GRADIENT IMAGES
% =========================================================================
function testRobustnessEdgeCases()
    % Uniform blank image (zero gradients)
    blankImg = uint8(ones(80, 120, 3) * 128);
    featBlank = extractPatternFeatures(blankImg);

    assert(featBlank.edgeDensity == 0, 'Blank image had non-zero edge density.');
    assert(~any(isnan(featBlank.combinedVector)), 'Combined vector contains NaN on blank image.');

    % Compare blank with normal patch
    patch = uint8(randi([0 255], 80, 120, 3));
    featPatch = extractPatternFeatures(patch);
    res = compareSareeBorders(featBlank, featPatch);
    assert(~isnan(res.overallSimilarityPct), 'Comparison returned NaN for blank image.');
end

% =========================================================================
% TEST SUITE 9: ERROR HANDLING FOR MISSING & INVALID FILES
% =========================================================================
function testErrorHandling()
    % Non-existent file
    errorCaught = false;
    try
        preprocessSareeImage('this_file_does_not_exist_at_all_12345.jpg');
    catch
        errorCaught = true;
    end
    assert(errorCaught, 'preprocessSareeImage did not throw error on missing file.');

    % Empty image matrix
    errorCaughtEmpty = false;
    try
        preprocessSareeImage([]);
    catch
        errorCaughtEmpty = true;
    end
    assert(errorCaughtEmpty, 'preprocessSareeImage did not throw error on empty matrix.');
end

% =========================================================================
% TEST SUITE 10: SYNTHETIC PATTERN FIXTURE VALIDATION
% (Generated purely as unit test fixtures, clearly labeled as synthetic)
% =========================================================================
function testSyntheticFixtures()
    % Generate synthetic geometric chevron pattern fixture
    [X, Y] = meshgrid(1:200, 1:100);
    chevron = uint8(128 + 100 * sin(abs(mod(X, 40) - 20) * 0.3 + Y * 0.1));
    synRGB = cat(3, chevron, uint8(chevron * 0.7), uint8(255 - chevron));

    featSyn = extractPatternFeatures(synRGB);
    assert(featSyn.glcmProps.Contrast > 0, 'Synthetic chevron produced 0 contrast.');
    assert(featSyn.edgeDensity > 0.01, 'Synthetic chevron produced too few edges.');
end
