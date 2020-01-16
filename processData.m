%% Data folder
DataFolder = 'Data\Pendulum\';
DataHeader = 'Data\data_structure.json';

fileList = dir([DataFolder, '*.txt']);
clear deviceData
for i = 1:length(fileList)
    fileName = [fileList(i).folder, '\\', fileList(i).name];
    
    deviceDataTmp = readDataFile(fileName, DataHeader);
    deviceDataTmp.file = fileList(i).name;
    
    deviceData(i) = deviceDataTmp;
end

clear filelist deviceDataTmp

%% Plot data
ax = [];
for i = 1:length(deviceData)
%     figure('Name', [deviceData(i).file, ' - Gyro']);
%     ax(end+1) = axes;
%     plot(deviceData(i).time, deviceData(i).gyro);
    
    [coeff, ~, ~, ~, explained, ~] = pca(deviceData(i).gyro);
    
%     [~, ~, roll] = dcm2angle(coeff);
%     fprintf("%s\t Roll: %0.2f\n", deviceData(i).file, rad2deg(roll));
    
%     coeff = angle2dcm(0, 0, roll);
    
    deviceData(i).gyro = deviceData(i).gyro * coeff;
        
    figure('Name', [deviceData(i).file, ' - Gyro PCA']);
    ax(end+1) = axes;
    plot(deviceData(i).time, deviceData(i).gyro);
end

% legend(deviceNames.values({deviceData(:).name}))
% linkaxes(ax, 'x');

%% clear i