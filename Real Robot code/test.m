addpath(genpath('functions'));

bot = Robot();
pause(0.5);
bot.setNumScan(64);
% scan = bot.scan()
scan2 = bot.scan2();
for i = 1:bot.numScan
    if scan2(i) == -1
        scan2(i) = 255;
    end
end
% hold off;
% plotScan(scan);

bot.close();

% 
% bot.numScan = 16;
% ScanDistance = bot.scan();
% for i = 1:bot.numScan
%     if ScanDistance(i) == -1
%         ScanDistance(i) = 255;
%     end
% end
% minDis = min(ScanDistance);
% ScanDistance
% index = find(ScanDistance == minDis, 1)
% ScanDistance(index)
% 
% angle = (index - 1) * 2*pi / bot.numScan
% 
% bot.turn(angle);
% 
% 
% hold off;
% plotScan(ScanDistance);

% for i=1:4

% bot.turn(-pi/4);

% end
% bot.move(5);
% bot.checkStraight()

% delta = round(365 / bot.numScan);
% bot.mScan.TachoLimit = delta;
% bot.mScan.Power = -50;
% bot.mScan.SendToNXT();
% bot.mScan.WaitFor();
% bot.mScan.Stop('brake');
% bot.scanFront()

% count = 0;
% while count < 20
%     count = count + 1;
%     scanFront = bot.scanFront()
%     
%     while (scanFront < 0)
%         bot.turn(pi / 4);
%         scanFront = bot.scanFront()
%     end
%     
%     if (scanFront > 40)
%         move = scanFront * 0.3;
%     else
%         move = 0;
%     end
%     
%     turn = pi / 2;
%     
%     bot.move(move);
%     bot.turn(turn);
% end


% while count < 20
%     count = count + 1;
%
%     % maximum move range
%     maxMove = 30;
%
%     % Scan around robot
%     scanDist = RobotScan(mScan, numScan);
%
%     move = moveAway(scanDist, numScan);
%     if move ~= 0
%         continue;
%     end
%
%     % Turn to direction with maximum distance
%     d = max(scanDist);
% %     ind = find(scanDist==d);
%     found = 0;
%     minDist = 30;
%     while ~found
%         ind = randi(numScan);
%         if scanDist(ind) > minDist && scanDist(mod(ind-2, numScan)+1) > minDist && scanDist(mod(ind, numScan)+1) > minDist
%             found = 1;
%         end
%     end
%     n = ind;
%     turn = (n -1) * 2 * pi / numScan;
%     if turn > pi
%         turn = -(2*pi - turn);
%     end
%     RobotTurn(turn);
%
%     % Re-scan in front robot
%     scanDist = RobotScanFront(mScan);
%
%     % Move within max and min range
%     move = scanDist - 20;
%     if move > maxMove
%         move = maxMove;
%     end
%     if (move > 5)
%         RobotMove(move);
%     else
%         move = 0;
%     end
% end
