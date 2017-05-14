function [ arrayMap ] = resizeMap( arrayMap )
%% this function is used to small the map therefore avoid collision
%if one of the neighbors of the current grid is 0, set the current grid to 0
[row,col] = size(arrayMap);
tempMap = zeros(row,col);
for i = 2: row-1
    for j = 2:col-1
        findZero = 0;
        for x = i-1:i+1
            for y = j-1:j+1
                if arrayMap(x,y) == 0
                    tempMap(i,j) = 0;
                    findZero = 1;
                    break;
                end
            end
            if findZero == 1
                break;
            end
        end
        if findZero == 0
            tempMap(i,j) = 1;
        end
    end
end
arrayMap = tempMap;
end

