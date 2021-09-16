function [output, activityType] = splitDataByActivity(input, min_window_size, max_window_size)
    activityStart = [];
    activityType = [];
    activities = table2array(input(:, 'activity'));
    
    activityStart(end+1) = 1;
    
    output = {};
    
    for i = 2:size(activities, 1)-1
        currLabel = activities(i);
        nextLabel = activities(i+1);
        
        % Find transitions between activities
        if (currLabel ~= nextLabel) || i == size(activities, 1)-1
            
            % Skip sections that are less than 1 window long
            if i - activityStart(end) < 2 * min_window_size
                warning('Activity segment two small; discarding');
                activityStart(end) = i+1;
            elseif i - activityStart(end) > max_window_size
                % Do something to split the data up so is smaller than
                % max_window_size
                length = i - activityStart(end);
                num_windows = floor(length/max_window_size);
                min_window_size = floor(length/num_windows);
                
                for j = 1:num_windows
                    activityType(end+1) = currLabel;
                    activityStart(end+1) = activityStart(end) + min_window_size;
                    output{end+1} = input(activityStart(end-1):activityStart(end)-1, :);
                end
            else
                activityType(end+1) = currLabel;
                activityStart(end+1) = i+1;

                output{end+1} = input(activityStart(end-1):activityStart(end)-1, :);
            end
            
            
        end
    end
end

