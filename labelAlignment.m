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
function [labelOut] = labelAlignment(data, label, hs, enableplot)
    if nargin < 4
        enableplot = false;
    end

    ix_new = zeros(length(label.time_row), 1);
    for i = 1:length(label.time_row)
        [~, ix_new(i)] = min(abs(hs - label.time_row(i)));
    end
    ix_new = hs(ix_new);
    
    labelOut.label = label.label;
    labelOut.time_row = ix_new;
    labelOut.time = data(1).time(ix_new);

    % Debug plot
    if enableplot
        figure;
        axes;
        ylim([-600, 600]);
        hold all
        
        rAnkleRow = strcmp({data.friendly}, 'r_ankle');
        lAnkleRow = strcmp({data.friendly}, 'l_ankle');
        gyroYR = data(rAnkleRow).gyro(:, 3);
        gyroYL = data(lAnkleRow).gyro(:, 3);
        
        plot(data(1).time, gyroYL)
        plot(data(1).time, -gyroYR)
        
        plot(data(1).time(hs), gyroYR(hs), 'xr')
        
        for i = label.time
            plot([i, i], [500, -500], 'g:');
        end

        for i = labelOut.time
            plot([i, i], [500, -500], 'r:');
        end
        hold off
    end

end

% EOF
