function move = moveBlindly(bot, scanDist, particles, num)
    % Move
    scanFront = bot.scanFront();
    if scanFront ~= -1 && scanFront > 21
        move = scanFront - 20;
        bot.move(move);
        for i = 1:num
            particles(i).move(move);
        end
    else
        move = 0;
    end
    
    % Turn
    if scanDist(4) > 40
        turn = -pi/2;
        bot.turn(turn);
        for i = 1:num
            particles(i).turn(turn);
        end
    elseif scanDist(2) > 40
        turn = pi/2;
        bot.turn(turn);
        for i = 1:num
            particles(i).turn(turn);
        end
    else
        turn = 0;
    end
    
    if turn == 0 && move == 0
        turn = pi;
        bot.turn(turn);
        for i = 1:num
            particles(i).turn(turn);
        end
    end
end