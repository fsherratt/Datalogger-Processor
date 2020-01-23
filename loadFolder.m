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
function [dataSet, labelSet] = loadFolder (DataFolder, DataHeader, applyCalibration)
    % Load all data from specified folder
    if nargin < 2 || isempty(DataHeader)
        DataHeader = 'Data\data_structure.json';
    end
    
    if nargin < 3
        applyCalibration = false;
    end

    fileList = dir([DataFolder, '*.txt']);
    dataSet = struct('data', {}, 'file', '');
    labelSet = struct('time', {}, 'label', [], 'file', '');
    headerStruct = readHeader(DataHeader);

    for i = 1:length(fileList)
        fileName = [fileList(i).folder, '\', fileList(i).name];

        if ( endsWith([fileList(i).name], '_label.txt') )
            [time, label] = readDataLabels(fileName);

            labelSetRow.time = time;
            labelSetRow.label = label;
            labelSetRow.file = fileList(i).name;

            labelSet(end+1) = labelSetRow;
        else
            fileName = [fileList(i).folder, '\', fileList(i).name];

            [~, split] = readData(fileName, headerStruct);
            dataSetRow.data = preProcessDataFile(split, headerStruct, applyCalibration);
            dataSetRow.file = fileList(i).name;

            dataSet(end+1) = dataSetRow;
        end
    end

end

% EOF
