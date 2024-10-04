function [HNoReg] = AggregateDemandforSlots(CTA,Arrivals, HStart,HEnd,PAAR,AAR)

figure;
minutos = 1:1:1440;

Arrivals_NUMBER = zeros(1440, 1); % Initialize a column vector of zeros with length 1440
for j = 1:height(CTA)
    if (CTA.Slot_time(j) > 0 && CTA.Slot_time(j) <= 1440)
        Arrivals_NUMBER(round(CTA.Slot_time(j))) = Arrivals_NUMBER(round(CTA.Slot_time(j))) + 1;
    end
end

% Compute the cumulative sum of the number of planes
Arrivals_NUMBER = cumsum(Arrivals_NUMBER,1);

%First function
hold on;

A1 = interp1(minutos, Arrivals_NUMBER, HStart);
B1 = A1 - ((PAAR/60) * HStart);
y1 = @(x) ((PAAR/60) * x) + B1;

% Define the second function
A2 = ((PAAR/60) * HEnd) + B1;
B2 = A2 - (AAR/60) * HEnd;
y2 = @(x) (AAR/60) * x + B2;

%Find HNoReg
for i = 1:length(Arrivals_NUMBER)
    minute = minutos(i);
    y_value = interp1(minutos, Arrivals_NUMBER, i);
    if (y2(minute) - y_value) >= 1
        HNoReg = minute;
        break;
    else
        HNoReg = 0;
    end
end

% Create the plot
plot(minutos, Arrivals_NUMBER);

% %Plot the function y1 between Hstart and HEnd
% x1 = HStart:1:HEnd;
% plot(x1, y1(x1)); % Plot the first function
% 
% hold on;
% 
% Plot the function y2 until the point of interception
% x2 = HEnd:1:HNoReg;
% plot(x2, y2(x2)); % Plot the second function

Arrivals_NUMBER = zeros(1440, 1); % Initialize a column vector of zeros with length 1440
for j = 1:height(Arrivals)
    if (Arrivals.arrival_minute(j) > 0 && Arrivals.arrival_minute(j) <= 1440)
        Arrivals_NUMBER(Arrivals.arrival_minute(j)) = Arrivals_NUMBER(Arrivals.arrival_minute(j)) + 1;
    end
end
% Compute the cumulative sum of the number of planes
Arrivals_NUMBER = cumsum(Arrivals_NUMBER,1);
plot(minutos, Arrivals_NUMBER);


xline(HStart, '-.r');
xline(HEnd, '-.g');
xline(HNoReg, '-.b');
xlabel('Scheduled Arrival Time (minutes)');
ylabel('Cumulative Sum of Planes');
legend('Location','northwest');
%legend('Number of planes','Reduced planes','Normal Planes','HStart','HEnd','HNoReg');
legend('Regulated Arrivals','Normal Arrivals','HStart','HEnd','HNoReg');
%print('AggregateDemand.png', '-dpng');

% %Calculates the area of the two functions
% b = integral(y1, HStart, HEnd);
% c = integral(y2, HEnd, HNoReg);
% 
% %Calculates the area of the line minutes utilizing trapz function since
% %its a vector of points and not a function.
% A = Arrivals_NUMBER;
% x3 = HStart:1:HNoReg;
% B = A(HStart:HNoReg);
% a = trapz(x3,B);
% 
% delay = a - (b+c);

end