function [Grafica] = Histograma(Arrivals,AAR,PAAR,HStart,HEnd)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%arrival_hour = hour(datetime(ARRIVAL_sorted.scheduled_arrival, 'InputFormat', 'yyyyMMddHHmmss'));
HStarth = HStart/60;
HEndh = HEnd/60;

arrival_hour = Arrivals.arrival_minute/60; 
% 
figure;
Grafica = histogram(arrival_hour, 'DisplayStyle', 'bar', 'BinEdges', 0:24);
hold on;

% Plot the nominal capacity line
plot(0:HStarth, AAR * ones(1, length(0:HStarth)), 'LineWidth', 2, 'Color', 'g', 'LineStyle', '-');
% Plot the reduced capacity line
plot(HStarth:HEndh, PAAR * ones(1, length(HStarth:HEndh)), 'LineWidth', 2, 'Color', 'r', 'LineStyle', '-');


plot(HEndh:24, AAR * ones(1, length(HEndh:24)), 'LineWidth', 2, 'Color', 'g', 'LineStyle', '-');

% Set the x and y axis labels
xlabel('Time (hours)');
ylabel('Number of Arrivals');

% Create a legend
legend('Arrivals', 'Nominal Capacity','Reduced Capacity');
%print('Histogram.png', '-dpng');

end