function [converged, meanPos, meanAng] = checkConvergence(particles, num)
convergeThreshold = 4;
converged = 0;

insideCount = 0;
for i = 1:num
    if particles(i).insideMap()
        insideCount = insideCount + 1;
    end
end

% Get particle positions and angles
posArray(insideCount, :) = [0, 0];
angArray(insideCount, :) = 0;
j = 1;
for i = 1:num
    if particles(i).insideMap()
        posArray(j, :) = particles(i).getBotPos();
        angArray(j, :) = wrapTo2Pi(particles(i).getBotAng());
        j=j+1;
    end
end

% Use interquatile range as a measure of deviation
deviation = iqr(posArray);
if deviation < convergeThreshold
    converged = 1;
end

% Estimate the robot position and angle
meanPos = median(posArray);
meanAng = median(angArray);
end