function [output] = convertLabel(label)
    fileData = fileread( "activities.json" );
    activites = jsondecode(fileData);
    
    if isnumeric(label)
        activity_map = containers.Map(1:size(activites, 1), activites);
    else
        activity_map = containers.Map(activites, 1:size(activites, 1));
    end
    
    output = activity_map(label);   
end
