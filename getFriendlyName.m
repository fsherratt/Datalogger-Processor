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
function [name] = getFriendlyName(deviceAddress)
    fileData = fileread( "deviceInfo.json" );
    deviceInfo = jsondecode(fileData);

    deviceNames = containers.Map({deviceInfo.address}, {deviceInfo.name}); 
    
    try
        name = deviceNames(deviceAddress);
    catch
        name = 'Unknown';
    end
end

