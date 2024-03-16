function [HFileOpt] = HFileOptimo(Arrivals,Hstart,Hend,HNoReg,Hfile,PAAR,AAR,RadioOpt)
%UNTITLED2 Summary of this function goes here

%   Detailed explanation goes here
TimeFile = 0:10:Hstart; % define the radius vector with a step of 100
DelG = zeros(1, length(TimeFile));
DelA = zeros(1, length(TimeFile));

for i = 1:length(TimeFile)
    Hfile = Hstart-i;
    [slots] = ComputeSlots(Hstart,Hend,HNoReg,PAAR,AAR);
    [NotAffected, ExemptRadius, ExemptInternational, ExemptFlying, Controlled, Exempt] = computeAircraftStatus(Arrivals, Hfile, Hstart, HNoReg, RadioOpt);
    [slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(slots, Controlled, Exempt, NotAffected, Hfile);
    DelG(i) = GroundDelay;
    DelA(i) = AirDelay;
end

max_index = length(DelG);
for i = length(DelG):-1:1
    if DelG(i) >= DelG(max_index)
        max_index = i;
    else
        break;
    end
end
HFileOpt = Hstart - max_index;

figure;

% print the last point where ground delay is maximum
fprintf('Optimal Hfile is = %d', Hfile);
% reverse the order of TimeFile
TimeFile = flip(TimeFile);

plot(TimeFile, DelG,'r') % plot the delay with respect to the radius
hold on;
plot(TimeFile, DelA,'b') % plot the delay with respect to the radius
xlabel('Hfile') % label the x-axis
ylabel('Delay') % label the y-axis
xline(Hstart, '-.g');
title('Delay vs. Hfile') % add a title to the plot
legend('Ground Delay', 'Air Delay') % add a legend to the plot

end