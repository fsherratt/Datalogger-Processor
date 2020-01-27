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
function [label] = labelAlignment(data, label, enableplot)
    if nargin < 3
        enableplot = false;
    end
    
    if enableplot
        figure;
        axes;
        hold all
    end

    for j = 1:length(label)
        %-------------------------------------------------------------------------------------------
        % Plot gyro
        time = data.time;

        % Plot label locations
        if enableplot
            for i = label.time
                plot([i, i], [500, -500], 'g:');
            end
            ylim([-300, 400]);
        end
        %----------------------------------------------------------------------

        % Adjust label locations - Align to closest heel strike (measured in time)
        rAnkleRow = strcmp({data.friendly}, 'r_ankle');
        lAnkleRow = strcmp({data.friendly}, 'l_ankle');

        aMagR = vecnorm(data(rAnkleRow).accel,2,2);
        gyroYR = data(rAnkleRow).gyro(:, 3);
        aMagL = vecnorm(data(lAnkleRow).accel,2,2);
        gyroYL = data(lAnkleRow).gyro(:, 3);

        % Invert singal where swing is a negative rotation
        if (skewness(gyroYR) < 0 && skewness(gyroYL) > 0)
            gyroYR = -gyroYR;
        else
            gyroYL = -gyroYL;
        end

        if enableplot
            plot(time, gyroYL)
            plot(time, gyroYR)
        end

        % Find heel strike
        hsR = identifyHeelStrike(aMagR, gyroYR);
        hsL = identifyHeelStrike(aMagL, gyroYL);

        if enableplot
            plot(time(hsR), gyroYR(hsR), 'xr')
            plot(time(hsL), gyroYL(hsL), 'or')
        end

        hs = [hsR, hsL];
        ix_new = zeros(length(label.time_row), 1);
        for i = 1:length(label.time_row)
            [~, ix_new(i)] = min(abs(hs - label.time_row(i)));
        end
        ix_new = hs(ix_new);

        label.time_row = ix_new;
        label.time = time(ix_new);

        % Plot new label locations
        if enableplot
            for i = ix_new
                plot([time(i), time(i)], [500, -500], 'r:');
            end
            hold off
        end
    end
end

function [hs] = identifyHeelStrike(aMag, gyroY)

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

