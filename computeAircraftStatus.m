function [NotAffected, Controlled, Exempt, ExemptFlying] = computeAircraftStatus(Arrivals, Hfile, Hstart, HNoReg, radius)

% Initialize output variables
NotAffected = [];
ExemptRadius = [];
ExemptInternational = [];
ExemptFlying = [];
Exempt = [];
Controlled = [];


% Initialize input variables
STA = Arrivals.arrival_minute;
STD = Arrivals.departure_minute;
Distances = Arrivals.distance;
International = Arrivals.CEAC;
flight_number = Arrivals.flight_number;
Airline = Arrivals.airline_code;
Aircraft = Arrivals.aircraft_type;



for i = 1:size(Arrivals)
    % Find flights not affected by the GDP
    if STA(i) <= Hstart || STA(i) >= HNoReg
        NotAffected = [NotAffected; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];

        % Check for exemptions: radius, already flying and International

    elseif STD(i) <= Hfile
        ExemptFlying = [ExemptFlying; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];
        Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];

    elseif International(i) == 0
        ExemptInternational = [ExemptInternational; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];
        Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];

    elseif Distances(i) >= radius
        ExemptRadius = [ExemptRadius; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];
        Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];

    else
        Controlled = [Controlled; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i), Aircraft(i)];
    end

end

Exempt = cell2table(Exempt, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline', 'Aircraft'});
ExemptFlying = cell2table(ExemptFlying, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline', 'Aircraft'});
Controlled = cell2table(Controlled, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline', 'Aircraft'});
NotAffected = cell2table(NotAffected, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline', 'Aircraft'});

end



