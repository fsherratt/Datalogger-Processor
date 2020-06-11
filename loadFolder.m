%{
% Load Folder - Identifty all data files in folder
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
function [returnList] = loadFolder (DataFolder)
    if nargin < 1 || isempty(DataFolder)
        warning('loadFolder: No folder specified, using current working directory');
        DataFolder = '';
    end
    
    if ~endsWith(DataFolder, {'/', '\'})
        warning('loadFolder: Folder missing trailing slash. A slash has been automatically added');
        DataFolder = [DataFolder, '/'];
    end
    
    % Load all data from specified folder
    fileList = dir([DataFolder, '*.txt']);
    dataFiles = {};
    labelFiles = {};

    for i = 1:length(fileList)
        fileName = [fileList(i).folder, '\', fileList(i).name];
        if ( ~startsWith([fileList(i).name], 'Log') )
            continue;
        end
        
        if ( endsWith([fileList(i).name], '_label.txt') )
            labelFiles{end+1} = fileName;
        else
            dataFiles{end+1} = fileName;
        end
    end
    
    returnList = struct('data', {}, 'label', '');    
    
    % Combine data and label set
    for i = 1:length(dataFiles)
        [~, data_file, ~] = fileparts(dataFiles{i});
        
        returnList(end+1) = struct('data', dataFiles{i}, 'label', '');
        
        for j = 1:length(labelFiles)
            [~, label_file, ~] = fileparts(labelFiles{j});
            
            if strcmp(label_file, [data_file, '_label'])
                % Found matchin label and data sets
                returnList(end).label = labelFiles{j};
            end
        end
    end

end

% EOF
