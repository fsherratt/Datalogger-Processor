% convertLabel - Interpret acitivites json list
% Converts between activity text and index from a JSON list
%
% Inputs: 
%   label - Either activity string or index to be converted
%   activityFile - Activity list JSON file, if empty uses default "activities.json" file
%
% Outputs:
%   output - Converted activity, if string input index output and vice versa
%
% Other m-files required: None
% Subfunctions: None
% MAT-files required: None 
%
% See also: readDataLabels
%
% Author: Freddie Sherratt
% University of Bath
% email: F.W.Sherratt@bath.ac.uk
% Website: fsherratt.dev
% Sep 2018; Last revision: 30-Jan-2020

function [output] = convertLabel(label, activityFile)
    if nargin < 2 || isempty(activityFile)
        activityFile = "activities.json";
    end
    
    fileData = fileread( activityFile );
    activites = jsondecode(fileData);
    
    if isnumeric(label)
        activity_map = containers.Map(1:size(activites, 1), activites);
    else
        activity_map = containers.Map(activites, 1:size(activites, 1));
    end
    
    output = activity_map(label);   
end
