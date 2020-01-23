%% Load Data
% Todo add in both right and left ankle
% Todo adjust labels to neaerest HS

DataFolder = 'Data/Stair_Test/';

[dataSet, labelSet] = loadFolder(DataFolder);

% Plot gyro
plot(dataSet.data(1).time, -dataSet.data(1).gyro(:, 3))

%% Find heel strike
[~, gyro_locs] = findpeaks(-dataSet.data(1).gyro(:, 3), ...
                    'MinPeakProminence', 1, ...
                    'MinPeakHeight', 100, ...
                    'MinPeakDistance', 30 );

[~, accel_locs] = findpeaks(vecnorm(dataSet.data(1).accel,2,2), ...
                    'MinPeakProminence', 1, ...
                    'MinPeakHeight', 20, ...
                    'MinPeakDistance', 30 );

% Each HS should be an accleration peak preceded by a leg swing
hs = [];
for i = 1:length(gyro_locs)
    tmp = accel_locs( accel_locs > gyro_locs(i) );
    
    if ~isempty(tmp)
        if ( tmp(1) - gyro_locs(i) ) < 100 % 1 second (100Hz) timeout
            hs(end+1) = tmp(1);
        end
    end
end

%% Plot Heel strike
hold all
plot(dataSet.data(1).time(hs), -dataSet.data(1).gyro(hs, 3), 'x')
hold off

%% Process labels
ix = zeros(length(labelSet.time), 1);
for i = 1:length(labelSet.time)
% Find index of label
    [~, ix(i)] = min(abs(dataSet.data(1).time - labelSet.time(i)));
end

%% Plot label locations
hold all
plot(dataSet.data(1).time(ix), -dataSet.data(1).gyro(ix, 3), 'o')
hold off

