function prep = preprocessSareeImage(inputImage, varargin)
% PREPROCESSSAREEIMAGE Validates, normalizes, denoises, and enhances saree image.
%
% Syntax:
%   prep = preprocessSareeImage(imagePath)
%   prep = preprocessSareeImage(imageMatrix)
%   prep = preprocessSareeImage(..., 'MaxDimension', 800, 'EnhanceContrast', true)
%
% Inputs:
%   inputImage      - Absolute/relative file path OR RGB/Grayscale numeric matrix.
%   Optional Parameters (Name-Value):
%     'MaxDimension'    - Maximum dimension for standard processing (default: 800).
%     'FilterType'      - Denoising filter: 'gaussian' (default) or 'median'.
%     'EnhanceContrast' - Contrast enhancement flag: true (default) or false.
%
% Outputs:
%   prep - Struct containing:
%     .original     - Original unresized RGB image (uint8)
%     .resized      - Normalized RGB image (uint8)
%     .gray         - Grayscale converted image (uint8)
%     .denoised     - Filtered grayscale image (uint8)
%     .enhanced     - Contrast-normalized grayscale image (uint8)
%     .gradientMag  - Gradient magnitude matrix (double)
%     .gradientDir  - Gradient direction matrix in degrees [-180, 180]
%     .scaleFactor  - Scaling ratio applied to the original
%     .origSize     - Dimensions of the input image [H, W, C]
%     .resizedSize  - Dimensions of the resized image [H, W, C]
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    % Input parsing
    p = inputParser;
    addParameter(p, 'MaxDimension', 800, @(x) isnumeric(x) && x > 50);
    addParameter(p, 'FilterType', 'gaussian', @(x) ischar(x) && any(strcmpi(x, {'gaussian', 'median'})));
    addParameter(p, 'EnhanceContrast', true, @islogical);
    parse(p, varargin{:});

    maxDim = p.Results.MaxDimension;
    filterType = lower(p.Results.FilterType);
    enhanceContrast = p.Results.EnhanceContrast;

    % 1. Load and Validate Image
    if ischar(inputImage) || isstring(inputImage)
        imagePath = char(inputImage);
        if ~exist(imagePath, 'file')
            error('SareePreprocess:FileNotFound', 'Input image file not found: %s', imagePath);
        end
        try
            rawImg = imread(imagePath);
        catch ME
            error('SareePreprocess:ReadFailed', 'Failed to read image "%s": %s', imagePath, ME.message);
        end
    elseif isnumeric(inputImage) || islogical(inputImage)
        rawImg = inputImage;
    else
        error('SareePreprocess:InvalidInput', 'Input must be a file path string or an image matrix.');
    end

    if isempty(rawImg)
        error('SareePreprocess:EmptyImage', 'The input image is empty.');
    end

    % Convert to uint8 if floating point
    if isfloat(rawImg)
        if max(rawImg(:)) <= 1.0
            rawImg = uint8(rawImg * 255);
        else
            rawImg = uint8(rawImg);
        end
    end

    % 2. Ensure 3-Channel RGB
    [origH, origW, origC] = size(rawImg);
    if origC == 1
        % Grayscale to 3-channel duplicate
        origRGB = cat(3, rawImg, rawImg, rawImg);
    elseif origC == 4
        % Drop alpha channel if present
        origRGB = rawImg(:, :, 1:3);
    else
        origRGB = rawImg;
    end

    % 3. Resize for consistent and efficient processing
    scaleFactor = 1.0;
    maxOriginalDim = max(origH, origW);
    if maxOriginalDim > maxDim
        scaleFactor = maxDim / maxOriginalDim;
        resizedRGB = imresize(origRGB, scaleFactor, 'bilinear');
    else
        resizedRGB = origRGB;
    end
    [resH, resW, ~] = size(resizedRGB);

    % 4. Grayscale Conversion
    grayImg = rgb2gray(resizedRGB);

    % 5. Denoising
    switch filterType
        case 'gaussian'
            % Gaussian filter (sigma = 1.0, 5x5 window)
            if exist('imgaussfilt', 'file')
                denoised = imgaussfilt(grayImg, 1.0);
            else
                h = fspecial('gaussian', [5 5], 1.0);
                denoised = imfilter(grayImg, h, 'replicate');
            end
        case 'median'
            % 3x3 median filter for salt-and-pepper / textile grain noise
            if exist('medfilt2', 'file')
                denoised = medfilt2(grayImg, [3 3]);
            else
                denoised = grayImg;
            end
    end

    % 6. Contrast Normalization / Enhancement
    if enhanceContrast
        % Use adaptive histogram equalization if available, else imadjust
        if exist('adapthisteq', 'file')
            enhanced = adapthisteq(denoised, 'ClipLimit', 0.02, 'Distribution', 'rayleigh');
        else
            enhanced = imadjust(denoised);
        end
    else
        enhanced = denoised;
    end

    % 7. Gradient Magnitude & Direction Computation
    if exist('imgradient', 'file')
        [Gmag, Gdir] = imgradient(enhanced, 'sobel');
    else
        % Sobel fallback
        hy = fspecial('sobel');
        hx = hy';
        Gx = imfilter(double(enhanced), hx, 'replicate');
        Gy = imfilter(double(enhanced), hy, 'replicate');
        Gmag = sqrt(Gx.^2 + Gy.^2);
        Gdir = atan2d(Gy, Gx);
    end

    % Package results
    prep.original = origRGB;
    prep.resized = resizedRGB;
    prep.gray = grayImg;
    prep.denoised = denoised;
    prep.enhanced = enhanced;
    prep.gradientMag = Gmag;
    prep.gradientDir = Gdir;
    prep.scaleFactor = scaleFactor;
    prep.origSize = [origH, origW, origC];
    prep.resizedSize = [resH, resW, 3];
end
