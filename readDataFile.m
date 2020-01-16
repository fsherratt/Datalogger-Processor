%% Load File
function [deviceData] = readDataFile(dataFile, headerFile)

deviceKeys = {'0C:8C:DC:2E:30:DC', '0C:8C:DC:2E:32:67', ...
              '0C:8C:DC:2E:33:78', '0C:8C:DC:2E:34:70', ...
              '0C:8C:DC:2E:3B:57', '0C:8C:DC:2E:3B:81', ...
              '0C:8C:DC:2E:40:7D', '0C:8C:DC:22:2A:0B'};
deviceValues = {'Right Ankle', 'Left Ankle', 'Right Hip', ...
                'Right Wrist', 'Chest', 'Left Wrist', 'Left Hip', 'Dev'};
            
deviceNames = containers.Map(deviceKeys, deviceValues);            

[~, split, struct] = readData(dataFile, headerFile);

%% Split data and syncronise - data syncronised by android clock
% Todo add in calibration!!!!!
% load('sensor_calibration.mat')

fprintf('Split Device Data\n');
fprintf('----------------------------------------\n');
devices = unique(split.device);

for i = 1:length(devices)
    device = devices(i);
    
    fprintf("Seperating device %s\n", device);
    
    deviceRows = split.device == convertStringsToChars(device);
    deviceRows = find(deviceRows);
    timestamp = split.timestamp(deviceRows)./1000;
    timestamp = timestamp - timestamp(1);
    
%     aTime = split.androidTime(deviceRows);
%     aTime = aTime - aTime(1);
    
%     figure('Name', deviceNames(device));
%     drift = timestamp - aTime;
%     plot(drift);


    % Heartrate data
    updated = split.updated(deviceRows);
    heartrate = split.heartrate(deviceRows) ./ struct.datafields.heartrate.scale;
    rrInterval = split.rrInterval(deviceRows) ./ struct.datafields.rrInterval.scale; 
    
    hrUpdate = find(bitand(uint8(updated), uint8(2)) > 0);
    hrTime = timestamp(hrUpdate);
    heartrate = heartrate(hrUpdate);
    rrInterval = rrInterval(hrUpdate);

    
    % Temperature
    temperature = split.temperature(deviceRows) ./ struct.datafields.temperature.scale;
    tempUpdate = find(bitand(uint8(updated), uint8(1)) > 0);
    tempTime = timestamp(tempUpdate);
    temperature = temperature(tempUpdate);
    
    
    % 9 Axis IMU Data    
    deltaT = timestamp(i+1:end) - timestamp(i:end-1);
    timestamp = timestamp + (0:7).*(mean(deltaT)/8);
    timestamp = reshape(timestamp', 1, [])';
    
    magn = reshape(split.magn(deviceRows, :)', 3, [])' ./ struct.datafields.magn.scale;
    gyro = reshape(split.gyro(deviceRows, :)', 3, [])' ./ struct.datafields.gyro.scale;
    accel = reshape(split.accel(deviceRows, :)', 3, [])' ./ struct.datafields.accel.scale;
    
    % Apply sensor offset calibration
%     calibration_row = find([calib(:).name] == device);
%     if length(calibration_row) == 1
%         accel = accel + calib(calibration_row).accel;
%         gyro = gyro + calib(calibration_row).gyro;
%     else
%         warning('No calibration data found for device ' + device);
%     end
    
    % Resampling too 100Hz
    data = [timestamp, accel, gyro, magn];
    data = resampleData( 100, timestamp, data);
    
    deviceData(i).name = device;
    deviceData(i).friendly = deviceNames(device);
    deviceData(i).samples = size(data, 1);
    deviceData(i).time = data(:, 1);
    deviceData(i).accel = data(:, 2:4);
    deviceData(i).gyro = data(:, 5:7);
    deviceData(i).magn = data(:, 8:10);
    deviceData(i).rrInterval = [hrTime, rrInterval];
    deviceData(i).heartrate = [hrTime, heartrate];
    deviceData(i).temperature = [tempTime, temperature];
end

fprintf('----------------------------------------\n');

for i = 1:size(deviceData, 2)
    timestamp = deviceData(i).time;
    
    deltaT = timestamp(i+1:end) - timestamp(i:end-1);
    freq = 1./(deltaT);
    fprintf( "%s\tSamples: %d  Avg: %0.2f  Std: %0.2f  Min: %0.2f  Max: %0.2f\n", deviceNames(deviceData(i).name), length(timestamp),  mean(freq), std(freq), min(freq), max(freq) );
end

fprintf('----------------------------------------\n');


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

end

function [data] = resampleData(resampleRate, timestamp, data)
    if resampleRate > 0
        date = datetime( '1970-01-01-000000', 'InputFormat', 'yyyy-MM-dd-HHmmSS' );
        dateArray = date + seconds(timestamp);

        dataResample = resample( data, dateArray, resampleRate, 'spline' );
        dataResample( :, 1 ) = ( 0:(length(dataResample)-1) ) ./resampleRate;

        data = dataResample;
    end
end

%EOF
