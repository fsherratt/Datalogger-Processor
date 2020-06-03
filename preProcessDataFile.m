%{
% Function name - Data file pre-processor
% Long description
%
% ToDo Check if field exsists before adding to dataSet
%
% Inputs: 
%   var1 - description
%
% Outputs:
%   rtn1 - description
%
% Other m-files required: 
% Subfunctions: 
% MAT-files required: 
%
% See also: fcn2
%
% Author: Freddie Sherratt
% University of Bath
% email: F.W.Sherratt@bath.ac.uk
% Website: fsherratt.dev
% Sep 2018; Last revision: 22-Jan-2020
%}

function [deviceData] = preProcessDataFile(split, struct, devices, resampleFrequency, applyCalibration)
    
    if nargin < 3 || size(devices, 1) == 0
            Warning('preProcessDataFile: devices is empty - using all available devices');
            input('Press Enter to continue')
            devices = [];
    end
    
    if nargin < 4 || isempty(resampleFrequency)
        Warning('preProcessDataFile: no frequncy specified, data not resampled');
        input('Press Enter to continue')
        resampleFrequency = 0;
    end
    
    if nargin < 5
        applyCalibration = false;
    end

    fprintf('Split Device Data\n');
    availableDevices = unique(split.device);
    
    if size(devices, 1) == 0
        devices = availableDevices;
    % Compare available devices with specified devices
    elseif ~all(contains(devices, availableDevices))
        % Error if not available
        error('Not all devices found in data file');
    end

    % Use input available
    
    for i = 1:length(devices)
%         fprintf("Seperating device %s\n", getFriendlyName(devices(i)));
           
        % Get data rows for device
        deviceRows = split.device == convertStringsToChars(devices(i));
        deviceRows = find(deviceRows);
        
        % Timestamp
        timestamp = split.timestamp(deviceRows)./1000;
        timestamp = timestamp - timestamp(1);

        
        % Apply drift correction - compare sensor time to phone clock
        aTime = split.androidTime(deviceRows);
        aTime = aTime - aTime(1);
        aTime = aTime./1000;

        drift = timestamp - aTime;
        p = polyfit(timestamp, drift, 1);
        timestamp = timestamp - polyval(p,timestamp);

        
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

        
        % Apply sensor calibration
        if applyCalibration
            calib = getCalibration(devices(i));
            accel = accel .* [calib.x_accel_scale,  calib.y_accel_scale,  calib.z_accel_scale ];
            accel = accel +  [calib.x_accel_offset, calib.y_accel_offset, calib.z_accel_offset];
            gyro  = gyro  +  [calib.x_gyro_offset,  calib.y_gyro_offset,  calib.z_gyro_offset ];
        end
        
        deltaT = timestamp(i+1:end) - timestamp(i:end-1);
        freq = 1./(deltaT);
        fprintf( "(%d)\t%s\t -\tSamples: %d  Avg: %0.2f  Std: %0.2f  Min: %0.2f  Max: %0.2f\n", ...
            i, getFriendlyName(devices(i)), length(timestamp),  mean(freq), std(freq), ...
            min(freq), max(freq) );
        
        % Resampling too 100Hz
        data = [timestamp, accel, gyro, magn];
        data = resampleData(resampleFrequency, timestamp, data);
        
        % Pack data
        deviceData(i).name = devices(i);
        deviceData(i).friendly = getFriendlyName(devices(i));
        deviceData(i).samples = size(data, 1);
        deviceData(i).time = data(:, 1);
        deviceData(i).accel = data(:, 2:4);
        deviceData(i).gyro = data(:, 5:7);
        deviceData(i).magn = data(:, 8:10);
        deviceData(i).rrInterval = [hrTime, rrInterval];
        deviceData(i).heartrate = [hrTime, heartrate];
        deviceData(i).temperature = [tempTime, temperature];
    end

    fprintf('--------------------------------------------------------------------------------\n');
    
    % Crop sensors to the same length
    minSamples = min([deviceData.samples]);
    
    % ToDo Error is large variation between sample numbers
    if range([deviceData.samples]) > 0.1 * minSamples
        warning('Error number of sensor samples vary too much. Did a sensor disconnect?')        
        input('Press Enter to continue')
    end

    for i = 1:length(deviceData)
        deviceData(i).time = deviceData(i).time(1:minSamples, :);
        deviceData(i).accel = deviceData(i).accel(1:minSamples, :);
        deviceData(i).gyro = deviceData(i).gyro(1:minSamples, :);
        deviceData(i).magn = deviceData(i).magn(1:minSamples, :);
    end
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

% EOF
