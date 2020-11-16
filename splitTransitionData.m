% splitTransitionData - Short description
% Long description
%
% Inputs: 
%   dataTable - description
%   label -
%   hs -
%   debugPlots -
%
% Outputs:
%   output - description
%   stats -
%
% Other m-files required: convertLabel
% Subfunctions: none
% MAT-files required: none
%
% See also: readData, labelAlignment, identifyHeelStrike, postProcessData
%
% Author: Freddie Sherratt
% University of Bath
% email: F.W.Sherratt@bath.ac.uk
% Website: fsherratt.dev
% Sep 2018; Last revision: 30-Jan-2020

function [output, stats] = splitTransitionData(dataTable, label, hs, debugPlots)
    Config.TransitionSteps = 2;
    
    Config.Valid.StepsBeforeTransition = 2;
    Config.Valid.StepsAfterTransition = 2;
    
    Config.Split.StepsBeforeTransition = 6;
    Config.Split.StepsAfterTransition = 6;
    
    
    walking = convertLabel('walking');
    stairD = convertLabel('stair_down');
    stairA = convertLabel('stair_up');
    rampA = convertLabel('ramp_up');
    rampD = convertLabel('ramp_down');
    stop = convertLabel('stop');
    tran = convertLabel('tran');

    % Find transition points
    transitionPoints = [];
    transitionType = [];
    for i = 2:length(label.label)-1
        currLabel = label.label(i);
        nextLabel = label.label(i+1);

        % Disables transition labelling
        if (currLabel ~= nextLabel)
            transitionType(end+1) = tran;
        else
            continue;
        end
        
        fprintf('Transition @ time: %0.2fs\trow: %d\n', label.time(i+1), label.time_row(i+1));
        fprintf('%s (%d) -> %d -> %s (%d)\n', convertLabel(label.label(i)), label.label(i), transitionType(end), convertLabel(label.label(i+1)), label.label(i+1));

        transitionPoints(end+1) = i+1;
    end


    % Find heelstrikes
    hs = sort(hs);

    transitionHsIx = [];
    for i = transitionPoints
        time = label.time_row(i);
        [~, transitionHsIx(end+1)] = min(abs(time-hs));
    end
    
    tranInRange = and(and(transitionHsIx + Config.Split.StepsAfterTransition < length(hs), ...
                  transitionHsIx - Config.Split.StepsBeforeTransition - Config.TransitionSteps > 0), ...
                  and(transitionPoints - 1 > 0, ...
                  transitionPoints + 1 < length(label.time_row)));
              
    transitionPoints = transitionPoints(tranInRange);
    transitionHsIx = transitionHsIx(tranInRange);

    % Check that x steps of activity occur either side of transition
    prevLabel = label.time_row(transitionPoints-1);
    nextLabel = label.time_row(transitionPoints+1);
    startIx = hs(transitionHsIx - Config.Valid.StepsBeforeTransition - Config.TransitionSteps);
    endIx = hs(transitionHsIx + Config.Valid.StepsAfterTransition);
    
    split_startIx = hs(transitionHsIx - Config.Split.StepsBeforeTransition - Config.TransitionSteps);
    split_endIx = hs(transitionHsIx + Config.Split.StepsAfterTransition);

    valid = (prevLabel < startIx) & (nextLabel > endIx);

    ValidTransitionHsIx = transitionHsIx(valid);
    splitStart = split_startIx(valid);
    splitEnd = split_endIx(valid);
    
    % Add in transition label for step(s) preceeding tansition point
    startTransitionRow = hs(transitionHsIx - Config.TransitionSteps);
    endTransitionRow = hs(transitionHsIx);
    
%     transitionType = transitionType(valid);

    for i = 1:length(startTransitionRow)
        dataTable.activity(startTransitionRow(i):endTransitionRow(i)) = transitionType(i);
        
        stats(i) = struct('Pre_Steps', Config.Split.StepsBeforeTransition, ...
                          'Tran_Steps', Config.TransitionSteps, ...
                          'Post_Steps', Config.Split.StepsAfterTransition, ...
                          'Tran_type', transitionType(i), ...
                          'Pre_samples', startTransitionRow(i) - split_startIx(i), ...
                          'Tran_samples', endTransitionRow(i) - startTransitionRow(i), ...
                          'Post_samples', split_endIx(i) - endTransitionRow(i));
    end
    
    if ~exist('stats' ,'var')
        stats = [];
    else
        stats = stats(valid);
    end

    
    
    if debugPlots
        figure;
        axes;
        ylim([-300, 400]);
        hold all;

        plot(dataTable.time, -dataTable.r_ankle_gyro_z);
        plot(dataTable.time, dataTable.l_ankle_gyro_z)
        yyaxis right
        plot(dataTable.time, dataTable.activity);
    end


    % Store new table segment
    output = {};
    for i = 1:length(splitStart)
        output{end+1} = dataTable(splitStart(i):splitEnd(i), :);

        if debugPlots
            figure;
            axes;
            ylim([-300, 400]);
            hold all;

            plot(output{i}.time, -output{i}.r_ankle_gyro_z);
            plot(output{i}.time, output{i}.l_ankle_gyro_z)
            yyaxis right
            plot(output{i}.time, output{i}.activity);
        end
    end
end
        