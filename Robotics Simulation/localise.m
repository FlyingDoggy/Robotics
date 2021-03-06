function [botSim] = localise(botSim,map,target)
%This function returns botSim, and accepts, botSim, a map and a target.
%LOCALISE Template localisation function

%% setup code
%you can modify the map to take account of your robots configuration space
modifiedMap = map; %you need to do this modification yourself
botSim.setMap(modifiedMap);
numOfDir = 90;%search every 4 degrees
botSim.setScanConfig(botSim.generateScanConfig(numOfDir));%set robot search range
arrayMap = mapArray(map);%convert map to array
arrayMap = resizeMap(arrayMap);%resize the map to aviod collision
sereenRes = 5;%set the size of grid of array map to 5*5
arrayMap = wavefront(modifiedMap,arrayMap,target,sereenRes);%calcuate the wavefront map 
[mapRow,mapCol] = size(arrayMap);%get the size of wavefront array
num =600; % number of particles
particles(num,1) = BotSim; %how to set up a vector of objects
resampledParticles(num,1) = BotSim;%store the resampled position and angle
weight(num) = 0;%store the weight of each particles
accumlatedWeight(num) = 0;%store the accumlatedWeight of all particles
particlesDis(numOfDir,num) = 0;%store the distance between each particles and walls
allLocation(num,2) = 0; %store the position of particles to check for convengence
allAngle(num,1) = 0;%store all angles of particles
rotateAngle = [0.75*pi,0.5*pi,0.25*pi; pi,0,0; 1.25*pi,1.5*pi,1.75*pi];%pre-set the rotation anlge for particles 
stdDiv = 6;%set the standard division
move = 5;
for i = 1:num
    particles(i) = BotSim(modifiedMap, [1,0.001,0.001]);  %each particle should use the same map as the botSim object
    particles(i).randomPose(0); %spawn the particles in random locations
    resampledParticles(i) = BotSim(modifiedMap);%store the pos and angle information after resample
    particles(i).setScanConfig(botSim.generateScanConfig(numOfDir));%set particles search range
end

%% Localisation code
maxNumOfIterations = 150;
n = 0;
converged =0; %The filter has not converged yet
while n < maxNumOfIterations %%particle filter loop
    n = n+1; %increment the current number of iterations
    botScan = botSim.ultraScan(); %get a scan from the real robot.
    
    %% Write code for updating your particles scans
    for i =1:num
        particlesDis(:,i)= particles(i).ultraScan;
    end
    %% Write code for scoring your particles
    for i = 1:num
        if particles(i).pointInsideMap(particles(i).getBotPos()) == 1
            maxWeight = 0;
            for j = 0:numOfDir-1 % use cyclic shift to rotate particles
                diff = botScan-circshift(particlesDis(:,i),j);%calculate the length of the vector between robot and particle
                weight(i) = sum(gaussmf(diff, [stdDiv,0]));%calculate the weight using gaussian distruibution;
                if weight(i)> maxWeight
                    maxWeight = weight(i);
                    index = j;%the index is stored when the max weight is found
                end
            end
            weight(i) = maxWeight;
            particles(i).setBotAng(particles(i).getBotAng() - index*2*pi/numOfDir);%rotate based on the index
        else
            weight(i) = 0;%calculate the weight using gaussian distruibution;
        end
    end
    
    weight = weight/sum(weight);%normalised the weight therefore sum of the weight = 1
    
    accumlatedWeight(1) = weight(1);%calcuate the accumlated weight of all particles
    for i = 2:num
        accumlatedWeight(i) = accumlatedWeight(i-1)+weight(i);
    end
    
    %% Write code for resampling your particles
    for i = 1:num
        randomNumber = rand;
        for j = 1:num
            if randomNumber <= accumlatedWeight(j)
                resampledParticles(i).setBotPos( particles(j).getBotPos());
                resampledParticles(i).setBotAng( particles(j).getBotAng());
                break;
            end
        end
    end
    for i = 1:num
        particles(i).setBotPos(resampledParticles(i).getBotPos());
        particles(i).setBotAng(resampledParticles(i).getBotAng());
        
    end
    %% Write code to check for convergence
    for i = 1:num
        allLocation(i,:) =  particles(i).getBotPos();
        allAngle(i) = wrapTo2Pi(particles(i).getBotAng());
        
    end
    locIqr = iqr(allLocation);%use Interquartile range to check for convergenc
    if locIqr < 4
        converged = 1;
    else
        converged = 0;
    end
    %% Write code to take a percentage of your particles and respawn in randomised locations (important for robustness)
    for i = 1:num * 0.1% 10%of the particles will respawn in randomised locations
        index = randi(num);
        particles(index).randomPose(10);
    end
    
    %% Write code to decide how to move next
    if converged ==0 || move < 5 %if not converged or there is no enough space to move, move the robot randomly
        turn = 2*pi/numOfDir;
        choice = rand;
        if choice<0.8 % 80% of the move will be random
            index = randi(numOfDir);
            while botScan(index) < 10
                index = randi(numOfDir);
            end
            maxDis = botScan(index);
        else
            [maxDis,index] = max(botScan);% 20% of the move will move the the diection with max distance
        end
        if maxDis > 40
            move = 40; % move 40 if the max distance is greater than 40
        elseif maxDis > 30 && maxDis < 40
            move = 30;
        elseif maxDis > 20 && maxDis < 20
                move = 20;
        elseif maxDis > 10 && maxDis < 20
            move = 10;
        elseif maxDis < 5 %if no enough space, don't move
            move = 0;
        else
            move = maxDis - 3;
        end
        turn = turn*(index-1);
    else
        findNode = 0; %flag
        estPos = convertCoor(map,median(allLocation),sereenRes);%estimated position
        estAng = median(allAngle);%estimated angle
        if arrayMap(estPos(2), estPos(1)) == 2
            break;
        end
        targetAngle = 0;
        for i = -1:1 %for each node, check the neighbors
            for j = -1:+1
                %if the value in next grid on the same direction is smaller than
                %current, keep moving until find a node that is larger than
                %current
                current = [estPos(2),estPos(1)];
                direction = [j,i];
                moveSteps = 0;%how many moves could be made
                next = current + direction*(moveSteps+1);
                while  next(2) > 0 && next(1) > 0 && next(2) < mapCol && next(1) < mapRow && ...
                        current(2) > 0 && current(1) > 0 && current(2) < mapCol && current(1) < mapRow && ...
                        arrayMap(next(1),next(2))~=0 && ...
                        (arrayMap(next(1),next(2)) < arrayMap(current(1),current(2))...
                        ||arrayMap(current(1),current(2)) == 0)
                    moveSteps = moveSteps+1;
                    current = next;
                    next = current + direction*(moveSteps+1);
                    targetAngle = rotateAngle(j+2,i+2);%set the target angle
                    
                    findNode = 1; 
                end
                if findNode == 1 % if node is found, jump out of the loop
                    break;
                end
            end
            if findNode == 1 % if node is found, jump out of the loop
                break;
            end
        end
        turn = targetAngle - estAng;
        move = 5*moveSteps;
    end
    botSim.turn(turn);
    botScan = botSim.ultraScan();
    if botScan(1)-5<=move
        move = botScan(1)-5;% if there is no enough space to move, recalculate the move
    end
    
    botSim.move(move);
    for i =1:num %for all the particles.
        particles(i).turn(turn); %turn the particle in the same way as the real robot
        particles(i).move(move); %move the particle in the same way as the real robot
    end
    
    %% Drawing
    %only draw if you are in debug mode or it will be slow during marking
    if botSim.debug()
        hold off; %the drawMap() function will clear the drawing when hold is off
        botSim.drawMap(); %drawMap() turns hold back on again, so you can draw the bots
        botSim.drawBot(30,'g'); %draw robot with line length 30 and green
        for i =1:num
            particles(i).drawBot(3); %draw particle with line length 3 and default color
        end
        drawnow;
    end
end

end
