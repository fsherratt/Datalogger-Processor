% Load Data
DataFolder = 'Data/Stair_Test/';

[dataSet, labelSet] = loadFolder(DataFolder);
labelSet = lableAlignment(dataSet, labelSet, true);

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
function [adjustedLabelSet] = lableAlignment(dataSet, labelSet, enableplot)
    if nargin < 3
        enableplot = false;
    end

    % Plot gyro
    time = dataSet.data(1).time;

    rAnkleRow = strcmp({dataSet.data.friendly}, 'Right Ankle');
    lAnkleRow = strcmp({dataSet.data.friendly}, 'Left Ankle');

    aMagR = vecnorm(dataSet.data(rAnkleRow).accel,2,2);
    gyroYR = -dataSet.data(rAnkleRow).gyro(:, 3);
    aMagL = vecnorm(dataSet.data(lAnkleRow).accel,2,2);
    gyroYL = dataSet.data(lAnkleRow).gyro(:, 3);

    if enableplot
        figure;
        axes;
        hold all
        
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

    % Process labels
    ix = zeros(length(labelSet.time), 1);
    for i = 1:length(labelSet.time)
    % Find index of label
        [~, ix(i)] = min(abs(time - labelSet.time(i)));
    end


    % Plot label locations
    if enableplot
        for i = ix
            plot([time(i), time(i)], [500, -500], 'g:');
        end
        ylim([-300, 400]);
    end


    % Adjust label locations - Align to closest heel strike (measured in time)
    hs = [hsR, hsL];
    ix_new = zeros(length(ix), 1);
    for i = 1:length(ix)
        [~, ix_new(i)] = min(abs(hs - ix(i)));
    end
    ix_new = hs(ix_new);

    adjustedLabelSet = labelSet;
    adjustedLabelSet.timeRow = ix_new;
    adjustedLabelSet.time = time(ix_new);

    % Plot new label locations
    if enableplot
        for i = ix_new
            plot([time(i), time(i)], [500, -500], 'r:');
        end
    end
    hold off
end

function [hs] = identifyHeelStrike(aMag, gyroY)
    [~, gyro_locs] = findpeaks(gyroY, ...
                        'MinPeakProminence', 1, ...
                        'MinPeakHeight', 100, ...
                        'MinPeakDistance', 30 );

    [~, accel_locs] = findpeaks(aMag, ...
                        'MinPeakProminence', 5, ...
                        'MinPeakHeight', 12, ...
                        'MinPeakDistance', 10 );

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

