function main()
% MAIN Primary entry point for the Saree Border Pattern Extraction & Similarity Comparison Project.
%
% Syntax:
%   main
%
% Description:
%   1. Verifies MATLAB version and Image Processing Toolbox availability.
%   2. Initializes workspace paths and output directories.
%   3. Prepares and audits the dataset structure.
%   4. Automatically launches the desktop graphical interface (sareeBorderGUI)
%      or provides a clean command-line menu if running in headless mode.
%
% Author: Senior MATLAB Image Processing Developer
% Project: Saree Border Pattern Extraction & Design Similarity Comparison

    clc;
    fprintf('==============================================================================\n');
    fprintf('   SAREE BORDER PATTERN EXTRACTION & DESIGN SIMILARITY COMPARISON            \n');
    fprintf('   College Image Processing Project — Automated MATLAB Implementation         \n');
    fprintf('==============================================================================\n');
    fprintf('Project Directory: %s\n', fileparts(mfilename('fullpath')));
    fprintf('MATLAB Version   : %s\n', version);
    fprintf('Date & Time      : %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf('------------------------------------------------------------------------------\n');

    % 1. Add project directories to MATLAB path
    scriptDir = fileparts(mfilename('fullpath'));
    addpath(scriptDir);
    addpath(fullfile(scriptDir, 'dataset'));
    addpath(fullfile(scriptDir, 'output'));

    % 2. Ensure output directories exist
    dirsToCreate = {
        fullfile(scriptDir, 'output', 'extracted_borders'), ...
        fullfile(scriptDir, 'output', 'comparisons'), ...
        fullfile(scriptDir, 'output', 'reports'), ...
        fullfile(scriptDir, 'dataset', 'raw'), ...
        fullfile(scriptDir, 'dataset', 'processed'), ...
        fullfile(scriptDir, 'dataset', 'silk'), ...
        fullfile(scriptDir, 'dataset', 'cotton'), ...
        fullfile(scriptDir, 'dataset', 'designer'), ...
        fullfile(scriptDir, 'dataset', 'printed'), ...
        fullfile(scriptDir, 'dataset', 'handloom'), ...
        fullfile(scriptDir, 'dataset', 'unclassified')
    };
    for i = 1:length(dirsToCreate)
        if ~exist(dirsToCreate{i}, 'dir')
            mkdir(dirsToCreate{i});
        end
    end

    % 3. Check Image Processing Toolbox requirement
    hasIPT = ~isempty(ver('images'));
    if hasIPT
        fprintf('Image Processing Toolbox: [DETECTED] Version %s\n', ver('images').Version);
    else
        fprintf('Image Processing Toolbox: [NOTE] Not explicitly registered in ver().\n');
        fprintf('                          Core algorithms include native robust fallbacks.\n');
    end

    % 4. Audit dataset readiness
    fprintf('\nAuditing dataset readiness...\n');
    dsSummary = prepareDataset();

    % 5. Launch GUI or Interactive Command-Line Menu
    isHeadless = ~usejava('jvm') || ~usejava('awt');

    if ~isHeadless
        fprintf('\nLaunching MATLAB Desktop GUI (sareeBorderGUI)...\n');
        try
            sareeBorderGUI();
            fprintf('GUI opened successfully.\n');
            return;
        catch ME
            fprintf('[NOTE] Could not open GUI in current window: %s\n', ME.message);
            fprintf('Switching to interactive console menu.\n');
        end
    else
        fprintf('\nRunning in headless/terminal environment.\n');
    end

    % Interactive Menu Fallback
    runConsoleMenu();
end

function runConsoleMenu()
    while true
        fprintf('\n------------------------------------------------------------------------------\n');
        fprintf('SAREE BORDER PROCESSING MENU:\n');
        fprintf('  [1] Launch Desktop GUI (sareeBorderGUI)\n');
        fprintf('  [2] Run Automated End-to-End Demo (runDemo)\n');
        fprintf('  [3] Run Complete Project Test Suite (testProject)\n');
        fprintf('  [4] Download Verified Open Dataset (downloadDataset)\n');
        fprintf('  [5] Prepare & Organize Dataset (prepareDataset)\n');
        fprintf('  [6] Exit\n');
        fprintf('------------------------------------------------------------------------------\n');

        choice = input('Enter selection [1-6]: ', 's');
        switch strtrim(choice)
            case '1'
                try
                    sareeBorderGUI();
                catch ME
                    fprintf('GUI launch error: %s\n', ME.message);
                end
            case '2'
                runDemo();
            case '3'
                testProject();
            case '4'
                downloadDataset();
            case '5'
                prepareDataset();
            case '6'
                fprintf('Exiting Saree Border Pattern Extraction System. Goodbye!\n');
                break;
            otherwise
                fprintf('Invalid selection. Please choose 1, 2, 3, 4, 5, or 6.\n');
        end
    end
end
