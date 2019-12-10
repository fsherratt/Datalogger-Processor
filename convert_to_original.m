filename = 'Log_20191203_135501';

[data, split, struct] = readData(filename);

% Check array length is defined correctly - 76 not 75
% Check how union is packed - does it need reordering
% How to turn two characterisitc data back to original format

%%
devices = unique(split.device);

figure;
axis;
hold all;

for i = 1:length(devices)
    device = devices(i);
    deviceRows = split.device == convertStringsToChars(device);
    timestamp = split.timestamp(deviceRows);
    
    timestamp = timestamp - timestamp(1);
    timestamp = timestamp./1000;
    
    freq = timestamp(i+1:end) - timestamp(i:end-1);
    freq = 1./freq;
    freq = freq * 8;
    
    magn = reshape(split.magn(deviceRows, :)', 3, [])' ./5;
    gyro = reshape(split.gyro(deviceRows, :)', 3, [])' ./ 8;
    accel = reshape(split.accel(deviceRows, :)', 3, [])' ./ 1000;
    plot(vecnorm(accel,2,2));
    
    fprintf( "%s  Samples: %d  Avg: %0.2f  Std: %0.2f  Min: %0.2f  Max: %0.2f\n", device, length(timestamp)*8,  mean(freq), std(freq), min(freq), max(freq) );
end

% device1 = (split.device == '0C:8C:DC:2E:3B:57');
% timestamp = split.timestamp(device1);
% accel = split.accel(device1, :);
% gyro = split.gyro(device1, :);
% magn = split.magn(device1, :);
% 
% accel = accel/1000;
% gyro = gyro/4;
% magn = magn/4;
% 
% accel = reshape(accel', 3, [])';
% gyro = reshape(gyro', 3, [])';
% magn = reshape(magn', 3, [])';
% 
% timestamp = repmat(timestamp, 1, 8) + ([0:7] * 10); % 100Hz Logging
% timestamp = reshape(timestamp', 1, [])';
% timestamp = timestamp/1000;
% 
% plot(timestamp, vecnorm(accel, 2, 2));