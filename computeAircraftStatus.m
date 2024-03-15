function [NotAffected ExemptRadius ExemptInternational ExemptFlying Controlled Exempt] = computeAircraftStatus(Arrivals, Hfile, Hstart, HNoReg, radius)

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



for i = 1:size(Arrivals)
  % Find flights not affected by the GDP
  if STA(i) <= Hstart || STA(i) >= HNoReg
      NotAffected = [NotAffected; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];
  
  % Check for exemptions: radius, already flying and International

  elseif STD(i) <= Hfile
      ExemptFlying = [ExemptFlying; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];
      Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];

  elseif International(i) == 0
      ExemptInternational = [ExemptInternational; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];
      Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];

  elseif Distances(i) >= radius
      ExemptRadius = [ExemptRadius; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];
      Exempt = [Exempt; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];

  else
      Controlled = [Controlled; flight_number(i), STA(i), STD(i), Distances(i), International(i), Airline(i)];
  end

end

Exempt = cell2table(Exempt, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline'});
Controlled = cell2table(Controlled, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline'});
NotAffected = cell2table(NotAffected, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distance', 'International', 'Airline'});

end



