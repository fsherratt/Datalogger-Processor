clear Config
%---------------------------------------------------------------------------------------------------
% Pipeline Configuration
%---------------------------------------------------------------------------------------------------
Config.DataFolder = 'Data/Stair_Test/'; % Folder containing the raw data

Config.DataOutput = 'C:\Users\fs349\Desktop\Out\'; % Folder to save output to
Config.OutputPrefix = 'Out_'; % Genearted file prefix
Config.OutputSuffix = '.csv'; % Generated file suffix

Config.OutputLogFilePath = Config.DataOutput; % Output log file save location
Config.OutputLogFile = 'output.log'; % Output log file name

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
       
    % Generate file name
    [~, file, ~]  = fileparts(dataFiles(i).data);
    data_file = [Config.OutputPrefix, file, Config.OutputSuffix];
    
    % Save to CSV
    fprintf('Saving to file: %s\n', reduceTextLength(data_file, 61));
    writetable(output, [Config.DataOutput, data_file], 'FileType', 'text', 'Delimiter', ',');
    
    % Make log file
    fprintf('Updating log file\n');
    fid = fopen([Config.OutputLogFilePath, Config.OutputLogFile], 'a+');
    date = string(datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-DD-HH-mm-SS'));
    [~] = fprintf(fid, ['- %s:\n', '\tdate_created: %s\n', '\tsave_location: %s\n', ...
                  '\tinput_file: %s\n', '\tsample_rate: %d\n', '\timu_calibration: %d\n'], ...
                  data_file, date, Config.DataOutput, dataFiles(i).data, ...
                  Config.TargetFrequency, Config.ApplyIMUCalibration);
    [~] = fclose(fid);
    fprintf('--------------------------------------------------------------------------------\n');
end

clear dataFiles header i data label file data_file date fid

%---------------------------------------------------------------------------------------------------
% EOF
