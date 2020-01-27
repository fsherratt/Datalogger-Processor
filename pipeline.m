%---------------------------------------------------------------------------------------------------
% Pipeline Configuration
%---------------------------------------------------------------------------------------------------
Config.DataFolder = 'Data/Stair_Test/'; % Folder containing the raw data
Config.DataOutput = 'Out/'; % Folder to save output to
Config.OutputPrefix = 'Out_';
Config.OutputExtension = '.csv';

Config.DataHeader = []; % Use default header file
Config.TargetFrequency = 100; % Hz
Config.ApplyIMUCalibration = true; % Apply user calibration file to sensors

Config.PlotAlignmentLabels = false; % Show label debug plots
%---------------------------------------------------------------------------------------------------

% Find log files - match data and label files
dataFiles = loadFolder(Config.DataFolder);

% Read the data header - for parsing
header = readHeader(Config.DataHeader);

for i = 1:length(dataFiles)
    % Open and parse data file
    [~, data] = readData(dataFiles(i).data, header);

    % Split sensors and apply pre-processing
    data = preProcessDataFile(data, header, Config.TargetFrequency, Config.ApplyIMUCalibration);
    
    % If a label file exsists
    if ~strcmp(dataFiles(i).label, '')
        % Open and parse label file
        fprintf('Loading label file: %s\n', reduceTextLength(dataFiles(i).label, 61));
        label = readDataLabels(dataFiles(i).label, Config.TargetFrequency);
        % Align user entered labels with Heel Strike
        fprintf('Aligning labels\n');
        label = labelAlignment(data, label, Config.PlotAlignmentLabels);
    end
    fprintf('--------------------------------------------------------------------------------\n');
    
    % Create ouput data table
    fprintf('Generating output table\n');
    output = postProcessData(data, label);
       
    % Save to CSV
    [~, data_file, ~]  = fileparts(dataFiles(i).data);
    data_file = [Config.DataOutput, Config.OutputPrefix, data_file, Config.OutputExtension];
    fprintf('Saving to file: %s\n', reduceTextLength(data_file, 61));
    writetable(output, data_file, 'FileType', 'text', 'Delimiter', ',');
    fprintf('--------------------------------------------------------------------------------\n');
end

clear dataFiles header i data label data_file

%---------------------------------------------------------------------------------------------------
% EOF
