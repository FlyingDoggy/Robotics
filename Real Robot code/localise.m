function [botSim] = localise(botSim,map,target)
%This function returns botSim, and accepts, botSim, a map and a target.
%LOCALISE Template localisation function

addpath(genpath('functions'));

%% setup code
num = 1000;         % number of particles
scanSample = 4*4;   % number of scans for particles
botScanNum = 4;     % number of scans for robot
targetThreshold = 5;   % minimum distance to the target to be considered
draw = 0;           % flag used to draw figures
straighten = 1;

botSim.setMap(map);
bot = Robot(); % robot object
particles(num,1) = BotSim; % vector of particles
reSampleParticles(num,1) = BotSim; % holder particles used for resampling


for i = 1:num
    % Create particles with random states
    particles(i) = BotSim(map);
    particles(i).randomPose(0);
    
    % Create placeholder particles for resampling
    reSampleParticles(i) = BotSim(map);
    
    % Set noise and scan config
    particles(i).setSensorNoise(0.5);
    particles(i).setMotionNoise(0.001);
    particles(i).setTurningNoise(0.005);
    particles(i).setScanConfig(botSim.generateScanConfig(scanSample));
end

% Pre-compute grid map for path finding
gridMap = buildPathMap(botSim, map, target);

%% Tries to straighten the robot
if straighten
    bot.numScan = 32;
    if bot.simMode
        bot.botSim.setScanConfig(bot.botSim.generateScanConfig(bot.numScan));
    end
    ScanDistance = bot.scan2();

    if draw && bot.simMode
        bot.botSim.drawBot(3);
        bot.botSim.drawScanConfig();
        bot.botSim.drawBot(3);
    end

    % Set invalid scans to high value
    for i = 1:bot.numScan
        if ScanDistance(i) == -1
            ScanDistance(i) = 255;
        end
    end

    % Calculate angle for the direction of the minimum distance
    minDis = min(ScanDistance);
    index = find(ScanDistance == minDis, 1);
    minDisAngle = (index-1) * 2*pi / bot.numScan;

    leftInd = mod(index + bot.numScan / 4 - 2, bot.numScan)+1;
    rightInd = mod(index - bot.numScan / 4 - 2, bot.numScan)+1;

    if ScanDistance(leftInd) > ScanDistance(rightInd)
        offTurn = pi/2;
    else
        offTurn = -pi/2;
    end

    % Turn robot to that direction
    bot.turn(minDisAngle+offTurn);

    if draw && bot.simMode
        bot.botSim.drawBot(3);
        bot.botSim.drawScanConfig();
        bot.botSim.drawBot(3);
    end

    bot.move(min(32, bot.scanFront()-20));

    ScanDistance = bot.scan2();

    % Set invalid scans to high value
    for i = 1:bot.numScan
        if ScanDistance(i) == -1
            ScanDistance(i) = 255;
        end
    end

    % Calculate angle for the direction of the minimum distance
    minDis = min(ScanDistance);
    index = find(ScanDistance == minDis, 1);
    minDisAngle = (index-1) * 2*pi / bot.numScan;

    % Turn robot to that direction
    bot.turn(minDisAngle);

    dis = bot.scanFront();
    if dis < 15
        bot.move(dis - 15);
    end

    if draw && bot.simMode
        bot.botSim.drawBot(3);
        bot.botSim.drawScanConfig();
        bot.botSim.drawBot(3);
    end

end

% Reset robot scan number to default
bot.numScan = botScanNum;
if bot.simMode
    bot.botSim.setScanConfig(bot.botSim.generateScanConfig(botScanNum));
end

%% Localisation code
loopCount = 0;
maxLoopCount = 228;
moved = 5; % distance moved in the previous iteration
everConverged = 0; % flag stating if a converge has ever occured

%particle filter loop
while loopCount < maxLoopCount
    loopCount = loopCount+1;
    
    %% Perform ultrasonic scan
    ScanDistance = bot.scan2();
    
    %% Update particles scans and score particles
    [particleWeights, particles] = scanParticlesAndAssignWeights(particles, num, ScanDistance);
    
    %% Resampling particles based on weight score
    resampleParticles(particles, reSampleParticles, num, particleWeights);
    
    %% Check for convergence
    [converged, estPos, estAng] = checkConvergence(particles, num);
    if converged
        everConverged = 1;
        dist = distance(estPos, target);
        if converged && dist < targetThreshold
            break;
        end
    end
    
    % Use random point if estimated position is outside map
    if botSim.pointInsideMap(estPos) == 0
        estPos = botSim.getRndPtInMap(10);
    end
    
    %% Take a percentage of particles and respawn in randomised locations (important for robustness)
    for i = 1:num*0.1
        particles(randi(num)).randomPose(0);
    end
    
    %% Decide how to move next
    if everConverged == 0 || (moved < 5 && dist > 10)
        %% Move blindly at the begining and when robot gets stuck
        moved = moveBlindly(bot, ScanDistance, particles, num);
    elseif converged && dist < 20
        %% Move straight to target
        % Calculate the angle required to face the target
        y = target(2) - estPos(2);
        x = target(1) - estPos(1);
        angle = atan(y/x);
        if x < 0 && y > 0
            angle = pi + angle;
        elseif x < 0 && y < 0
            angle = pi + angle;
        elseif x > 0 && y < 0
            angle = 2*pi + angle;
        end
        turn = angle - estAng;
        
        % Turn and move
        bot.turn(turn);
        for i = 1:num
            particles(i).turn(turn);
        end
        moved = min(dist, max(0, bot.scanFront()-5));
        bot.move(moved);
        for i = 1:num
            particles(i).move(moved);
        end
        
        % Final check
%         bot.turn(-turn);
%         for i = 1:num
%             particles(i).turn(-turn);
%         end
%         ScanDistance = bot.scan2();
%         [particleWeights, particles] = scanParticlesAndAssignWeights(particles, num, ScanDistance);
%         resampleParticles(particles, reSampleParticles, num, particleWeights);
%         [~, estPos, estAng] = checkConvergence(particles, num);
        break;
    elseif moved < 5 && dist <= 10
        %% If stuck within 10cm of target
        bot.move(5);
        for i = 1:num
            particles(i).move(5);
        end
    else
        %% Move to target
        moved = moveToTarget(map, bot, estPos, estAng, gridMap, particles, num);
    end
    
    %% Drawing
    if draw
        hold off; %the drawMap() function will clear the drawing when hold is off
        botSim.drawMap(); %drawMap() turns hold back on again, so you can draw the bots
        for i =1:num
            particles(i).drawBot(3, 'b');
        end
        drawnow;
    end
end

%% Play end beep
bot.complete();

%% Drawing
if draw
    % Use botSim as ghost bot
    botSim.setBotPos(estPos);
    botSim.setBotAng(estAng);
    
    hold off;
    botSim.drawMap();
    plot(estPos(1),estPos(2),'kx','MarkerSize',20);
    botSim.drawBot(30,'g');
    for i =1:num
        particles(i).drawBot(3, 'b'); %draw particle with line length 3 and default color
    end
    drawnow;
end
estPos
estAng

bot.off();
end

