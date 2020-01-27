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
function [table] = postProcessData(data, label)
    % Combine each sensors data into a single table

    % Table headings
    sensors = {data.friendly};
    dataFields = {'accel_x', 'accel_y', 'accel_z', 'gyro_x', 'gyro_y', 'gyro_z', 'magn_x', 'magn_y', 'magnz'};
    tableHeader = {'time'};
    for j = 1:length(sensors)
        for k = 1:length(dataFields)
            tableHeader = [tableHeader, [sensors{j}, '_', dataFields{k}]];
        end
    end

    % Table data
    tableData = [data(1).time];
    for j = 1:length(data)
        dataRow = data(j);
        tableData = [tableData, dataRow.accel, dataRow.gyro, dataRow.magn];
    end

    % Activity labels
    tableHeader = [tableHeader, 'activity'];
    labelColumn = zeros(length(tableData), 1);
    for i = 1:length(label.label)-1
        if i == 1
            labelColumn(1:label.time_row(i+1)) = label.label(i);
        elseif i == length(label.label)-1
            labelColumn(label.time_row(i):end) = label.label(i);
        else
            labelColumn(label.time_row(i):label.time_row(i+1)) = label.label(i);
        end
    end
    tableData = [tableData, labelColumn];

    % Convert to data table
    table = array2table(tableData, 'VariableNames', tableHeader);
end
