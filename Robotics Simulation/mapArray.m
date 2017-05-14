function [ mapArray ] = mapArray( map )
%% this function is copyed from EXAMPLE?insideMap.m
botSim = BotSim(map);  %sets up a botSim object a map, and debug mode on.

limsMin = min(map); % minimum limits of the map
limsMax = max(map); % maximum limits of the map
dims = limsMax-limsMin; %dimension of the map
res = 5; %sampling resouloution in cm
iterators = dims/res;
iterators = ceil(iterators)+[1 1]; %to counteract 1 based indexing
mapArray = zeros(iterators); %preallocate for speed
%loops through the grid indexes and tests if they are inside the map
for i = 1:iterators(2)
    for j = 1:iterators(1)
        testPos = limsMin + [j-1 iterators(2)-i-1]*res; %to counteract 1 based indexing
        %notice, that i and j have also been swapped here so that the only
        %thing left to do is invert the y axis.
        mapArray(i,j) = botSim.pointInsideMap(testPos);
    end
end

end

