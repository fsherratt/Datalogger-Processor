% Load data file
source_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\1_20200611-101247\Source_Data\';
source_file_list = dir([source_dir, '*.csv']);

% Load result file
result_dir = 'C:\Users\Freddie\Documents\PhD\Machine-Learning\Output\1_20200611-101247\Results\Data\';
result_file_list = dir([result_dir, '*.csv']);

% One hot conversion
file_num = 6;
source_file = source_file_list(file_num);
result_file = result_file_list(file_num);

source_data = readtable([source_file.folder, '\', source_file.name]);
result_data = readtable([result_file.folder, '\', result_file.name]);
result_data = table2array(result_data);

yyaxis left
plot(source_data.time, source_data.activity)
hold all
yyaxis right
plot(source_data.time(129:end), result_data(:, 1), 'r-')
plot(source_data.time(129:end), result_data(:, 2), 'g:')
plot(source_data.time(129:end), result_data(:, 3), 'b--')
lgnd = {'label', 'walking', 'stair ascent', 'stair descent'};

if size(result_data, 2) == 4
    plot(source_data.time(129:end), result_data(:, 4), 'k-.')
    lgnd{end+1} = 'transition';
end

legend(lgnd)
hold off