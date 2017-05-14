function resampleParticles(particles, holder, num, weights)
% Accumulate weights
cummulativeWeights = cumsum(weights);

% Randomly resample particles in cummulative space
for i = 1:num
    weight = rand();
    j = find(cummulativeWeights >= weight, 1);
    holder(i).setBotPos( particles(j).getBotPos() );
    holder(i).setBotAng( particles(j).getBotAng() );
end

% Assign resampled particles back to particles
for i = 1:num
    particles(i).setBotPos( holder(i).getBotPos() );
    particles(i).setBotAng( holder(i).getBotAng() );
end
end