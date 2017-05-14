function [weights, particles] = scanParticlesAndAssignWeights(particles, num, botScanDistance)
weights(num, 1) = 0;

% Loop all particles and calculate weights
parfor i =1:num
    particle = particles(i);
    weights(i) = calculateWeights(particle, botScanDistance);
    particles(i) = particle;
end

% Normalize
weights = weights / sum(weights);
end

function weight = calculateWeights(particle, botScanDistance)
sig = 3; % Sandard deviation for the gaussion distribution
maxWeight = 0; % Keep track of max

if particle.insideMap() == 0
    % Ignore particles outside the map
    weight = 0;
else
    % Take scan
    pScanDist = particle.ultraScan();
    numScan = size(pScanDist, 1);
    
    % Cyclic shift
    n = 0;
    botNumScan = size(botScanDistance,1);
    primePartScan(botNumScan, 1) = 0;
    for i = 1:numScan
        for j = 1:botNumScan
            primePartScan(j) = pScanDist(j*4-3);
        end
%         w = gaussmf(sum(var([primePartScan botScanDistance], 0, 2)), [sig, 0]);
%         w = gaussmf(sum(abs(primePartScan - botScanDistance)), [sig, 0]);
%         w = sum(gaussmf((primePartScan - botScanDistance).^2, [sig, 0]));
%         w = gaussmf(norm(primePartScan - botScanDistance)/2, [sig, 0]);
        w = gaussmf(norm(primePartScan - botScanDistance), [sig, 0]);
        
        if w > maxWeight
            maxWeight = w;
            n = i;
        end
        pScanDist = circshift(pScanDist, numScan-1);
    end
    
    % Return weight and set particle to angle with max weight
    weight = maxWeight;
    particle.setBotAng(particle.getBotAng() + (n -1) * 2 * pi / numScan);

% botNumScan = size(botScanDistance,1);
% primePartScan(botNumScan, 1) = 0;
% for j = 1:botNumScan
% 	primePartScan(j) = pScanDist(j*2-1);
% end
% weight = sum(gaussmf(primePartScan - botScanDistance, [sig, 0]));
% % weight = sum(gaussmf(var([primePartScan botScanDistance], 0, 2), [sig, 0]));
end
end
