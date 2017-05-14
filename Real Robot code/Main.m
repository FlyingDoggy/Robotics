clf;        %clears figures
clc;        %clears console
clear;      %clears workspace
axis equal; %keeps the x and y scale the same

%% Setup workers for parallel processing
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    myCluster = parcluster('local');
    myCluster.NumWorkers = 8;
    parpool('local',8);
end

%% Re-measured map
map = [0,0;66,0;66,45;45,45;45,66;111,66;111,111;0,111];

botSim = BotSim(map,[0,0.001,0.0005]);
botSim.drawMap();
drawnow;

%% Position and set target for robot
botSim.randomPose(10);
% botSim.setBotPos([35, 35]);
% botSim.setBotAng(1.1);
target = [80 80];

%% Starts timer
tic 

%% your localisation function is called here.
returnedBot = localise(botSim,map,target);

%% stops timer
resultsTime = toc 