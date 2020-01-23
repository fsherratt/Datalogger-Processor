% Calibrate sensors
enablePlot = false;
DataFolder = 'Data\Calibration\';

[dataSet, labelSet] = loadFolder(DataFolder, [], false);

for i = 1:size(dataSet, 2)
    startPoints = find(labelSet(1).label == 5);
    endPoints = find(labelSet(1).label == 6);
    
    if (length(startPoints) ~= length(endPoints) )
        warning('Label file incomplete');
        continue;
    end
    
    for j = 1:size(dataSet(i).data, 2)
        
        accelExtreme = zeros(2, 3);
        gyroOffset = 0;
        
        if enablePlot
            figure;
            plot(dataSet(i).data(j).time, dataSet(i).data(j).accel);
            hold all
        end

        for k = 1:length(startPoints)
            % Find closest data row
            sTime = labelSet(i).time(startPoints(k));
            eTime = labelSet(i).time(endPoints(k));
            [~, sPoint] = min(abs(sTime - dataSet(i).data(j).time));
            [~, ePoint] = min(abs(eTime - dataSet(i).data(j).time));
            
            if enablePlot
                plot(dataSet(1).data(j).time(sPoint), 5, 'x');
                plot(dataSet(1).data(j).time(ePoint), 6, 'o');
            end

            accelMean = mean(dataSet(i).data(j).accel(sPoint:ePoint, :));
            gyroOffset = gyroOffset + mean(dataSet(i).data(j).gyro(sPoint:ePoint, :));
            
            [aMax, iMax] = max(accelMean);
            [aMin, iMin] = min(accelMean);

            if ( aMax > abs(aMin) )
                accelExtreme(1, iMax) = aMax;
            else
                accelExtreme(2, iMin) = aMin;
            end
        end
        % Calculate adjustments
        gyroOffset = -gyroOffset ./ length(startPoints);
        
        accelScale = accelExtreme(1, :) - accelExtreme(2, :);
        accelScale = (9.81 * 2) ./ accelScale;
        
        accelExtreme = accelExtreme .* accelScale;
        
        accelOffset = 9.81 - accelExtreme(1, :);
        
        % Generate calibration JSON
        fprintf(['"address": "%s",\n'...
                 '"name": "%s",\n'...
                 '"x_accel_offset": %f,\n'...
                 '"x_accel_scale": %f,\n'...
                 '"y_accel_offset": %f,\n'...
                 '"y_accel_scale": %f,\n'...
                 '"z_accel_offset": %f,\n'...
                 '"z_accel_scale": %f,\n'...
                 '"x_gyro_offset": %f,\n'...
                 '"y_gyro_offset": %f,\n'...
                 '"z_gyro_offset": %f\n\n'], ...
                 dataSet(i).data(j).name, ...
                 dataSet(i).data(j).friendly, ...
                 accelOffset(1), accelScale(1), ...
                 accelOffset(2), accelScale(2), ...
                 accelOffset(3), accelScale(3), ...
                 gyroOffset(1), gyroOffset(2), gyroOffset(3));
    end
end

clear i j k startPoints endPoints sTime eTime sPoint ePoint accelMean aMax iMax aMin iMin accelExtreme