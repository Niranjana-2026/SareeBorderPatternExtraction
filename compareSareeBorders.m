function result = compareSareeBorders(input1, input2, varargin)
% COMPARESAREEBORDERS Compares two saree border designs using quantitative multi-feature analysis.
%
% Syntax:
%   result = compareSareeBorders(feat1, feat2)
%   result = compareSareeBorders(borderImg1, borderImg2)
%   result = compareSareeBorders(sareeImg1, sareeImg2)
%   result = compareSareeBorders(..., 'Weights', [0.35 0.30 0.20 0.15])
%
% Inputs:
%   input1, input2 - Feature structs (from extractPatternFeatures),
%                    OR cropped border images,
%                    OR file paths / raw saree images.
%   Optional Name-Value Parameters:
%     'Weights'     - Feature component weights [Color, Texture, Edge, Structural]
%                     (default: [0.35, 0.30, 0.20, 0.15], automatically normalized).
%     'SaveReport'  - Boolean flag to save comparison text report (default: false).
%     'OutputDir'   - Directory where report is saved (default: 'output/reports').
%
% Outputs:
%   result - Struct containing:
%     .overallSimilarityPct  - Overall similarity percentage [0.00% to 100.00%]
%     .colorSimilarityPct    - HSV color histogram similarity percentage
%     .textureSimilarityPct  - GLCM texture similarity percentage
%     .edgeSimilarityPct     - Edge density & orientation similarity percentage
%     .structuralSimilarityPct - Statistical & motif similarity percentage
%     .interpretation        - Qualitative assessment string
%     .weightsUsed           - Weights applied to each component
%     .features1             - Extracted features for Border 1
%     .features2             - Extracted features for Border 2
%     .reportText            - Full human-readable comparison report
%     .reportFilePath        - Path to saved report file if SaveReport=true
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    % Input parsing
    p = inputParser;
    addParameter(p, 'Weights', [0.35, 0.30, 0.20, 0.15], @(x) isnumeric(x) && numel(x) == 4);
    addParameter(p, 'SaveReport', false, @islogical);
    addParameter(p, 'OutputDir', '', @ischar);
    parse(p, varargin{:});

    rawWeights = p.Results.Weights;
    saveReport = p.Results.SaveReport;
    outputDir = p.Results.OutputDir;

    % Normalize weights so they sum to 1.0
    w = rawWeights / sum(rawWeights);

    % 1. Resolve Input 1 Features
    feat1 = resolveFeatures(input1);
    feat2 = resolveFeatures(input2);

    % =========================================================================
    % 2. MULTI-DESCRIPTOR SIMILARITY METRICS
    % =========================================================================

    % A. Color Similarity (HSV Histogram Intersection)
    % S_color = sum(min(h1_i, h2_i)) / sum(h1_i)
    colorIntersection = sum(min(feat1.colorHist, feat2.colorHist)) / (sum(feat1.colorHist) / 3 + eps);
    % Normalized across 3 channels (H, S, V)
    sColor = max(0.0, min(1.0, colorIntersection / 3.0));

    % B. Texture Similarity (GLCM Haralick Distance)
    % Exponential decay over normalized Euclidean distance of GLCM properties
    diffGLCM = norm(feat1.glcmVector - feat2.glcmVector);
    sTexture = max(0.0, min(1.0, exp(-2.2 * diffGLCM)));

    % C. Edge & Directionality Similarity
    % 1. Edge density match
    d1 = feat1.edgeDensity; d2 = feat2.edgeDensity;
    maxD = max(d1, d2);
    if maxD > 0
        edgeDensitySim = 1.0 - (abs(d1 - d2) / maxD);
    else
        edgeDensitySim = 1.0;
    end
    edgeDensitySim = max(0.0, min(1.0, edgeDensitySim));

    % 2. Edge orientation histogram intersection
    edgeOrientSim = sum(min(feat1.edgeOrientationHist, feat2.edgeOrientationHist));
    edgeOrientSim = max(0.0, min(1.0, edgeOrientSim));

    sEdge = 0.5 * edgeDensitySim + 0.5 * edgeOrientSim;

    % D. Structural & Motif Statistical Similarity
    % Cosine similarity between structural descriptor vectors
    s1 = feat1.structuralProps;
    s2 = feat2.structuralProps;
    dotProd = dot(s1, s2);
    normProd = norm(s1) * norm(s2) + eps;
    sStructural = max(0.0, min(1.0, dotProd / normProd));

    % =========================================================================
    % 3. COMPOSITE WEIGHTED SIMILARITY SCORE
    % =========================================================================
    compositeScore = (w(1) * sColor) + (w(2) * sTexture) + (w(3) * sEdge) + (w(4) * sStructural);
    overallPct = round(max(0.0, min(100.0, compositeScore * 100)), 2);

    colorPct      = round(sColor * 100, 2);
    texturePct    = round(sTexture * 100, 2);
    edgePct       = round(sEdge * 100, 2);
    structuralPct = round(sStructural * 100, 2);

    % =========================================================================
    % 4. QUALITATIVE INTERPRETATION
    % =========================================================================
    if overallPct >= 90.0
        qualitativeStr = 'Extremely High Similarity (Near-Identical Border Pattern & Palette)';
    elseif overallPct >= 75.0
        qualitativeStr = 'High Similarity (Closely Related Motif, Weave Texture & Palette)';
    elseif overallPct >= 55.0
        qualitativeStr = 'Moderate Similarity (Shared Texture or Palette Characteristics)';
    elseif overallPct >= 35.0
        qualitativeStr = 'Low Similarity (Noticeable Differences in Motif and Color)';
    else
        qualitativeStr = 'Very Low / Dissimilar Border Designs';
    end

    % =========================================================================
    % 5. GENERATE COMPREHENSIVE TEXT REPORT
    % =========================================================================
    reportLines = {};
    reportLines{end+1} = '==============================================================================';
    reportLines{end+1} = '       SAREE BORDER PATTERN SIMILARITY COMPARISON REPORT                      ';
    reportLines{end+1} = '==============================================================================';
    reportLines{end+1} = sprintf('Generated At          : %s', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    reportLines{end+1} = sprintf('Overall Similarity    : %.2f%%', overallPct);
    reportLines{end+1} = sprintf('Qualitative Assessment: %s', qualitativeStr);
    reportLines{end+1} = '------------------------------------------------------------------------------';
    reportLines{end+1} = 'DETAILED FEATURE METRIC BREAKDOWN:';
    reportLines{end+1} = sprintf('  1. Color Palette Similarity (HSV Hist)   : %6.2f%%  [Weight: %.2f]', colorPct, w(1));
    reportLines{end+1} = sprintf('  2. Textile Texture Similarity (GLCM)     : %6.2f%%  [Weight: %.2f]', texturePct, w(2));
    reportLines{end+1} = sprintf('  3. Edge & Motif Directionality           : %6.2f%%  [Weight: %.2f]', edgePct, w(3));
    reportLines{end+1} = sprintf('  4. Structural & Entropy Descriptors      : %6.2f%%  [Weight: %.2f]', structuralPct, w(4));
    reportLines{end+1} = '------------------------------------------------------------------------------';
    reportLines{end+1} = 'INDIVIDUAL BORDER FEATURE COMPARISONS:';
    reportLines{end+1} = sprintf('  Border 1 GLCM Texture : Contrast=%.2f, Correlation=%.2f, Energy=%.3f, Homogeneity=%.3f', ...
        feat1.glcmProps.Contrast, feat1.glcmProps.Correlation, feat1.glcmProps.Energy, feat1.glcmProps.Homogeneity);
    reportLines{end+1} = sprintf('  Border 2 GLCM Texture : Contrast=%.2f, Correlation=%.2f, Energy=%.3f, Homogeneity=%.3f', ...
        feat2.glcmProps.Contrast, feat2.glcmProps.Correlation, feat2.glcmProps.Energy, feat2.glcmProps.Homogeneity);
    reportLines{end+1} = sprintf('  Border 1 Edge Density : %.4f (Border 2: %.4f)', feat1.edgeDensity, feat2.edgeDensity);
    reportLines{end+1} = '------------------------------------------------------------------------------';
    reportLines{end+1} = 'ACADEMIC & LEGAL DISCLAIMER:';
    reportLines{end+1} = '  A high similarity score indicates high mathematical correlation between visual';
    reportLines{end+1} = '  color, texture, and edge features extracted by the system. It does not certify';
    reportLines{end+1} = '  trademark identity, weaver origin, or commercial authenticity.';
    reportLines{end+1} = '==============================================================================';

    fullReportText = strjoin(reportLines, '\n');

    % Save report if requested
    savedReportPath = '';
    if saveReport
        if isempty(outputDir)
            scriptDir = fileparts(mfilename('fullpath'));
            outputDir = fullfile(scriptDir, 'output', 'reports');
        end
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        savedReportPath = fullfile(outputDir, sprintf('similarity_report_%s.txt', timestamp));
        fid = fopen(savedReportPath, 'w');
        if fid ~= -1
            fprintf(fid, '%s\n', fullReportText);
            fclose(fid);
        end
    end

    % Return structured result
    result.overallSimilarityPct    = overallPct;
    result.colorSimilarityPct      = colorPct;
    result.textureSimilarityPct    = texturePct;
    result.edgeSimilarityPct       = edgePct;
    result.structuralSimilarityPct = structuralPct;
    result.interpretation          = qualitativeStr;
    result.weightsUsed             = w;
    result.features1               = feat1;
    result.features2               = feat2;
    result.reportText              = fullReportText;
    result.reportFilePath          = savedReportPath;
end

% -------------------------------------------------------------------------
% Helper: Automatically extracts features regardless of input type
% -------------------------------------------------------------------------
function feat = resolveFeatures(inputItem)
    if isstruct(inputItem) && isfield(inputItem, 'combinedVector')
        % Already a feature struct
        feat = inputItem;
    elseif isstruct(inputItem) && isfield(inputItem, 'borderRGB')
        % Border data struct from extractSareeBorder
        feat = extractPatternFeatures(inputItem.borderRGB);
    elseif isstruct(inputItem) && isfield(inputItem, 'resized')
        % Preprocessed struct -> extract border first
        bData = extractSareeBorder(inputItem);
        feat = extractPatternFeatures(bData.borderRGB);
    else
        % Raw file path or image matrix
        prep = preprocessSareeImage(inputItem);
        bData = extractSareeBorder(prep);
        feat = extractPatternFeatures(bData.borderRGB);
    end
end
