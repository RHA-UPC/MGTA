function [RadioOpt] = OptimusRadius(Arrivals,Hstart,Hend,HNoReg,Hfile,PAAR,AAR)
%UNTITLED Summary of this function goes here
figure;
%   Detailed explanation goes here
lowest_delay = inf;

rad = 250:100:5000; % define the radius vector with a step of 100
DelG = zeros(1, length(rad));
DelA = zeros(1, length(rad)); 

for i = 1:length(rad)
    [slots] = ComputeSlots(Hstart,Hend,HNoReg,PAAR,AAR);
    [NotAffected, ExemptRadius, ExemptInternational, ExemptFlying, Controlled, Exempt] = computeAircraftStatus(Arrivals, Hfile, Hstart, HNoReg, rad(i));
    [slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(slots, Controlled, Exempt, NotAffected, Hfile);

    DelG(i) = GroundDelay;
    DelA(i) = AirDelay;
end

TotalDelay = DelG + DelA; % calculate the total delay
DelayRatio = DelG ./ TotalDelay; % calculate the ratio of ground delay to total delay

% find the index of the minimum delay ratio that is greater than or equal to 0.75
minDelayRatioIndex = find(DelayRatio >= 0.75, 1, 'first');

if isempty(minDelayRatioIndex) % if no such index exists, set it to the last index
    minDelayRatioIndex = length(rad);
end
RadioOpt = rad(minDelayRatioIndex); % find the optimal radius

fprintf('The optimal radius is %d with a minimum delay ratio of %f.\n', RadioOpt, minDelayRatioIndex);

plot(rad, DelG,'r') % plot the delay with respect to the radius
hold on;
plot(rad, DelA,'b') % plot the delay with respect to the radius
xlabel('Radius') % label the x-axis
ylabel('Delay') % label the y-axis
xline(RadioOpt, '-.g');
title('Delay vs. Radius') % add a title to the plot
legend('Ground Delay', 'Air Delay') % add a legend to the plot

end