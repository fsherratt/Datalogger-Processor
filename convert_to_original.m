%% Load File
filename = 'Data/Log_20191220_123026';
% filename = 'Data/Syncronise_test';

[~, split, struct] = readData(filename);

%% Setup device Map
deviceKeys = {'0C:8C:DC:2E:30:DC', '0C:8C:DC:2E:32:67', ...
              '0C:8C:DC:2E:33:78', '0C:8C:DC:2E:34:70', ...
              '0C:8C:DC:2E:3B:57', '0C:8C:DC:2E:3B:81', ...
              '0C:8C:DC:2E:40:7D'};
deviceValues = {'Right Ankle', 'Left Ankle', 'Right Hip', ...
                'Right Wrist', 'Chest', 'Left Wrist', 'Left Hip'};

deviceNames = containers.Map(deviceKeys, deviceValues);


%% Split data and syncronise - data syncronised by android clock
% Todo add in calibration!!!!!
load('sensor_calibration.mat')

% Todo add in friendly name!!!!!
devices = unique(split.device);
clear deviceData;
fprintf('Split Device Data\n');
fprintf('----------------------------------------\n');

for i = 1:length(devices)
    device = devices(i);
    fprintf("Seperating device %s\n", deviceNames(device));
    
    deviceRows = split.device == convertStringsToChars(device);
    deviceRows = find(deviceRows);
    timestamp = split.timestamp(deviceRows);
    
    aTime = split.androidTime(deviceRows);
    aTime = aTime - aTime(1);
    timestamp = timestamp - timestamp(1);
    
%     figure('Name', deviceNames(device));
%     drift = timestamp - aTime;
%     plot(drift);
    
    
    deltaT = timestamp(i+1:end) - timestamp(i:end-1);
    timestamp = timestamp + (0:7).*(mean(deltaT)/8);
    timestamp = reshape(timestamp', 1, [])';
    timestamp = timestamp./1000;
    
    magn = reshape(split.magn(deviceRows, :)', 3, [])' ./5;
    gyro = reshape(split.gyro(deviceRows, :)', 3, [])' ./ 8;
    accel = reshape(split.accel(deviceRows, :)', 3, [])' ./ 1000;
    
    % Apply sensor offset calibration
%     calibration_row = find([calib(:).name] == device);
%     if length(calibration_row) == 1
%         accel = accel + calib(calibration_row).accel;
%         gyro = gyro + calib(calibration_row).gyro;
%     else
%         warning('No calibration data found for device ' + device);
%     end
    
    data = [timestamp, accel, gyro, magn];
    
    % Resampling too 100Hz
    resampleRate = 0;
    if resampleRate > 0
        date = datetime( struct.date, 'InputFormat', struct.dateformat );
        dateArray = date + seconds(timestamp);

        dataResample = resample( data, dateArray, resampleRate );
        dataResample( :, 1 ) = ( 0:(length(dataResample)-1) ) ./resampleRate;

        data = dataResample;
    end
    
    deviceData(i).name = device;
    deviceData(i).samples = size(data, 1);
    deviceData(i).timestamp = data(:, 1);
    deviceData(i).accel = data(:, 2:4);
    deviceData(i).gyro = data(:, 5:7);
    deviceData(i).magn = data(:, 8:10);
end
fprintf('----------------------------------------\n');

for i = 1:size(deviceData, 2)
    timestamp = deviceData(i).timestamp;
    
    deltaT = timestamp(i+1:end) - timestamp(i:end-1);
    freq = 1./(deltaT);
    fprintf( "%s\tSamples: %d  Avg: %0.2f  Std: %0.2f  Min: %0.2f  Max: %0.2f\n", deviceNames(deviceData(i).name), length(timestamp),  mean(freq), std(freq), min(freq), max(freq) );
end

fprintf('----------------------------------------\n');

clear i struct data date dateArray deltaT device deviceRows timestamp freq accel gyro magn resampleRate dataResample


%% Combine sensors into a single matrix
% stopPoint = min([deviceData(:).samples]);
% 
% % Todo needs to be in a consistent order with labeled headers
% for i = 1:size(deviceData, 2)
%     deviceData(i).samples = stopPoint;
%     deviceData(i).timestamp = deviceData(i).timestamp(1:stopPoint);
%     deviceData(i).accel = deviceData(i).accel(1:stopPoint, :);
%     deviceData(i).gyro = deviceData(i).gyro(1:stopPoint, :);
%     deviceData(i).magn = deviceData(i).magn(1:stopPoint, :);
%     
%     deviceData(i).data = [deviceData(i).accel, deviceData(i).gyro, deviceData(i).magn];
% end
% clear i stopPoint


%% Read Labels

%% Add labels



%% Plot data
fig = [];
for i = 1:size(deviceData, 2)
    figure('Name', deviceNames(deviceData(i).name));
    fig(end+1) = axes;
    plot(deviceData(i).timestamp, deviceData(i).accel);
end
legend(deviceNames.values({deviceData(:).name}))
linkaxes(fig, 'x');
clear i


%% Clean up
clear filename

%EOF
