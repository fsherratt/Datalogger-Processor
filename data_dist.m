% Evaluate distribution of activities throughout data files
% Run by the pipeline function

function data_dist(output)
    fprintf('Running distribution analysis\n');

    % Constants
    activity_types = [0, 1, 2, 3, 4, 5]; % Walking, Ramp Ascent, Ramp Descent, Stair Ascent, Stair Descent, Stopped
    window_size = 30000; % Number of samples in 5 Minutes at 100Hz 
    step_size = 100; % Number of samples in 1s at 100Hz
    
    output = output{1};
    table_length = size(output, 1);
    activities = table2array(output(:, 'activity'));
    number_activities = size(activity_types, 2);
    
    if (table_length < window_size)
        fprintf('Data file too short for analysis\n')
        activity_freq = zeros(0,0);
        return
    end
    
    % Produce a running distribution of data samples over 5 minutes
    % Window the output into 5 minute segments - leave 100ms between windows?
    window_start = 1:step_size:table_length-window_size;
    window_end = window_start + window_size;
    number_windows = size(window_start, 2);

    
    activity_freq = zeros(number_windows, number_activities);
    
    % Count number of each sample in the window
    for i = 1:number_windows
        window = window_start(i):window_end(i);
        
        for j = 1:number_activities
            line_count = sum(activities(window) == activity_types(j));
            activity_freq(i, j) = line_count;
%             fprintf('Window: %d\tActivity: %d\t Count: %d\n', i, j, line_count);
        end
    end
    
    activity_freq = activity_freq ./ window_size;
    
    % Plot results
    figure;
    plot(activity_freq)
    xlabel('Time [s]');
    label('Distribution of activities [%]');
    legend('Walking', 'Ramp Ascent', 'Ramp Descent', 'Stair Ascent', 'Stair Descent', 'Stopped');
end