clear Config
tic
%---------------------------------------------------------------------------------------------------
% Pipeline Configuration
%---------------------------------------------------------------------------------------------------
Config.DataFolder = 'Data/Stair_Test/'; % Folder containing the raw data

Config.DataOutputFolder = 'C:\Users\fs349\Desktop\Out\'; % Folder to save output to
% Config.DataOutputFolder = 'Out/';
Config.OutputPrefix = 'Out_'; % Genearted file prefix
Config.OutputSuffix = '.csv'; % Generated file suffix

Config.OutputLogFilePath = Config.DataOutputFolder; % Output log file save location
Config.OutputLogFile = 'output.log'; % Output log file name

Config.DataHeader = []; % Use default header file
Config.TargetFrequency = 100; % Hz
Config.ApplyIMUCalibration = true; % Apply user calibration file to sensors

Config.RealignLabels = true;
Config.PlotAlignmentLabels = false; % Show label debug plots

Config.SplitTableAtTransition = true;
Config.PlotSplitData = false;

Config.SaveToCsv = true;

Config.UpdateLogFile = true;
%---------------------------------------------------------------------------------------------------

% Find log files - match data and label files
dataFiles = loadFolder(Config.DataFolder);
if isempty(dataFiles)
    warning('No files found - Check data folder is correct');
    return;
end

% Read the data header - for parsing
header = readHeader(Config.DataHeader);

for i = 1:length(dataFiles)
    % Open and parse data file
    [~, data] = readData(dataFiles(i).data, header);

    % Split sensors and apply pre-processing
    data = preProcessDataFile(data, header, Config.TargetFrequency, Config.ApplyIMUCalibration);
    [hsR, hsL] = identifyHeelStrike(data);
    
    % If a label file exsists
    if ~strcmp(dataFiles(i).label, '')
        % Open and parse label file
        fprintf('Loading label file: %s\n', reduceTextLength(dataFiles(i).label, 61));
        label = readDataLabels(dataFiles(i).label, Config.TargetFrequency);
        
        % Align user entered labels with Heel Strike
        if Config.RealignLabels
            fprintf('Aligning labels\n');
            label = labelAlignment(data, label, [hsR, hsL], Config.PlotAlignmentLabels);
        end
    end
    
    % Create ouput data tables
    fprintf('Generating output table\n');
    output = postProcessData(data, label);
    
    % Split data into activity segments
    if Config.SplitTableAtTransition
        [output, stats] = splitTransitionData(output, label, [hsR, hsL], Config.PlotSplitData);
    end
     
    if Config.SaveToCsv
        for n = 1:length(output)
            % Generate file name
            [~, file, ~]  = fileparts(dataFiles(i).data);
            data_file = sprintf('%s%s_%d%s',Config.OutputPrefix, file, n, Config.OutputSuffix);

            % Save to CSV
            fprintf('Saving to file: %s\n', reduceTextLength(data_file, 61));
            writetable(output{n}, [Config.DataOutputFolder, data_file], ...
                'FileType', 'text', 'Delimiter', ',');

            if Config.UpdateLogFile
                % Make log file
                fprintf('Updating log file\n');
                fid = fopen([Config.OutputLogFilePath, Config.OutputLogFile], 'a+');
                date = string(datetime('now', 'Format', 'yyyy-MM-DD-HH-mm-SS'));

                [~] = fprintf(fid, ['- %s:\n', '\tdate_created: %s\n', '\tsave_location: %s\n', ...
                    '\tinput_file: %s\n', '\tsplit_number: %d\n', '\tsample_rate: %d\n',  ...
                    '\timu_calibration: %d\n', '\trealign_labels: %d\n'], ...
                    data_file, date, Config.DataOutputFolder, dataFiles(i).data, n, ...
                    Config.TargetFrequency, Config.ApplyIMUCalibration, Config.RealignLabels);
                
                if Config.SplitTableAtTransition
                    % Add stats to yaml file
                end
                [~] = fclose(fid);
            end
        end
    end
    fprintf('--------------------------------------------------------------------------------\n');
end

clear dataFiles header i data label file data_file date fid hsR hsL
toc
%---------------------------------------------------------------------------------------------------

% EOF
