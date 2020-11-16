clear Config
tic

warning('on','all');

%---------------------------------------------------------------------------------------------------
% Pipeline Configuration
%---------------------------------------------------------------------------------------------------
% Folder containing the raw data
% Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stair_Video/'; % Folder containing the raw data
Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs/**';

Config.Devices = {};
Config.Devices{1} = ["0C:8C:DC:2E:30:DC", "0C:8C:DC:2E:32:67", ...
                     "0C:8C:DC:2E:33:78", "0C:8C:DC:2E:40:7D", ...
                     "0C:8C:DC:2E:3B:57"];
Config.Devices{2} = ["0C:8C:DC:2E:34:70", "0C:8C:DC:2E:40:6C", ...
                     "0C:8C:DC:2E:33:3D", "0C:8C:DC:2E:3B:FF", ...
                     "0C:8C:DC:2E:3B:81"];

Config.DataOutputFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs/Out/';
Config.OutputPrefix = 'Out_'; % Genearted file prefix
Config.OutputSuffix = '.csv'; % Generated file extension

Config.OutputLogFilePath = Config.DataOutputFolder; % Output log file save location
Config.OutputLogFile = 'output.log'; % Output log file name

Config.DataHeader = []; % Use default data header file
Config.TargetFrequency = 100; % Hz
Config.Normalise = true;

Config.OutputPrefix = strcat(Config.OutputPrefix, ...
                             num2str(Config.TargetFrequency), "_");

Config.ApplyIMUCalibration = false; % Apply user calibration file to sensors
Config.AutoFixIncorrectAlignment = true; % Some idiot put the ankle sensors on the outside of the ankles...
Config.RemapAxis = true;

Config.RealignLabels = false;
Config.PlotAlignmentLabels = false; % Show label debug plots

Config.SplitTableAtTransition = false;
Config.PlotSplitData = true;

Config.SaveToCsv = false;

Config.UpdateLogFile = false;
LogStruct = struct('Date_created', '', ...
                    'Save_Location', Config.DataOutputFolder, ...
                    'Input_file', '', ...
                    'Sample_Rate', Config.TargetFrequency, ...
                    'Normalise', Config.Normalise, ...
                    'Imu_Calibration', Config.ApplyIMUCalibration, ...
                    'Realign_Labels', Config.RealignLabels, ...
                    'Split_index', 0);

%---------------------------------------------------------------------------------------------------
% Pipeline
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
    LogStruct.Input_file = dataFiles(i).data;
    disp(LogStruct.Input_file);
    [~, data] = readData(dataFiles(i).data, header);
    
    % Split sensors and apply pre-processing
    data = preProcessDataFile(data, header, Config.Devices, ...
                              Config.TargetFrequency, ...
                              Config.ApplyIMUCalibration, ...
                              Config.AutoFixIncorrectAlignment, ...
                              Config.RemapAxis);
    
    % If a label file exsists
    if ~strcmp(dataFiles(i).label, '')
        % Open and parse label file
        
        fprintf('Loading label file: %s\n', reduceTextLength(dataFiles(i).label, 61));
        label = readDataLabels(dataFiles(i).label, Config.TargetFrequency);
        
        % Align user entered labels with Heel Strike
        if Config.RealignLabels
            fprintf('Aligning labels\n');
            hsR = identifyHeelStrike(data, 'r_ankle');
            hsL = identifyHeelStrike(data, 'l_ankle');
            label = labelAlignment(data, label, [hsR, hsL], Config.PlotAlignmentLabels);
        end
    end
    
    % Create ouput data tables
    fprintf('Generating output table\n');
    output = postProcessData(data, label);
    
    % Split data into activity segments
    if Config.SplitTableAtTransition
        hsR = identifyHeelStrike(data, 'r_ankle');
        hsL = identifyHeelStrike(data, 'l_ankle');
        [output, Stats] = splitTransitionData(output, label, [hsR, hsL], Config.PlotSplitData);
    else
        output = {output};
    end
     
    if Config.SaveToCsv
        for n = 1:length(output)
            % Participant
            expr = 'Participant_(\d*)';
            participant_number = regexp(dataFiles(i).data, expr, 'tokens');
            
            if isempty(participant_number)
                participant_number = 'unknown';
            else
                participant_number = string(participant_number{1});
            end
            
            
            % Generate file name
            [~, file, ~]  = fileparts(dataFiles(i).data);
            data_file = sprintf('%s%s_%d%s', Config.OutputPrefix, file, ...
                                n, Config.OutputSuffix);
            directory = sprintf('%sParticipant_%s/', ...
                              Config.DataOutputFolder, participant_number);
            
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            
            % Save to CSV
            fprintf('Saving to file: %s\n', reduceTextLength(data_file, 61));
            writetable(output{n}, [directory, data_file], ...
                'FileType', 'text', 'Delimiter', ',');

            if Config.UpdateLogFile
                % Make log file
                fprintf('Updating log file\n');
                fid = fopen([Config.OutputLogFilePath, Config.OutputLogFile], 'a+');
                date = string(datetime('now', 'Format', 'yyyy-MM-DD-HH-mm-SS'));
                
                LogStruct.Date_created = date;
                LogStruct.Split_index = n;
                
                [~] = fprintf(fid, '- %s:\n', data_file);
                structToTxt(fid, LogStruct);
                
                % Add split stats to log file
                if Config.SplitTableAtTransition
                    structToTxt(fid, Stats(n));
                end
                
                [~] = fclose(fid);
            end
        end
    end
    fprintf('--------------------------------------------------------------------------------\n');
end

clear dataFiles header i j n data label file data_file date fid hsR hsL LogStruct Stats
toc
%---------------------------------------------------------------------------------------------------

function structToTxt(fid, structure)
    fn = fieldnames(structure);
    for j = 1:numel(fn)
        field = fn{j};
        val = structure.(field);

        if isnumeric(val) || islogical(val)
            fprintf(fid, '\t%s: %d\n', field, val);
        else
            fprintf(fid, '\t%s: %s\n', field, val);
        end
    end
end
% EOF
