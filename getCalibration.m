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
function [calib] = getCalibration(deviceAddress)
    fileData = fileread( "deviceInfo.json" );
    deviceInfo = jsondecode(fileData);

    deviceNames = containers.Map({deviceInfo.address}, 1:size(deviceInfo, 1)); 
    
    try
        row = deviceNames(deviceAddress);
        calib = deviceInfo(row);
        
        calib = rmfield(calib, {'address', 'name'});
    catch
        calib = null(1);
    end
end

% EOF
