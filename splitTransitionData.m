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
    Config.StepsBeforeTransition = 5;
    Config.TransitionSteps = 2;
    Config.StepsAfterTransition = 5;
    
    walking = convertLabel('walking');
    stairD = convertLabel('stair_down');
    stairA = convertLabel('stair_up');

    % Find transition points
    transitionPoints = [];
    transitionType = [];
    for i = 2:length(label.label)-1
        currLabel = label.label(i);
        nextLabel = label.label(i+1);
        
        if (currLabel == walking && nextLabel == stairD )
            transitionType(end+1) = convertLabel('tran_W->SD');
        elseif (currLabel == walking && nextLabel == stairA )
            transitionType(end+1) = convertLabel('tran_W->SA');
        elseif (currLabel == stairA  && nextLabel == walking )
            transitionType(end+1) = convertLabel('tran_SA->W');
        elseif (currLabel == stairD  && nextLabel == walking )
           transitionType(end+1) = convertLabel('tran_SD->W');
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


    % Check that x steps of activity occur either side of transition
    prevLabel = label.time_row(transitionPoints-1);
    nextLabel = label.time_row(transitionPoints+1);
    startIx = hs(transitionHsIx - Config.StepsBeforeTransition - Config.TransitionSteps);
    endIx = hs(transitionHsIx + Config.StepsAfterTransition);

    valid = (prevLabel < startIx) & (nextLabel > endIx);

    ValidTransitionHsIx = transitionHsIx(valid);
    splitStart = startIx(valid);
    splitEnd = endIx(valid);


    % Add in transition label for step preceeding tansition point
    startTransitionRow = hs(ValidTransitionHsIx - Config.TransitionSteps);
    endTransitionRow = hs(ValidTransitionHsIx);

    for i = 1:length(startTransitionRow)
        dataTable.activity(startTransitionRow(i):endTransitionRow(i)) = transitionType(i);
        
        stats(i) = struct('Pre_Steps', Config.StepsBeforeTransition, ...
                          'Tran_Steps', Config.TransitionSteps, ...
                          'Post_Steps', Config.StepsAfterTransition, ...
                          'Tran_type', transitionType(i), ...
                          'Pre_samples', startTransitionRow(i) - splitStart(i), ...
                          'Tran_samples', endTransitionRow(i) - startTransitionRow(i), ...
                          'Post_samples', splitEnd(i) - endTransitionRow(i));
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
        