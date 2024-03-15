function [NotAffected, Controlled, Exempt] = DameAvioncito(Arrivals, Hfile, Hstart, HNoReg, radius)

% Initialize output variables
NotAffected = [];
Exempt = [];
Controlled = [];


% Initialize input variables
STA = Arrivals.arrival_minute;
STD = Arrivals.departure_minute;
flight_number = Arrivals.flight_number;
Distances = Arrivals.distance;
International = Arrivals.CEAC;



for i = 1:size(Arrivals)
  % Find flights not affected by the GDP
  if STA(i) <= Hstart || STA(i) >= HNoReg
      NotAffected = [NotAffected; flight_number(i), STA(i), STD(i)];
  
  % Check for exemptions: radius, already flying and International

  elseif STD(i) <= Hfile || International(i) == 0 || Distances(i) >= radius
      Exempt = [Exempt; flight_number(i), STA(i), STD(i)];
  else
      Controlled = [Controlled; flight_number(i), STA(i), STD(i)];
  end

end

end