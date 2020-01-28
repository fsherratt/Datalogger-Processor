function [output, stats] = splitTransitionData(dataTable, label, hs, debugPlots)
    StepsBeforeTransition = 7;
    TranstionSteps = 10;
    StepsAfterTransition = 5;
    
    stats = [];

    walking = convertLabel('walking');
    stairD = convertLabel('stair_down');
    stairU = convertLabel('stair_up');


    % Find transition points
    transitionPoints = [];
    for i = 2:length(label.label)-1
        currLabel = label.label(i);
        nextLabel = label.label(i+1);
        if (currLabel == walking && nextLabel == stairD ) ...
                || (currLabel == walking && nextLabel == stairU ) ...
                || (currLabel == stairU  && nextLabel == walking ) ...
                || (currLabel == stairD  && nextLabel == walking )
            fprintf('Transition @ time: %0.2fs\trow: %d\n', label.time(i+1), label.time_row(i+1));
            fprintf('%s (%d) -> %s (%d)\n', convertLabel(label.label(i)), label.label(i), convertLabel(label.label(i+1)), label.label(i+1));

            transitionPoints(end+1) = i+1;
        end
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
    startIx = hs(transitionHsIx - StepsBeforeTransition);
    endIx = hs(transitionHsIx + StepsAfterTransition);

    valid = (prevLabel < startIx) & (nextLabel > endIx);

    ValidTransitionHsIx = transitionHsIx(valid);
    splitStart = startIx(valid);
    splitEnd = endIx(valid);


    % Add in transition label for step preceeding tansition point
    startTransitionHsRow = hs(ValidTransitionHsIx - TranstionSteps);
    endTransitionRow = hs(ValidTransitionHsIx);

    for i = 1:length(startTransitionHsRow)
        dataTable.activity(startTransitionHsRow(i):endTransitionRow(i)) = 10;
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
        