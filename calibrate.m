% Calibrate sensors
for i = 1:size(deviceData, 2)
    % select 10->90% data range
    datStart = round(0.1*deviceData(i).samples);
    datEnd = round(0.9*deviceData(i).samples);
    
    accel = deviceData(i).accel(datStart:datEnd, :);
    gyro = deviceData(i).gyro(datStart:datEnd, :);
    
    calib(i).name= deviceData(i).name;
    calib(i).accel = [0, 0, -9.81] - mean(accel);
    calib(i).gyro = [0, 0, 0] - mean(gyro);
end

clear i datStart datEnd accel gyro