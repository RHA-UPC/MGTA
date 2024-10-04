function [ITALIA_VUELOS] = computeItalia(Arrivals, Exempt, Controlled)

STA = Arrivals.arrival_minute;
STD = Arrivals.departure_minute;
Distances = Arrivals.distance;
flight_number = Arrivals.flight_number;
Airline = Arrivals.airline_code;
Aircraft = Arrivals.aircraft_type;
Ciudad = Arrivals.departure_airport;
Tiempo_Air = Arrivals.time_diff;


ITALIA_GDP = [];
ITALIA_GHP = [];

for i = 1:height(Arrivals)
    ch = char(Arrivals.departure_airport(i));
    ar = ch(1:2);
    if ismember(ar, "LI")
        if ismember(Arrivals.flight_number(i),Exempt.FlightNumber) || ismember(Arrivals.flight_number(i), Controlled.FlightNumber)
            ITALIA_GDP = [ITALIA_GDP; flight_number(i), Ciudad(i), STA(i), STD(i), Distances(i), Tiempo_Air(i), Airline(i), Aircraft(i)];
        end
    end
end

ITALIA_VUELOS = cell2table(ITALIA_GDP, 'VariableNames', {'FlightNumber', 'Ciudad', 'STA', 'STD','Distance', 'Tiempo_Air','Airline', 'Aircraft'});

end