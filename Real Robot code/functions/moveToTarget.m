function move = moveToTarget(map, bot, pos, ang, grid, particles, num)
    limsMin = min(map);
    limsMax = max(map);
    res = 5;
    dims = limsMax-limsMin;
    iterators = dims/res;
    iterators = ceil(iterators)+[1 1];
    coord = realMapToGridMap(pos, res, limsMin, limsMax);

    if (coord(1) < 0 || coord(2) < 0 || coord(1) > iterators(2) || coord(2) > iterators(1))
        disp('Something went wrong!')
    end

    % up, down, left, right, top-right, bottom-right, bottom-left, top-left
    dir = [-1,0; 1,0; 0,-1; 0,1];
    targetAng = [pi/2, 3*pi/2, pi, 0];
    
    if ang >= 0
        ang = wrapTo2Pi(ang);
    else
        ang = -wrapTo2Pi(abs(ang));
    end
    
    if ang > pi
        ang = -(2*pi - ang);
    elseif ang < -pi
        ang = -(-2*pi - ang);
    end
    
    if ang >= pi/4 && ang < 3*pi/4
        ang = targetAng(1);
    elseif ang <= -pi/4 && ang > -3*pi/4
        ang = targetAng(2);
    elseif (ang >= 3*pi/4 && ang <= pi) || (ang <= -3*pi/4 && ang >= -pi)
        ang = targetAng(3);
    else
        ang = targetAng(4);
    end

    maxMove = 100;
    move = 0;

    for i = 1:4
        % Each of eight directions
        adj = coord + dir(i, :);
    
        % Ignore points outside map
        if adj(1) < 1 || adj(2) < 1 || adj(1) > iterators(2) || ...
                adj(2) > iterators(1) || grid(adj(1), adj(2)) == 0
            continue;
        end
    
        % Pick a direction in grid
        if grid(coord(1), coord(2)) == 0 || ...
                grid(adj(1), adj(2)) < grid(coord(1), coord(2))
            % Turn to the chosen direction
            turn = targetAng(i) - ang;
            bot.turn(turn);
            for j =1:num
                particles(j).turn(turn);
            end
        
            % Calculate distance to move
            move = res;
            for m = 1:max(iterators(1), iterators(2))
                adjNext = adj + dir(i, :);
                if adjNext(1) < 1 || adjNext(2) < 1 || adjNext(1) > iterators(2) || ...
                        adjNext(2) > iterators(1) || grid(adjNext(1), adjNext(2)) == 0
                    break;
                end
                if grid(adjNext(1), adjNext(2)) < grid(adj(1), adj(2))
                    move = move + res;
                    adj = adjNext;
                else
                    break;
                end
            end
        
            % Move
            ScanDistance = bot.scanFront();
            move = min(min(move, maxMove), floor(ScanDistance) - 20);
            if move > 0
                bot.move(move);
                for j =1:num
                    particles(j).move(move);
                end
            else
                move = 0;
            end
        
            % Ignore other directions
            break;
        end
    end
end