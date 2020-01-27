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
function [output] = readDataLabels(filename, frequency)
    fileID = fopen(filename,'r');

    formatSpec = '%f%C%[^\n\r]';
    dataArray = textscan(fileID, formatSpec, 'Delimiter', ',', 'TextType', 'string',  'ReturnOnError', false);

    fclose(fileID);

    timestamp = dataArray{:, 1};
    text_label = cellstr(dataArray{:, 2});

    % Convert to seconds from starta
    timestamp = timestamp - timestamp(1);
    timestamp = timestamp ./ 1000;

    % Convert from to numerical list
    fileData = fileread( "activities.json" );
    activites = jsondecode(fileData);
    activity_number = containers.Map(activites, 1:size(activites, 1));

    output = struct('time', [], 'label', [], 'time_row', []);

    for i = 1:size(text_label,1)
        if ~strcmp(text_label{i}, {'START', 'END'})
            output.time(end+1) = timestamp(i);
            output.time_row(end+1) = floor(timestamp(i)*frequency);
            output.label(end+1) = activity_number(text_label{i});
        end
    end
end