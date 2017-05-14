function [ outputCoor ] = convertCoor(map, originCoor,res )
%% this function is used to convert the coordinates of map to the map array coordinates
limsMin = min(map); % minimum limits of the map
limsMax = max(map); % maximum limits of the map
outputCoor = round((originCoor -[limsMin(1),limsMax(2)])/res);
outputCoor = [outputCoor(1),-outputCoor(2)]+[1,1];
end

