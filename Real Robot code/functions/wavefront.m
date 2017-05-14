function grid = wavefront(grid, iterators, target)
% Starting point as 2
grid(target(1), target(2)) = 2;

% Set up queue for fringes
queue(1:2, iterators(1) * iterators(2)) = [0, 0];
queue(:, 1) = target;
front = 1;
tail= 2;

% up, down, left, right, top-right, bottom-right, bottom-left, top-left
dir = [-1,0; 1,0; 0,-1; 0,1; -1,1; 1,1; 1,-1; -1,-1];

% Loop to fill in grid
while front ~= tail
    coord = queue(:, front);
    front = front + 1;
    
    for i = 1:8
        adj = coord + [dir(i, 1); dir(i, 2)];
        
        % ignore points outside map
        if adj(1) < 1 || adj(2) < 1 || adj(1) > iterators(2) || adj(2) > iterators(1)
            continue;
        end
        
        if grid(adj(1), adj(2)) == 1
            grid(adj(1), adj(2)) = grid(coord(1), coord(2)) + 1;
            queue(:, tail) = adj;
            tail = tail + 1;
        end
    end
end
end