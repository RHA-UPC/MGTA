function [HistogramaComputado] = HistogramaComputado(CTA,AAR,PAAR,HStart,HEnd)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
HStarth = HStart/60;
HEndh = HEnd/60;

arrival_hour = CTA.Slot_time/60;
%arrival_hour = CTA{,1}/60;

figure;
HistogramaComputado = histogram(arrival_hour, 'DisplayStyle', 'bar', 'BinEdges', 0:24);
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
%print('HistogramaComputado.png', '-dpng');

end