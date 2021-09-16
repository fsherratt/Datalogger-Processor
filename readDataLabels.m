%{
% Function name - Short description
% Long description
%
% Inputs:
%   var1 - description
%
% Outputs:
%   rtn1 - description
%
% Other m-files required:
% Subfunctions:
% MAT-files required:
%
% See also: fcn2
%
% Author: Freddie Sherratt
% University of Bath
% email: F.W.Sherratt@bath.ac.uk
% Website: fsherratt.dev
% Sep 2018; Last revision: 22-Jan-2020
%}
function [output, data_end, data_start] = readDataLabels(filename, frequency)
    fileID = fopen(filename,'r');

    formatSpec = '%f%C%[^\n\r]';
    dataArray = textscan(fileID, formatSpec, 'Delimiter', ',', 'TextType', 'string',  'ReturnOnError', false);

    fclose(fileID);

    timestamp = dataArray{:, 1};
    text_label = cellstr(dataArray{:, 2});

    % Convert to seconds from starta
    timestamp = timestamp - timestamp(1);
    timestamp = timestamp ./ 1000;

    % Convert from strings to numerical list
    output = struct('time', [], 'label', [], 'time_row', []);
    data_end = struct('time', [], 'time_row', []);
    data_start = struct('time', [], 'time_row', []);

    for i = 1:size(text_label,1)
        if strcmp(text_label{i}, 'START')
            data_start.time(end+1) = timestamp(i);
            data_start.time_row(end+1) = floor(timestamp(i)*frequency) + 1;
            
        elseif strcmp(text_label{i}, 'END')
            data_end.time(end+1) = timestamp(i);
            data_end.time_row(end+1) = floor(timestamp(i)*frequency);
            
        else
            output.time(end+1) = timestamp(i);
            output.time_row(end+1) = floor(timestamp(i)*frequency);
            output.label(end+1) = convertLabel(text_label{i});
        end
    end

 % Allow for clipping of data in label file
 if length(data_end.time) > 1 
    data_end = struct('time', data_end.time(1), 'time_row', data_end.time_row(1));
 end
 
 if length(data_start.time) > 1 
    data_start = struct('time', data_start.time(end), 'time_row', data_start.time_row(end));
 end
    
end