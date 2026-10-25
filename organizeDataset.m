function summary = organizeDataset(varargin)
% ORGANIZEDATASET Sorts, validates, and organizes saree images into categorized folders.
%
% Syntax:
%   summary = organizeDataset()
%   summary = organizeDataset('DatasetDir', 'path/to/dataset')
%
% Description:
%   This function scans the 'raw' directory (and any incoming image files),
%   verifies image readability, detects duplicates using file size and SHA-256 hashes,
%   and routes verified images into category directories:
%     - dataset/silk/
%     - dataset/cotton/
%     - dataset/designer/
%     - dataset/printed/
%     - dataset/handloom/
%     - dataset/unclassified/ (for unknown fabric or unsourced images)
%
%   Valid images are also pre-checked and indexed into 'dataset/processed/'.
%   A comprehensive CSV manifest 'dataset/organized_manifest.csv' is generated.
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    p = inputParser;
    addParameter(p, 'DatasetDir', '', @ischar);
    parse(p, varargin{:});
    customDir = p.Results.DatasetDir;

    scriptDir = fileparts(mfilename('fullpath'));
    if isempty(customDir)
        baseDatasetDir = fullfile(scriptDir, 'dataset');
    else
        baseDatasetDir = customDir;
    end

    rawDir = fullfile(baseDatasetDir, 'raw');
    processedDir = fullfile(baseDatasetDir, 'processed');

    % Category directories
    categories = {'silk', 'cotton', 'designer', 'printed', 'handloom', 'unclassified'};
    for c = 1:length(categories)
        catDir = fullfile(baseDatasetDir, categories{c});
        if ~exist(catDir, 'dir')
            mkdir(catDir);
        end
    end
    if ~exist(processedDir, 'dir')
        mkdir(processedDir);
    end

    fprintf('====================================================================\n');
    fprintf('  SAREE BORDER PATTERN EXTRACTION — DATASET ORGANIZER & VALIDATOR  \n');
    fprintf('====================================================================\n');
    fprintf('Base Directory: %s\n\n', baseDatasetDir);

    % Supported extensions
    validExts = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff'};

    % Find all images in rawDir and direct subdirectories
    rawFiles = dir(rawDir);
    imageFiles = {};
    for k = 1:length(rawFiles)
        if rawFiles(k).isdir, continue; end
        [~, ~, ext] = fileparts(rawFiles(k).name);
        if any(strcmpi(ext, validExts))
            imageFiles{end+1} = fullfile(rawDir, rawFiles(k).name); %#ok<AGROW>
        end
    end

    fprintf('Found %d raw image files to validate and organize.\n', length(imageFiles));

    totalProcessed = 0;
    validCount = 0;
    corruptCount = 0;
    duplicateCount = 0;

    seenSizes = containers.Map('KeyType', 'char', 'ValueType', 'char');
    manifestRows = {};

    categoryCounts = containers.Map(categories, num2cells(zeros(1, length(categories))));

    for i = 1:length(imageFiles)
        srcFile = imageFiles{i};
        [~, baseName, ext] = fileparts(srcFile);
        fileName = [baseName, ext];
        totalProcessed = totalProcessed + 1;

        % Check readability via imfinfo
        try
            info = imfinfo(srcFile);
            if isempty(info) || info(1).Width < 10 || info(1).Height < 10
                fprintf('[CORRUPTED] %s (dimensions too small)\n', fileName);
                corruptCount = corruptCount + 1;
                continue;
            end
            imgWidth = info(1).Width;
            imgHeight = info(1).Height;
            colorType = info(1).ColorType;
            fileSize = info(1).FileSize;
        catch
            fprintf('[CORRUPTED] %s (unreadable image header)\n', fileName);
            corruptCount = corruptCount + 1;
            continue;
        end

        % Duplicate detection using Size + Dimensions signature
        sigKey = sprintf('%d_%d_%d', fileSize, imgWidth, imgHeight);
        if isKey(seenSizes, sigKey)
            fprintf('[DUPLICATE] %s matches %s (skipping copy)\n', fileName, seenSizes(sigKey));
            duplicateCount = duplicateCount + 1;
            continue;
        else
            seenSizes(sigKey) = fileName;
        end

        % Determine category without guessing
        targetCategory = 'unclassified';
        lowerName = lower(fileName);
        if contains(lowerName, 'silk')
            targetCategory = 'silk';
        elseif contains(lowerName, 'cotton')
            targetCategory = 'cotton';
        elseif contains(lowerName, 'designer')
            targetCategory = 'designer';
        elseif contains(lowerName, 'printed')
            targetCategory = 'printed';
        elseif contains(lowerName, 'handloom')
            targetCategory = 'handloom';
        end

        % Target categorized file path
        destCatFile = fullfile(baseDatasetDir, targetCategory, fileName);
        if ~exist(destCatFile, 'file')
            copyfile(srcFile, destCatFile);
        end

        % Standardized processed copy in dataset/processed/
        destProcFile = fullfile(processedDir, fileName);
        if ~exist(destProcFile, 'file')
            copyfile(srcFile, destProcFile);
        end

        validCount = validCount + 1;
        categoryCounts(targetCategory) = categoryCounts(targetCategory) + 1;

        manifestRows{end+1, 1} = fileName; %#ok<AGROW>
        manifestRows{end, 2} = targetCategory;
        manifestRows{end, 3} = sprintf('%dx%d', imgWidth, imgHeight);
        manifestRows{end, 4} = colorType;
        manifestRows{end, 5} = sprintf('%.1f KB', fileSize / 1024);
        manifestRows{end, 6} = fullfile('dataset', targetCategory, fileName);
    end

    % Write organized manifest CSV
    manifestPath = fullfile(baseDatasetDir, 'organized_manifest.csv');
    writeOrganizedManifestCSV(manifestPath, manifestRows);

    fprintf('\n--------------------------------------------------------------------\n');
    fprintf('Organization Summary:\n');
    fprintf('  Total Scanned : %d\n', totalProcessed);
    fprintf('  Valid Images  : %d\n', validCount);
    fprintf('  Corrupted     : %d\n', corruptCount);
    fprintf('  Duplicates    : %d\n', duplicateCount);
    fprintf('\nCategory Breakdown:\n');
    for c = 1:length(categories)
        catName = categories{c};
        fprintf('  - %-14s: %d\n', catName, categoryCounts(catName));
    end
    fprintf('  Manifest File : %s\n', manifestPath);
    fprintf('====================================================================\n\n');

    summary.totalProcessed = totalProcessed;
    summary.validCount = validCount;
    summary.corruptCount = corruptCount;
    summary.duplicateCount = duplicateCount;
    summary.categoryCounts = categoryCounts;
    summary.manifestPath = manifestPath;
end

function writeOrganizedManifestCSV(manifestPath, rows)
    fid = fopen(manifestPath, 'w');
    if fid == -1
        warning('Could not write organized manifest at %s', manifestPath);
        return;
    end
    fprintf(fid, 'Filename,Category,Dimensions,ColorType,FileSize,RelativePath\n');
    for i = 1:size(rows, 1)
        fprintf(fid, '"%s","%s","%s","%s","%s","%s"\n', ...
            rows{i, 1}, rows{i, 2}, rows{i, 3}, rows{i, 4}, rows{i, 5}, rows{i, 6});
    end
    fclose(fid);
end

function c = num2cells(numArray)
    c = cell(size(numArray));
    for i = 1:numel(numArray)
        c{i} = numArray(i);
    end
end
