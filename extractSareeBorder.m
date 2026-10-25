function borderData = extractSareeBorder(inputData, varargin)
% EXTRACTSAREEBORDER Detects, localizes, and extracts saree decorative border regions.
%
% Syntax:
%   borderData = extractSareeBorder(prep)
%   borderData = extractSareeBorder(imagePath, 'Orientation', 'bottom')
%   borderData = extractSareeBorder(prep, 'BorderWidthFraction', 0.25)
%   borderData = extractSareeBorder(prep, 'ManualBBox', [x, y, w, h])
%
% Inputs:
%   inputData            - Struct from preprocessSareeImage OR raw image/path.
%   Optional Name-Value Parameters:
%     'Orientation'         - 'auto' (default), 'bottom', 'top', 'left', 'right'.
%     'BorderWidthFraction' - Relative width fraction [0.08 to 0.45] (default: 0.22).
%     'ManualBBox'          - Custom bounding box [x, y, width, height] (overrides auto).
%     'SaveOutput'          - Boolean flag to save extracted border to disk (default: false).
%     'OutputDir'           - Output directory for saved images (default: 'output/extracted_borders').
%
% Outputs:
%   borderData - Struct containing:
%     .borderRGB         - Cropped color border image (uint8)
%     .borderGray        - Cropped grayscale border image (uint8)
%     .borderBBox        - Bounding box [x y w h] on resized image
%     .origBBox          - Bounding box [x y w h] on original full-res image
%     .annotatedImage    - Full image with marked border overlay
%     .orientation       - Final orientation used ('bottom', 'top', 'left', 'right')
%     .confidence        - Detection confidence score [0 to 1]
%     .method            - Extraction method ('auto', 'preset', 'manual')
%     .filePathSaved     - Saved file path if SaveOutput=true
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    % Input parsing
    p = inputParser;
    addParameter(p, 'Orientation', 'auto', @(x) ischar(x) && any(strcmpi(x, {'auto', 'bottom', 'top', 'left', 'right'})));
    addParameter(p, 'BorderWidthFraction', 0.22, @(x) isnumeric(x) && x >= 0.05 && x <= 0.50);
    addParameter(p, 'ManualBBox', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 4));
    addParameter(p, 'SaveOutput', false, @islogical);
    addParameter(p, 'OutputDir', '', @ischar);
    parse(p, varargin{:});

    orientReq = lower(p.Results.Orientation);
    widthFrac = p.Results.BorderWidthFraction;
    manualBBox = p.Results.ManualBBox;
    saveOutput = p.Results.SaveOutput;
    outputDir = p.Results.OutputDir;

    % 1. Ensure preprocessed struct
    if isstruct(inputData) && isfield(inputData, 'resized') && isfield(inputData, 'enhanced')
        prep = inputData;
    else
        prep = preprocessSareeImage(inputData);
    end

    [H, W, ~] = size(prep.resized);
    scale = prep.scaleFactor;

    % 2. Check for Manual Bounding Box Override
    if ~isempty(manualBBox)
        % Ensure manual bounding box is clamped to valid image boundaries
        bx = max(1, min(W - 2, round(manualBBox(1))));
        by = max(1, min(H - 2, round(manualBBox(2))));
        bw = max(5, min(W - bx + 1, round(manualBBox(3))));
        bh = max(5, min(H - by + 1, round(manualBBox(4))));
        borderBBox = [bx, by, bw, bh];
        finalOrient = 'custom';
        method = 'manual';
        confidence = 1.0;
    else
        % 3. Automated or Preset Margin Detection
        % Compute Canny edge map for texture & pattern density estimation
        if exist('edge', 'file')
            edgeMap = edge(prep.enhanced, 'Canny', [0.04 0.15]);
        else
            % Thresholded gradient magnitude fallback
            edgeMap = prep.gradientMag > (mean(prep.gradientMag(:)) + 0.5 * std(prep.gradientMag(:)));
        end

        % Measure high-frequency edge density and gradient energy along each margin
        marginH = max(10, round(H * widthFrac));
        marginW = max(10, round(W * widthFrac));

        scores.bottom = computeMarginEnergy(edgeMap, prep.gradientMag, [H - marginH + 1, H, 1, W]);
        scores.top    = computeMarginEnergy(edgeMap, prep.gradientMag, [1, marginH, 1, W]);
        scores.left   = computeMarginEnergy(edgeMap, prep.gradientMag, [1, H, 1, marginW]);
        scores.right  = computeMarginEnergy(edgeMap, prep.gradientMag, [1, H, W - marginW + 1, W]);

        % Body central reference energy (typically plainer cloth)
        centerBody = [round(H * 0.3), round(H * 0.7), round(W * 0.3), round(W * 0.7)];
        bodyEnergy = computeMarginEnergy(edgeMap, prep.gradientMag, centerBody);

        if strcmp(orientReq, 'auto')
            % Select orientation with highest pattern energy
            [maxScore, bestOrient] = findBestOrientation(scores);
            finalOrient = bestOrient;
            method = 'auto';
            if bodyEnergy > 0
                confidence = min(1.0, maxScore / (bodyEnergy * 1.8 + eps));
            else
                confidence = 0.85;
            end
        else
            finalOrient = orientReq;
            method = 'preset';
            confidence = 0.90;
        end

        % Refine localized bounding box along chosen orientation
        borderBBox = computeLocalizedBBox(finalOrient, H, W, widthFrac, edgeMap);
    end

    % 4. Crop Border Region
    bx = borderBBox(1); by = borderBBox(2); bw = borderBBox(3); bh = borderBBox(4);
    borderRGB = prep.resized(by:(by + bh - 1), bx:(bx + bw - 1), :);
    borderGray = prep.gray(by:(by + bh - 1), bx:(bx + bw - 1));

    % Map to original full-resolution image coordinates
    origBX = max(1, round(bx / scale));
    origBY = max(1, round(by / scale));
    origBW = min(prep.origSize(2) - origBX + 1, round(bw / scale));
    origBH = min(prep.origSize(1) - origBY + 1, round(bh / scale));
    origBBox = [origBX, origBY, origBW, origBH];

    % 5. Create Visual Annotation Overlay
    annotated = prep.original;
    annotated = drawBoundingBoxOverlay(annotated, origBBox, finalOrient, confidence);

    % 6. Save outputs if requested
    savedPath = '';
    if saveOutput
        if isempty(outputDir)
            scriptDir = fileparts(mfilename('fullpath'));
            outputDir = fullfile(scriptDir, 'output', 'extracted_borders');
        end
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        savedPath = fullfile(outputDir, sprintf('border_%s_%s.png', finalOrient, timestamp));
        imwrite(borderRGB, savedPath);
    end

    % Package results
    borderData.borderRGB = borderRGB;
    borderData.borderGray = borderGray;
    borderData.borderBBox = borderBBox;
    borderData.origBBox = origBBox;
    borderData.annotatedImage = annotated;
    borderData.orientation = finalOrient;
    borderData.confidence = round(confidence, 3);
    borderData.method = method;
    borderData.filePathSaved = savedPath;
end

% -------------------------------------------------------------------------
% Helper: Calculate pattern and edge energy within bounding zone [r1 r2 c1 c2]
% -------------------------------------------------------------------------
function energy = computeMarginEnergy(edgeMap, gradMag, box)
    r1 = max(1, box(1)); r2 = min(size(edgeMap, 1), box(2));
    c1 = max(1, box(3)); c2 = min(size(edgeMap, 2), box(4));

    subEdges = edgeMap(r1:r2, c1:c2);
    subGrad  = gradMag(r1:r2, c1:c2);

    edgeDensity = sum(subEdges(:)) / numel(subEdges);
    meanGrad = mean(subGrad(:));

    % Weighted combination of edge density and gradient variance
    energy = 0.65 * edgeDensity * 100 + 0.35 * (meanGrad / 255 * 100);
end

% -------------------------------------------------------------------------
% Helper: Find orientation with highest pattern energy
% -------------------------------------------------------------------------
function [maxScore, bestOrient] = findBestOrientation(scores)
    orients = {'bottom', 'top', 'left', 'right'};
    vals = [scores.bottom, scores.top, scores.left, scores.right];
    % Saree borders are conventionally on bottom or top in standard catalog photos,
    % so slight prior weight is applied to bottom margin
    vals(1) = vals(1) * 1.15;

    [maxScore, maxIdx] = max(vals);
    bestOrient = orients{maxIdx};
end

% -------------------------------------------------------------------------
% Helper: Refines exact border bounding box using edge projection profile
% -------------------------------------------------------------------------
function bbox = computeLocalizedBBox(orient, H, W, widthFrac, edgeMap)
    switch orient
        case 'bottom'
            defaultH = max(15, round(H * widthFrac));
            % Scan row edge profile from bottom upwards to find border transition
            startRow = H - round(H * min(0.40, widthFrac * 1.5)) + 1;
            rowDensity = mean(edgeMap(startRow:H, :), 2);
            % Find cutoff where edge density dips below 60% of max border density
            threshold = 0.5 * max(rowDensity);
            denseIdx = find(rowDensity > threshold, 1, 'first');
            if ~isempty(denseIdx)
                detectedH = (H - startRow + 1) - denseIdx + 1;
                finalH = max(round(H * 0.12), min(round(H * 0.40), detectedH));
            else
                finalH = defaultH;
            end
            bbox = [1, H - finalH + 1, W, finalH];

        case 'top'
            defaultH = max(15, round(H * widthFrac));
            scanH = round(H * min(0.40, widthFrac * 1.5));
            rowDensity = mean(edgeMap(1:scanH, :), 2);
            threshold = 0.5 * max(rowDensity);
            denseIdx = find(rowDensity > threshold, 1, 'last');
            if ~isempty(denseIdx)
                finalH = max(round(H * 0.12), min(round(H * 0.40), denseIdx));
            else
                finalH = defaultH;
            end
            bbox = [1, 1, W, finalH];

        case 'left'
            defaultW = max(15, round(W * widthFrac));
            scanW = round(W * min(0.40, widthFrac * 1.5));
            colDensity = mean(edgeMap(:, 1:scanW), 1);
            threshold = 0.5 * max(colDensity);
            denseIdx = find(colDensity > threshold, 1, 'last');
            if ~isempty(denseIdx)
                finalW = max(round(W * 0.12), min(round(W * 0.40), denseIdx));
            else
                finalW = defaultW;
            end
            bbox = [1, 1, finalW, H];

        case 'right'
            defaultW = max(15, round(W * widthFrac));
            startCol = W - round(W * min(0.40, widthFrac * 1.5)) + 1;
            colDensity = mean(edgeMap(:, startCol:W), 1);
            threshold = 0.5 * max(colDensity);
            denseIdx = find(colDensity > threshold, 1, 'first');
            if ~isempty(denseIdx)
                detectedW = (W - startCol + 1) - denseIdx + 1;
                finalW = max(round(W * 0.12), min(round(W * 0.40), detectedW));
            else
                finalW = defaultW;
            end
            bbox = [W - finalW + 1, 1, finalW, H];

        otherwise
            bbox = [1, H - round(H * widthFrac) + 1, W, round(H * widthFrac)];
    end
end

% -------------------------------------------------------------------------
% Helper: Overlay bright bounding box onto color image
% -------------------------------------------------------------------------
function annotated = drawBoundingBoxOverlay(img, bbox, orientStr, conf)
    annotated = img;
    [H, W, ~] = size(img);
    bx = max(1, min(W - 2, bbox(1)));
    by = max(1, min(H - 2, bbox(2)));
    bw = max(2, min(W - bx + 1, bbox(3)));
    bh = max(2, min(H - by + 1, bbox(4)));

    thickness = max(2, round(min(H, W) * 0.006));

    % Draw bright neon green bounding box
    colorRGB = [0, 255, 60]; % Bright green

    % Top border
    y1 = by; y2 = min(H, by + thickness);
    x1 = bx; x2 = min(W, bx + bw);
    annotated = stampColor(annotated, y1, y2, x1, x2, colorRGB);

    % Bottom border
    y1 = max(1, by + bh - thickness); y2 = min(H, by + bh);
    annotated = stampColor(annotated, y1, y2, x1, x2, colorRGB);

    % Left border
    y1 = by; y2 = min(H, by + bh);
    x1 = bx; x2 = min(W, bx + thickness);
    annotated = stampColor(annotated, y1, y2, x1, x2, colorRGB);

    % Right border
    x1 = max(1, bx + bw - thickness); x2 = min(W, bx + bw);
    annotated = stampColor(annotated, y1, y2, x1, x2, colorRGB);
end

function img = stampColor(img, y1, y2, x1, x2, rgb)
    for c = 1:3
        channel = img(:, :, c);
        channel(y1:y2, x1:x2) = rgb(c);
        img(:, :, c) = channel;
    end
end
