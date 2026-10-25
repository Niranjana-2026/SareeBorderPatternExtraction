function features = extractPatternFeatures(borderImage, varargin)
% EXTRACTPATTERNFEATURES Extracts quantitative color, texture, edge, and structural descriptors.
%
% Syntax:
%   features = extractPatternFeatures(borderImage)
%   features = extractPatternFeatures(borderImage, 'ColorBins', [16 8 8])
%
% Inputs:
%   borderImage - Extracted border RGB or Grayscale image (uint8 or double).
%   Optional Name-Value Parameters:
%     'ColorBins'      - Bins for HSV channels [H S V] (default: [16 8 8]).
%     'NumLevels'      - Quantization levels for GLCM (default: 16).
%     'NumEdgeBins'    - Bins for edge orientation histogram (default: 8).
%
% Outputs:
%   features - Struct containing:
%     .colorHist           - 32-D normalized HSV color histogram
%     .glcmProps           - Haralick texture features (Contrast, Correlation, Energy, Homogeneity)
%     .glcmVector          - Normalized 4-D GLCM vector
%     .edgeDensity         - Scalar edge density [0, 1]
%     .edgeOrientationHist - 8-D normalized gradient direction histogram
%     .structuralProps     - 4-D statistical descriptors [mean, std, entropy, solidity]
%     .combinedVector      - Unified L2-normalized 49-D feature vector
%     .summary             - Human-readable feature summary string
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    % Input validation
    p = inputParser;
    addParameter(p, 'ColorBins', [16, 8, 8], @(x) isnumeric(x) && numel(x) == 3);
    addParameter(p, 'NumLevels', 16, @(x) isnumeric(x) && x >= 4 && x <= 64);
    addParameter(p, 'NumEdgeBins', 8, @(x) isnumeric(x) && x >= 4);
    parse(p, varargin{:});

    colorBins = p.Results.ColorBins;
    numLevels = p.Results.NumLevels;
    numEdgeBins = p.Results.NumEdgeBins;

    if isempty(borderImage)
        error('PatternFeatures:EmptyInput', 'Input border image cannot be empty.');
    end

    % Standardize image format to uint8 RGB
    if isfloat(borderImage)
        if max(borderImage(:)) <= 1.0
            borderImage = uint8(borderImage * 255);
        else
            borderImage = uint8(borderImage);
        end
    end

    [H, W, C] = size(borderImage);
    if C == 1
        rgbImg = cat(3, borderImage, borderImage, borderImage);
        grayImg = borderImage;
    elseif C >= 3
        rgbImg = borderImage(:, :, 1:3);
        grayImg = rgb2gray(rgbImg);
    end

    totalPixels = max(1, H * W);

    % =========================================================================
    % 1. COLOR HISTOGRAM EXTRACTION (HSV Space)
    % =========================================================================
    hsvImg = rgb2hsv(rgbImg);
    hChannel = hsvImg(:, :, 1);
    sChannel = hsvImg(:, :, 2);
    vChannel = hsvImg(:, :, 3);

    % Quantize channels
    hHist = histcounts(hChannel(:), linspace(0, 1, colorBins(1) + 1));
    sHist = histcounts(sChannel(:), linspace(0, 1, colorBins(2) + 1));
    vHist = histcounts(vChannel(:), linspace(0, 1, colorBins(3) + 1));

    % Normalize each sub-histogram so sum is 1.0
    hHist = hHist / (sum(hHist) + eps);
    sHist = sHist / (sum(sHist) + eps);
    vHist = vHist / (sum(vHist) + eps);

    colorHist = [hHist, sHist, vHist]; % 32-D color descriptor

    % =========================================================================
    % 2. TEXTURE ANALYSIS (GLCM - Gray-Level Co-occurrence Matrix)
    % =========================================================================
    % Haralick texture features measured at 0, 45, 90, 135 degrees
    offsets = [0 1; -1 1; -1 0; -1 -1];
    if exist('graycomatrix', 'file')
        glcm = graycomatrix(grayImg, 'Offset', offsets, 'NumLevels', numLevels, 'Symmetric', true);
        stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

        contrastVal    = mean(stats.Contrast);
        correlationVal = mean(stats.Correlation);
        energyVal      = mean(stats.Energy);
        homogeneityVal = mean(stats.Homogeneity);
    else
        % Fallback local intensity spatial variation if toolbox missing
        diffH = abs(diff(double(grayImg), 1, 2));
        diffV = abs(diff(double(grayImg), 1, 1));
        contrastVal = (mean(diffH(:)) + mean(diffV(:))) / 2;
        correlationVal = 0.5;
        energyVal = 1 / (std(double(grayImg(:))) + 1);
        homogeneityVal = 1 / (1 + contrastVal / 255);
    end

    % Safe NaN check
    if isnan(correlationVal), correlationVal = 0.0; end
    if isnan(contrastVal), contrastVal = 0.0; end
    if isnan(energyVal), energyVal = 0.0; end
    if isnan(homogeneityVal), homogeneityVal = 0.0; end

    glcmProps.Contrast    = contrastVal;
    glcmProps.Correlation = correlationVal;
    glcmProps.Energy      = energyVal;
    glcmProps.Homogeneity = homogeneityVal;

    % Normalize GLCM components for vector distance calculation
    % Typical max values: Contrast ~ (numLevels-1)^2, Correlation [-1, 1], Energy [0, 1], Homogeneity [0, 1]
    normContrast    = min(1.0, contrastVal / ((numLevels - 1)^2 + eps));
    normCorrelation = (correlationVal + 1.0) / 2.0; % Map [-1, 1] -> [0, 1]
    normEnergy      = min(1.0, max(0.0, energyVal));
    normHomogeneity = min(1.0, max(0.0, homogeneityVal));
    glcmVector = [normContrast, normCorrelation, normEnergy, normHomogeneity];

    % =========================================================================
    % 3. EDGE DENSITY & ORIENTATION HISTOGRAM
    % =========================================================================
    if exist('edge', 'file')
        edgeBinary = edge(grayImg, 'Canny', [0.05 0.18]);
    else
        edgeBinary = imgradient(grayImg) > 40;
    end
    edgeDensity = sum(edgeBinary(:)) / totalPixels;

    % Gradient angles using Sobel filters
    hy = fspecial('sobel');
    hx = hy';
    Gx = imfilter(double(grayImg), hx, 'replicate');
    Gy = imfilter(double(grayImg), hy, 'replicate');
    gradMag = sqrt(Gx.^2 + Gy.^2);
    gradDir = atan2d(Gy, Gx); % [-180, 180]
    gradDir(gradDir < 0) = gradDir(gradDir < 0) + 180; % Map to [0, 180)

    % Only include angles of significant edge pixels
    edgeMask = edgeBinary | (gradMag > (mean(gradMag(:)) + 0.5 * std(gradMag(:))));
    edgeAngles = gradDir(edgeMask);

    if isempty(edgeAngles)
        edgeOrientHist = ones(1, numEdgeBins) / numEdgeBins;
    else
        edgeOrientHist = histcounts(edgeAngles, linspace(0, 180, numEdgeBins + 1));
        edgeOrientHist = edgeOrientHist / (sum(edgeOrientHist) + eps);
    end

    % =========================================================================
    % 4. STRUCTURAL & STATISTICAL MOTIF DESCRIPTORS
    % =========================================================================
    meanIntensity = mean(double(grayImg(:))) / 255;
    stdIntensity  = std(double(grayImg(:))) / 255;

    % Pattern Entropy
    if exist('entropy', 'file')
        patEntropy = entropy(grayImg) / 8.0; % Normalize 8-bit entropy [0, 8] -> [0, 1]
    else
        pCounts = histcounts(grayImg(:), 0:256) / totalPixels;
        pCounts = pCounts(pCounts > 0);
        patEntropy = -sum(pCounts .* log2(pCounts)) / 8.0;
    end

    % Motif Solidity & Density
    motifBinary = edgeBinary;
    if exist('imclose', 'file') && exist('strel', 'file')
        motifBinary = imclose(motifBinary, strel('disk', 2));
    end
    if exist('regionprops', 'file')
        regStats = regionprops(motifBinary, 'Solidity', 'Area');
        if ~isempty(regStats)
            solidityMean = mean([regStats.Solidity]);
            if isnan(solidityMean), solidityMean = 0.5; end
        else
            solidityMean = 0.5;
        end
    else
        solidityMean = 0.5;
    end

    structuralProps = [meanIntensity, stdIntensity, patEntropy, solidityMean];

    % =========================================================================
    % 5. UNIFIED NORMALIZED FEATURE VECTOR (49-D)
    % =========================================================================
    rawVector = [colorHist, glcmVector, edgeDensity, edgeOrientHist, structuralProps];
    l2Norm = norm(rawVector);
    if l2Norm > 0
        combinedVector = rawVector / l2Norm;
    else
        combinedVector = rawVector;
    end

    % Package structured features
    features.colorHist           = colorHist;
    features.glcmProps           = glcmProps;
    features.glcmVector          = glcmVector;
    features.edgeDensity         = edgeDensity;
    features.edgeOrientationHist = edgeOrientHist;
    features.structuralProps     = structuralProps;
    features.combinedVector      = combinedVector;
    features.dimensions          = length(combinedVector);
    features.imageSize           = [H, W];

    % Summary string
    features.summary = sprintf(['Color Bins: %d | Texture (Contrast=%.2f, Energy=%.2f, Homog=%.2f) | ' ...
                                'Edge Density: %.3f | Entropy: %.2f'], ...
                                length(colorHist), glcmProps.Contrast, glcmProps.Energy, ...
                                glcmProps.Homogeneity, edgeDensity, patEntropy);
end
