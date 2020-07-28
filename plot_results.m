% Load data file
% source_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\5_20200623_153800_Extra_Data\Out\';
source_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\4_20200622-163900_More_Dropout\Results\Data\';
source_file_list = dir([source_dir, '*.csv']);

% Load result file
% result_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\5_20200623_153800_Extra_Data\Results\';
result_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\4_20200622-163900_More_Dropout\Results\Data\3-State\';
result_file_list = dir([result_dir, '*.csv']);

% One hot conversion
file_num = 1;
source_file = source_file_list(file_num);
result_file = result_file_list(file_num);

source_data = readtable([source_file.folder, '\', source_file.name]);
result_data = readtable([result_file.folder, '\', result_file.name]);
result_data = table2array(result_data);

figure;
ax(1) = axes;
plot(source_data.time, source_data.activity)
yyaxis right
plot(source_data.time(129:end), result_data(:, 2), 'r-')
hold all
plot(source_data.time(129:end), result_data(:, 3), 'k:')
plot(source_data.time(129:end), result_data(:, 4), 'b--')

lgnd = {'label', 'walking', 'stair ascent', 'stair descent'};

if size(result_data, 2) == 5
    plot(source_data.time(129:end), result_data(:, 4), 'k-.')
    lgnd{end+1} = 'transition';
end

legend(lgnd)
hold off

%% Accel Mag
accel_mag = vecnorm([source_data.r_ankle_accel_x, source_data.r_ankle_accel_y, source_data.r_ankle_accel_z], 2, 2);

figure;
ax(end+1) = axes;
plot(source_data.time, source_data.activity)
yyaxis right
plot(source_data.time, accel_mag)

legend('Label', 'accel_mag')

%% Cadence
[~, gyro_ts] = findpeaks(source_data.l_ankle_gyro_z, source_data.time, ...
                        'MinPeakProminence', 10, ...
                        'MinPeakHeight', 100, ...
                        'MinPeakDistance', 0.30 );
                    
 dt_gyro_ts = gyro_ts(2:end) - gyro_ts(1:end-1);
 
figure;
ax(end+1) = axes;
plot(source_data.time, source_data.activity)
yyaxis right
plot(gyro_ts(2:end), dt_gyro_ts)

linkaxes(ax, 'x');

