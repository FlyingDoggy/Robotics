function map = inflateMap( map, iteration, iterators )

inflatedMap = map;
for it = 1:iteration
    for i = 1:iterators(2)
        inflatedMap(i,1) = 0;
        inflatedMap(i,iterators(1)) = 0;
    end
    for j = 1:iterators(1)
        inflatedMap(1,j) = 0;
        inflatedMap(iterators(2),j) = 0;
    end
    for i = 2:iterators(2)-1
        for j = 2:iterators(1)-1
            if map(i-1,j) == 0 || map(i+1,j) == 0 || map(i,j-1) == 0 || map(i,j+1) == 0 || map(i-1,j-1) == 0 || map(i-1,j+1) == 0 || map(i+1,j-1) == 0 || map(i+1,j+1) == 0
                inflatedMap(i,j) = 0;
            end
        end
    end
    map = inflatedMap;
end

end

