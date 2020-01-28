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
function [hsR, hsL] = identifyHeelStrike(data)
    rAnkleRow = strcmp({data.friendly}, 'r_ankle');
    lAnkleRow = strcmp({data.friendly}, 'l_ankle');

    aMagR = vecnorm(data(rAnkleRow).accel,2,2);
    aMagL = vecnorm(data(lAnkleRow).accel,2,2);
    
    gyroYR = data(rAnkleRow).gyro(:, 3);
    gyroYL = data(lAnkleRow).gyro(:, 3);

    % Find heel strike
    hsR = findHeelStrike(aMagR, gyroYR);
    hsL = findHeelStrike(aMagL, gyroYL);
end

function [hs] = findHeelStrike(aMag, gyroY)
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
    for i = 1:length(gyro_locs)
        tmp = accel_locs( accel_locs > gyro_locs(i) );

        if ~isempty(tmp)
            if ( tmp(1) - gyro_locs(i) ) < 100 % 1 second (100Hz) timeout
                hs(end+1) = tmp(1);
            end
        end
    end
end