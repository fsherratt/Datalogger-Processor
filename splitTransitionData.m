% splitTransitionData - Short description
% Long description
%
% Inputs: 
%   dataTable - description
%   label - data labels
%   hs - heel strike indexes
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

function output = splitTransitionData(dataTable, label, hs, debugPlots)
    % Find transition points
    transitionPoints = [];
    transitionType = [];
    for i = 2:length(label.label)-1
        currLabel = label.label(i);
        nextLabel = label.label(i+1);

        % Disables transition labelling
        if (currLabel ~= nextLabel)
            transitionType(end+1) = convertLabel('tran');
            transitionPoints(end+1) = i+1;

            fprintf('Transition @ time: %0.2fs\trow: %d\n', label.time(i+1), label.time_row(i+1));
            fprintf('%s (%d) -> %d -> %s (%d)\n', convertLabel(label.label(i)), label.label(i),...
                transitionType(end), convertLabel(label.label(i+1)), label.label(i+1));

        end
    end
    
    tranHsIx = zeros(1, size(transitionPoints, 2));
    for i = 1:size(transitionPoints, 2)
        [~, tranHsIx(i)] = min(abs(hs - label.time_row(transitionPoints(i))));
    end
    
    max_tran_len = 50;
    for i = 1:size(tranHsIx, 2)
        tran_start = hs(tranHsIx(i)) - max_tran_len;
        tran_end = hs(tranHsIx(i)) + max_tran_len;
%         try
%             tran_start = hs(tranHsIx(i)-1);
%             if hs(tranHsIx(i)) - tran_start > max_tran_len
%                 tran_start = hs(tranHsIx(i)) - max_tran_len;
%             end
%         catch
%             tran_start = hs(tranHsIx(i));
%         end
%         
%         try
%             tran_end = hs(tranHsIx(i)+1);
%             if tran_end - hs(tranHsIx(i)) > max_tran_len
%                 tran_end = hs(tranHsIx(i)) + max_tran_len;
%             end
%         catch
%             tran_end = hs(tranHsIx(i));
%         end
        
        dataTable.activity(tran_start:tran_end) = transitionType(i);
    end
    
    if debugPlots
        figure;
        plot(dataTable.activity);
        hold all
        plot(dataTable.r_ankle_gyro_y);
        hold off
    end
    
    output{1} = dataTable;
end
        