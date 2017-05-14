function gridCoord = realMapToGridMap(realMapCoord, res, limsMin, limsMax)
% Top left corner of map in map coord
topLeft = [limsMin(1), limsMax(2)];

% Point from top left in map coord
coordFromTopLeft = round((realMapCoord - topLeft) / res);

% Swap x and y, flip y, and add 1
gridCoord = [-coordFromTopLeft(2), coordFromTopLeft(1)] + [1, 1];

%     gridCoord = floor([limsMax(2) - realMapCoord(2), realMapCoord(1) - limsMin(1)] / res) + [1, 1];
end