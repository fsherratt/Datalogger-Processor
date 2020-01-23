ax = [];
for i = 1:length(deviceData)
    for j = 1:length(deviceData(i).data)
        
        deviceData(i).data(j).gyro = lowpass( deviceData(i).data(j).gyro, 10, 100);
        
        figure('Name', [deviceData(i).file, ' - ', deviceData(i).data(j).friendly, ' - Gyro']);
        ax(end+1) = axes;
        plot(deviceData(i).data(j).time, deviceData(i).data(j).gyro);

        [coeff, ~, ~, ~, explained, ~] = pca(deviceData(i/).data(j).gyro);

        [yaw, pitch, roll] = dcm2angle(coeff);
        fprintf("%s\t Explained: %0.2f\t%0.2f\t%0.2f\n", [deviceData(i).file, ' - ', deviceData(i).data(j).friendly], explained);

        deviceData(i).data(j).gyro = deviceData(i).data(j).gyro * coeff;

        figure('Name', [deviceData(i).file, ' - ', deviceData(i).data(j).friendly, ' - Gyro PCA']);
        ax(end+1) = axes;
        plot(deviceData(i).data(j).time, deviceData(i).data(j).gyro);
    end
end

linkaxes(ax, 'x');