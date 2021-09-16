function [output] = splitDataFile(data, max_samples)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

file_size = size(data, 1);
remaining_data = file_size;

if file_size < max_samples
    output{1} = data;
    return;
end

output = {};
start_ix = 1;
while remaining_data > 0
    if remaining_data < 0.5 * max_samples
        warning('Discarding end of data file');
        break;
    end
    
    end_ix = start_ix + max_samples;
    if end_ix > file_size
        end_ix = file_size;
    end
    
    output{end+1} = data(start_ix:end_ix-1, :);
    
    start_ix = end_ix;
    
    remaining_data = remaining_data - max_samples;
end


end
