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
% Adjust label locations - Align to closest heel strike (measured in time)
function [hs, ps] = identifyHeelStrike(data, ankle_friendly_name)
    hs = [];
    ankleRow = strcmp({data.friendly}, ankle_friendly_name);
    
    if ankleRow == 0
        warning('No heel strikes fround for %s', ankle_friendly_name)
        return
    end
    
    aMag = vecnorm(data(ankleRow).accel, 2, 2);
    gyroY = data(ankleRow).gyro(:, 2);
     
    if (skewness(gyroY) < 0)
            gyroY = -gyroY;
    end

    [~, gyro_locs] = findpeaks(gyroY, ...
                        'MinPeakProminence', 10, ...
                        'MinPeakHeight', 100, ...
                        'MinPeakDistance', 30 );

    [~, accel_locs] = findpeaks(aMag, ...
                        'MinPeakProminence', 7, ...
                        'MinPeakHeight', 15, ...
                        'MinPeakDistance', 30 );

    % Each HS should be an accleration peak preceded by a leg swing
    hs = [];
    ps = [];
    for i = 1:length(gyro_locs)
        tmp = accel_locs( accel_locs > gyro_locs(i) );

        if ~isempty(tmp)
            if ( tmp(1) - gyro_locs(i) ) < 100 % 1 second (100Hz) timeout
                hs(end+1) = tmp(1);
                ps(end+1) = gyro_locs(i);
            end
        end
    end
end