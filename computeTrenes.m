function [TRENES_ITALIA] = computeTrenes(ITALIA_VUELOS)

TRENES = readtable("DataAir.xlsx","Sheet", "Italy");

TRENES_ITALIA = [];

Distances = ITALIA_VUELOS.Distance;
Distances = round(Distances);
flight_number = ITALIA_VUELOS.FlightNumber;
Ciudad = ITALIA_VUELOS.Ciudad;
Tiempo_Tren = TRENES.Time;
Coste = TRENES.Cost;
CO2T = TRENES.CO2T; 
CO2A = TRENES.CO2A; 
CO2T = str2double(CO2T);
CO2A = str2double(CO2A);

for i=1:height(TRENES)
    for j=1:height(ITALIA_VUELOS)
        if(strcmp(TRENES.departure_airport(i),ITALIA_VUELOS.Ciudad(j)))
            TRENES_ITALIA = [TRENES_ITALIA; flight_number(j),Ciudad(j), Distances(j), Tiempo_Tren(i), Coste(i), CO2T(i), CO2A(i)];
        end
    end
end

TRENES_ITALIA = cell2table(TRENES_ITALIA, 'VariableNames', {'ID', 'Ciudad','Distance', 'Tiempo_Tren', 'Coste', 'CO2T', 'CO2A'});

TRENES_ITALIA = TRENES_ITALIA(TRENES_ITALIA.Tiempo_Tren < 360, :); %Trayectos de menos de 6h
max_distance = max(TRENES_ITALIA.Distance);
ITALIA_VUELOS = ITALIA_VUELOS(ITALIA_VUELOS.Distance < max_distance+1, :);

% Get unique values in the 'City' column
unique_cities = unique(ITALIA_VUELOS.Ciudad);
unique_cities = cell2table(unique_cities, 'VariableNames', {'Ciudad'});



Ciudad_Italy_AVION = [];
Ciudad_Italy_TREN = [];


for i = 1:height(unique_cities)
    city = unique_cities.Ciudad(i);
    indices = strcmp(ITALIA_VUELOS.Ciudad, city);
    relevantRows = ITALIA_VUELOS(indices, :);
    if ~isempty(relevantRows)
        % Add only the first relevant row for each city
        Ciudad_Italy_AVION = [Ciudad_Italy_AVION; relevantRows.FlightNumber(1), city, relevantRows.Distance(1), relevantRows.Tiempo_Air(1), relevantRows.Airline(1), relevantRows.Aircraft(1)];
    end
end


for i = 1:height(unique_cities)
    city = unique_cities.Ciudad(i);
    indices = strcmp(TRENES_ITALIA.Ciudad, city);
    relevantRows = TRENES_ITALIA(indices, :);
    if ~isempty(relevantRows)
        % Add only the first relevant row for each city
        Ciudad_Italy_TREN = [Ciudad_Italy_TREN; relevantRows.ID(1), relevantRows.Ciudad(1), relevantRows.Distance(1), relevantRows.Tiempo_Tren(1), relevantRows.Coste(1), relevantRows.CO2T(1), relevantRows.CO2A(1)];
    end
end

Ciudad_Italy_AVION = cell2table(Ciudad_Italy_AVION, 'VariableNames', {'ID', 'Ciudad','Distance', 'Tiempo_Air', 'Airline', 'Aircraft'});
Ciudad_Italy_TREN = cell2table(Ciudad_Italy_TREN, 'VariableNames', {'ID', 'Ciudad','Distance', 'Tiempo_Tren', 'Coste', 'CO2T', 'CO2A'});

Ciudad_Italy_AVION = sortrows(Ciudad_Italy_AVION, 'Distance', 'ascend');
Ciudad_Italy_TREN = sortrows(Ciudad_Italy_TREN, 'Distance', 'ascend');

Tiempo_Extra_Avion = 30 + 120 + 15 + 15 + 30;
Tiempo_Extra_Tren = 10 + 20 + 10;

figure

% Scatter plots for CO2 emissions
scatter(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.CO2T, 'b', 'filled');
hold on;
scatter(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.CO2A, 'r', 'filled');
hold on;

% Connect scatter points with lines
plot(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.CO2T, 'b--');
hold on;
plot(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.CO2A, 'r--');
hold on;

% Scatter plots for travel time
yyaxis right
scatter(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.Tiempo_Tren + Tiempo_Extra_Tren, 'g', 'filled');
hold on;
scatter(Ciudad_Italy_AVION.Distance, (Ciudad_Italy_AVION.Tiempo_Air*60 + Tiempo_Extra_Avion), 'm', 'filled');
hold on;

% Connect scatter points with lines
plot(Ciudad_Italy_TREN.Distance, Ciudad_Italy_TREN.Tiempo_Tren + Tiempo_Extra_Tren, 'g--');
hold on;
plot(Ciudad_Italy_AVION.Distance, Ciudad_Italy_AVION.Tiempo_Air*60 + Tiempo_Extra_Avion, 'm--');
hold on;



for i = 1:3
    Train_Recorrido(i) = 220 * i;
    xline(Train_Recorrido(i), '-.k');
    hold on;
end

for i = 30:15:60
    Avion_Recorrido(i) = 900 * i/60;
    xline(Avion_Recorrido(i), 'k');
    hold on;
end



title('CO2 and Door-to-Door time  Comparison in GDP');
xlabel('Distance (Km)');
yyaxis left
ylabel('CO2 (kg)');
yyaxis right
ylabel('Door-to-Door time (min)');
legend('CO2 Tren', 'CO2 Avion','CO2 Tren', 'CO2 Avion', 'Time Travel Tren', 'Time Travel Avion', 'Time Travel Tren', 'Time Travel Avion', '1, 2 & 3 hours of train tavel', '30 & 45 min of air travel');




end


