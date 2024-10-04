function [ARRIVAL] = Arrivals(name, Time_zone)
%PROCESS Summary of this function goes here

%Executes function given by the professor.
flights_data = parse_allft("20160129.ALL_FT+");

%Acces data about Aircrafts, Airlines and ECAC airports from an unique
%excel.
aircraft_types = readtable("DataAir.xlsx","Sheet","Aircraft");
data_airlines = readtable("DataAir.xlsx","Sheet","Airlines");
%ECAC = readtable("DataAir.xlsx","Sheet","AirportsECAC");
CountriesECAC = readtable("DataAir.xlsx","Sheet","ECAC_List");

%Filtrates flights by the arriving ones to the selected and airport and
%sort them by time of arrival.
ARRIVAL = flights_data(strcmp(flights_data.arrival_airport, name), :);
ARRIVAL_sorted = sortrows(ARRIVAL, 'scheduled_arrival', 'ascend');
ARRIVAL_sorted.scheduled_departure = datetime(ARRIVAL_sorted.scheduled_departure,'TimeZone','UTC', 'InputFormat', 'yyyyMMddHHmmSS');
ARRIVAL_sorted.scheduled_arrival = datetime(ARRIVAL_sorted.scheduled_arrival,'TimeZone','UTC', 'InputFormat', 'yyyyMMddHHmmSS');

ARRIVAL_sorted.scheduled_departure = datetime(ARRIVAL_sorted.scheduled_departure, 'TimeZone', Time_zone);
ARRIVAL_sorted.scheduled_arrival = datetime(ARRIVAL_sorted.scheduled_arrival, 'TimeZone', Time_zone);

ARRIVAL_sorted.time_diff = hours(ARRIVAL_sorted.scheduled_arrival - ARRIVAL_sorted.scheduled_departure);

%Elimina los vuelos que aterrizan al dia siguiente despues de corregirlo a
%horario local desde UTC

daysToDelete = day(ARRIVAL_sorted.scheduled_arrival) ~= 29;
ARRIVAL_sorted(daysToDelete,:) = [];

%Assign if the flight comes from ceac '1' or outside it '0'.
ARRIVAL_sorted.CEAC = zeros(size(ARRIVAL_sorted.departure_airport));
for i = 1:height(ARRIVAL_sorted)
    ch = char(ARRIVAL_sorted.departure_airport(i));
    ar = ch(1:2);
    if ismember(ar, CountriesECAC.Code)
        ARRIVAL_sorted.CEAC(i) = 1;
    end
end

%Adds passengers in the flight multiplying capacity by median occupancy by
%airline.
[~, idx1] = ismember(ARRIVAL_sorted.aircraft_type, aircraft_types.aircraft);

ARRIVAL_sorted.available_seats = aircraft_types.pax(idx1);

[~, idx2] = ismember(ARRIVAL_sorted.airline_code, data_airlines.airline_code);
ARRIVAL_sorted.pax = ARRIVAL_sorted.available_seats .* (data_airlines.occupancy(idx2)/100);
ARRIVAL_sorted.pax = round(ARRIVAL_sorted.pax);

%Adds distance multipyling time off flight by cruise speed of each
%aircraft.
[~, idx3] = ismember(ARRIVAL_sorted.aircraft_type, aircraft_types.aircraft);
ARRIVAL_sorted.speed = aircraft_types.speed(idx3);
ARRIVAL_sorted.distance = ARRIVAL_sorted.speed .* ARRIVAL_sorted.time_diff;

% Create a new column 'departure_minute' in the table
ARRIVAL_sorted.departure_minute = zeros(size(ARRIVAL_sorted,1),1);

% Loop through each row of the table
for i = 1:size(ARRIVAL_sorted,1)
    % Get the scheduled departure time
    scheduled_departure = ARRIVAL_sorted.scheduled_departure(i);

    % Check if the scheduled departure time is on the 28th day of the month
    if day(scheduled_departure) == 28
        % If the scheduled departure time is on the 28th day of the month, calculate the number of minutes until the end of the day
        ARRIVAL_sorted.departure_minute(i) = -((23 - hour(scheduled_departure)) * 60 + (60 - minute(scheduled_departure)));
    else
        % If the scheduled departure time is not on the 28th day of the month, calculate the number of minutes since the start of the day
        ARRIVAL_sorted.departure_minute(i) = hour(scheduled_departure) * 60 + minute(scheduled_departure);
    end
end

%Crea una columna con la hora de llegada en minutos.
ARRIVAL_sorted.arrival_minute = hour(ARRIVAL_sorted.scheduled_arrival)*60 + minute(ARRIVAL_sorted.scheduled_arrival);


%Creamos una distancia media de los aeropuertos de salida así unificamos
%criterios para GHP. Ya que la distancia realmente es un estimado y es
%diferente para cada caso. 
listasalidas = unique(ARRIVAL_sorted.departure_airport);

listmod = cell2table(listasalidas,'VariableName',{'DepartureAirport'});
Distancias = [];
dismo = [];
arrimod = ARRIVAL_sorted;
k = 1;
for i = 1:height(listmod)
    while k <= height(arrimod)
        if height(arrimod) > 0 && strcmp(listmod.DepartureAirport(i), arrimod.departure_airport(k))
            dismo = [dismo; arrimod.distance(k)];
            arrimod(k,:) = [];
            size(arrimod);
            k = 0;
        elseif k == height(arrimod)
            k = 1;
            break;
        end
        k = k +1;
    end
    DMedia = mean(dismo);
    Distancias = [Distancias; listmod.DepartureAirport(i), DMedia];
    dismo = [];
end

DistMedias = cell2table(Distancias,'VariableName',{'DepartureAirport','Distancias'});

[~, idx4] = ismember(ARRIVAL_sorted.departure_airport, DistMedias.DepartureAirport);

ARRIVAL_sorted.distance = DistMedias.Distancias(idx4);



ARRIVAL = ARRIVAL_sorted;

end

