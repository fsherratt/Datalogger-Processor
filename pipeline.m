clear Config
t1 = tic;

warning('on','all');

%---------------------------------------------------------------------------------------------------
% Pipeline Configuration
%---------------------------------------------------------------------------------------------------
% Folder containing the raw data
% Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stair_Video/'; % Folder containing the raw data
% Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs/**';
% Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs_v1_2021-01-18/**';
Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs/Participant_09/**';
% Config.DataFolder = 'C:/Users/Freddie/Documents/PhD/Data/Prosthetic/**';

Config.Devices = {};
Config.Devices{1} = ["0C:8C:DC:2E:30:DC", "0C:8C:DC:2E:32:67", ...
                     "0C:8C:DC:2E:33:78", "0C:8C:DC:2E:40:7D", ...
                     "0C:8C:DC:2E:3B:57"];
Config.Devices{2} = ["0C:8C:DC:2E:3B:81", "0C:8C:DC:2E:40:6C", ...
                     "0C:8C:DC:2E:33:3D", "0C:8C:DC:2E:3B:FF", ...
                     "0C:8C:DC:2E:34:70"];

Config.DataOutputFolder = 'C:/Users/Freddie/Documents/PhD/Data/Stairs/Out/';
% Config.DataOutputFolder = 'C:/Users/Freddie/OneDrive - University of
% Bath/PhD/Papers/LSTM_Behaviour/Data';
Config.OutputPrefix = 'Out_'; % Genearted file prefix
Config.OutputSuffix = '.csv'; % Generated file extension

Config.OutputLogFilePath = Config.DataOutputFolder; % Output log file save location
Config.OutputLogFile = 'output.log'; % Output log file name

Config.DataHeader = []; % Use default data header file
Config.TargetFrequency = 100; % Hz
Config.Normalise = true;
config.Window_Size = 128; % Minimum size for exporting data

Config.OutputPrefix = strcat(Config.OutputPrefix, ...
                             num2str(Config.TargetFrequency), "_");

Config.ApplyIMUCalibration = false; % Apply user calibration file to sensors
Config.AutoFixIncorrectAlignment = false; % Some idiot put the ankle sensors on the outside of the ankles...
Config.RemapAxis = false;
Config.RemapLeftAnkle = true;

Config.RealignLabels = false;
Config.PlotAlignmentLabels = false; % Show label debug plots

Config.AddTransitions = false;
Config.PlotTransitionDebug = false;

Config.SaveToCsv = false;

Config.DistAnalysis = false;

Config.SplitDataByActivity = true;
Config.SplitDataFileByTime = false;
Config.MinWindowSize = floor(1.1 * config.Window_Size);
Config.MaxSplitTime = 30000;

Config.UpdateLogFile = true;
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
data_stats = {};

episode_lengths = {};

for i = 1:length(dataFiles)
    % Open and parse data file
    LogStruct.Input_file = dataFiles(i).data;
    disp(LogStruct.Input_file);
    [~, data] = readData(dataFiles(i).data, header);
    
    % Identify Participant
    expr = 'Participant_(\d*)';
    participant_number = regexp(dataFiles(i).data, expr, 'tokens');

    if isempty(participant_number)
        participant_number = 'unknown';
    else
        participant_number = string(participant_number{1});
    end
    
    % Split sensors and apply pre-processing
    data = preProcessDataFile(data, header, Config.Devices, ...
                              Config.TargetFrequency, ...
                              Config.ApplyIMUCalibration, ...
                              Config.AutoFixIncorrectAlignment, ...
                              Config.RemapAxis);
                          
    hsR = identifyHeelStrike(data, 'r_ankle');
    hsL = identifyHeelStrike(data, 'l_ankle');
    
    % If a label file exsists
    if ~strcmp(dataFiles(i).label, '')
        % Open and parse label file
        
        fprintf('Loading label file: %s\n', reduceTextLength(dataFiles(i).label, 61));
        [label, data_end, data_start] = readDataLabels(dataFiles(i).label, Config.TargetFrequency);
        
        % Align user entered labels with Heel Strike
        if Config.RealignLabels
            fprintf('Aligning labels\n');
            label = labelAlignment(data, label, [hsR, hsL], Config.PlotAlignmentLabels);
        end
    else
        continue;
    end
    
    % Create ouput data tables
    fprintf('Generating output table\n');
    
    output = postProcessData(data, label, Config.Normalise);
    
    % Limit data to START END bounds
    if isempty(data_start.time_row) || (data_start.time_row <= 0)
        data_start.time_row = 1;
    end
    if isempty(data_end.time_row) || (data_end.time_row) > height(output)
        data_end.time_row = height(output);
    end
    
    hsR = hsR(hsR < data_end.time_row & hsR > data_start.time_row) - data_start.time_row;
    hsL = hsL(hsL < data_end.time_row & hsL > data_start.time_row) - data_start.time_row;
   
    output = output(data_start.time_row:data_end.time_row, :);
       
    % Remap the left ankle so it is identical to the right ankle
    if Config.RemapLeftAnkle
        % Do rotation of left ankle data to match r ankle data
    %     output.l_ankle_accel_x = output.l_ankle_accel_x;
        output.l_ankle_accel_y = -output.l_ankle_accel_y;
    %     output.l_ankle_accel_z = output.l_ankle_accel_z;

        output.l_ankle_gyro_x = -output.l_ankle_gyro_x;
    %     output.l_ankle_accel_y = output.l_ankle_gyro_y;
        output.l_ankle_gyro_z = -output.l_ankle_gyro_z;
    end
     
    % Add heel strike labels
    output.Activity_Hs(hsL) = 1;
    output.Activity_Hs(hsR) = 2;
    
    % Generate statistics on model
    data_stats{end+1} = stats(output.activity, [hsR, hsL], participant_number);
    
    % Split data into activity segments
    if Config.SplitDataFileByTime
        output = splitDataFile(output, Config.MaxSplitTime);
    elseif Config.SplitDataByActivity
        [output, activityType] = splitDataByActivity(output, Config.MinWindowSize, Config.MaxSplitTime);
        [episode_samples, ~] = cellfun(@size, output); % Get episode lengths
        episode_lengths{end+1, 1} = episode_samples;
        episode_lengths{end, 2} = activityType;
    elseif Config.AddTransitions
        output = splitTransitionData(output, label, [hsR, hsL], Config.PlotTransitionDebug);
    else
        output = {output};
        
        % If we are looking at the whole file run distribution analysis
        if Config.DistAnalysis
            data_dist(output);
        end
    end
    
     
    if Config.SaveToCsv
        for n = 1:length(output)
            

            % Generate file name
            [~, file, ~]  = fileparts(dataFiles(i).data);
            
            % Add activity name to .csv file
            if Config.SplitDataByActivity
                data_file = sprintf('%s%s_%s_%d%s', Config.OutputPrefix, ...
                               convertLabel(activityType(n)), file, n, Config.OutputSuffix);
            else
                data_file = sprintf('%s%s_%d%s', Config.OutputPrefix, file, ...
                                n, Config.OutputSuffix);
            end
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
                
                [~] = fclose(fid);
            end
        end
    end
    fprintf('--------------------------------------------------------------------------------\n');
end

data_stats = cell2mat(data_stats);
activities = unique(vertcat(data_stats.count_activity)) + 1;

activity_count = zeros(max(activities), 1);
activity_step_count = zeros(max(activities), 1);
transition_count = 0;

participant_activity_count = zeros(max(activities), 1);
participant_step_count = zeros(max(activities), 1);
participant_transition_count = 0;

participant = str2double(data_stats(1).participant);

fprintf("-----------------------------------\n");
fprintf("Number of activites: %d\n", size(activities, 1));

for i = 1:length(data_stats)
    if (participant ~= str2double(data_stats(i).participant))
        printdata_stats(participant_activity_count, participant_step_count, participant_transition_count, data_stats(i-1).participant);
        
        participant_activity_count = zeros(max(activities), 1);
        participant_step_count = zeros(max(activities), 1);
        participant_transition_count = 0;
        
        participant = str2double(data_stats(i).participant);
    end
    
    ix = data_stats(i).count_activity + 1;
    participant_activity_count(ix) = participant_activity_count(ix) + data_stats(i).count;

    ix = data_stats(i).step_count_activity + 1;
    participant_step_count(ix) = participant_step_count(ix) + data_stats(i).step_count;
    participant_transition_count = participant_transition_count + data_stats(i).transitions_count;

    ix = data_stats(i).count_activity + 1;
    activity_count(ix) = activity_count(ix) + data_stats(i).count;
    
    ix = data_stats(i).step_count_activity + 1;
    activity_step_count(ix) = activity_step_count(ix) + data_stats(i).step_count;
    
    transition_count = transition_count + data_stats(i).transitions_count;
end

printdata_stats(participant_activity_count, participant_step_count, participant_transition_count, data_stats(i).participant);
printdata_stats(activity_count, activity_step_count, transition_count, "Totals");

toc(t1)

clear dataFiles header i j n data label file data_file date fid hsR hsL LogStruct Stats t1 ix ...
        participant participant_number data_end data_start expr
    
clear activities activity_count activity_step_count transition_count participant_activity_count ... 
        participant_step_count participant_transition_count
%---------------------------------------------------------------------------------------------------

function printdata_stats(activity_count, activity_step_count, transition_count, row_label)
    fprintf("%s,\t", row_label);
    fprintf("%d,\t", activity_count);
    fprintf("%d,\t", activity_step_count);
    fprintf("%d,\t", transition_count);
    fprintf("\n");
end

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
