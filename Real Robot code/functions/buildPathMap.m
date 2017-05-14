function mapArray = buildPathMap(botSim, map, target)
% Map limits
limsMin = min(map);
limsMax = max(map);
% Map dimentions and resultion (cm)
res = 5;
dims = limsMax-limsMin;
% Grid iterator
iterators = dims/res;
iterators = ceil(iterators)+[1 1]; % to counteract 1 based indexing

% Preallocate for speed
mapArray(iterators(2), iterators(1)) = 0;

% Loops through the grid indexes and tests if they are inside the map
for i = 1:iterators(2)
    for j = 1:iterators(1)
        testPos = limsMin + [j-1 iterators(2)-i-1] * res;
        mapArray(i,j) = botSim.pointInsideMap(testPos);
    end
end

mapArray = inflateMap(mapArray, 2, iterators);

% Fill in grid
gridTarget = realMapToGridMap(target, res, limsMin, limsMax);
mapArray = wavefront(mapArray, iterators, gridTarget);
end