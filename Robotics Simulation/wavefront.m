function [ wavefrontMapArray ] = wavefront( map,mapArray,target,res )
%WAVEFRONT Summary of this function goes here
%   Detailed explanation goes here
%% this function is used to generate the wavefront map
wavefrontMapArray = mapArray;
[m,n] = size(wavefrontMapArray);%get the size of array map
target = convertCoor(map,target,res);
queue(1,:) = target;%store target at the start of the queue

wavefrontMapArray(target(2),target(1)) = 2;%set the value of the grid to 2 where target is in
i = 1;
while i <= size(queue,1)
    pos = queue(i,:);
    for x = pos(1,1)-1:pos(1,1)+1
        for y = pos(1,2)-1:pos(1,2)+1
            if x > 0 && y > 0 && x < n && y < m && wavefrontMapArray(y,x)==1 %check if within the range
                wavefrontMapArray(y,x) = wavefrontMapArray(pos(2),pos(1))+1;%assign weight and cost to neighbors
                queue = [queue ; [x,y]];
            end
        end
    end
    i =i+1;
end
end
