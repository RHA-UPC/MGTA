function [Slots_GHP, GroundDelay_GHP, AirDelay_GHP, TotalDelay_GHP] = AssignSlots_GHP(Arrivals,Exempt, Controlled, Slots, Slots_Selected, Cost)


Slots_table = cell2table(Slots,'VariableNames', {'Slot_time', 'ID', 'Airline'});

Slots_table.GroundDelay = zeros(height(Slots_table), 1);
Slots_table.AirDelay = zeros(height(Slots_table), 1);
Slots_table.TotalDelay = zeros(height(Slots_table), 1);
Slots_table.Aircraft = zeros(height(Slots_table), 1);
Slots_table.Cost = zeros(height(Slots_table), 1);
Slots_table.ID = string(Slots_table.ID);
Slots_table.Aircraft = string(Slots_table.Aircraft);
Slots_table.Airline = string(Slots_table.Airline);


Arrivals_modified = table;

if istable(Arrivals) && ismember('flight_number', Arrivals.Properties.VariableNames)
    Arrivals_modified = table;
    for i = 1:height(Arrivals)
        if ismember(Arrivals.flight_number(i), Exempt.FlightNumber) || ismember(Arrivals.flight_number(i), Controlled.FlightNumber)
            Arrivals_modified = [Arrivals_modified; Arrivals(i, :)];
        end
    end
else
    error('Invalid input: Arrivals must be a table with a flight_number variable.');
end



ID = Arrivals_modified.flight_number;
Airline = Arrivals_modified.airline_code;
Aircraft = Arrivals_modified.aircraft_type;
STA = Arrivals_modified.arrival_minute;

num_Controlled= height(Controlled);
num_Exempt= height(Exempt);


num_flights = num_Controlled + num_Exempt;
num_slots = height(Slots_table);

Dame_Slots = []; 

idx = find(Slots_Selected == 1);

j = 1;
for i=1:num_flights:height(Slots_Selected)
    while j <= height(idx)
        if i == 1
            Dame_Slots = [Dame_Slots; idx(j)];
        else
            Dame_Slots = [Dame_Slots; idx(j)-(i-1)]; 
        end 
        j = j + 1;
        break
    end
end

Dame_Slots = array2table(Dame_Slots, 'VariableNames', {'Slot_Row'});

Dame_Slots.ID = zeros(height(Slots_table), 1);
Dame_Slots.Aircraft = zeros(height(Slots_table), 1);
Dame_Slots.Airline = zeros(height(Slots_table), 1);
Dame_Slots.STA = zeros(height(Slots_table), 1);

Dame_Slots.ID = string(Slots_table.ID);
Dame_Slots.Aircraft = string(Slots_table.Aircraft);
Dame_Slots.Airline = string(Slots_table.Airline);

j = 1;
for i = 1:height(Dame_Slots)
    while j <= height(Arrivals_modified)
        Dame_Slots.ID(i) = ID(j);
        Dame_Slots.Airline(i) = Airline(j);
        Dame_Slots.Aircraft(i) = Aircraft(j);
        Dame_Slots.STA(i) = STA(j);
        j = j + 1;
        break
    end
end


for i = 1:height(Slots_table)
    for j = 1:height(Dame_Slots)
        if i == Dame_Slots.Slot_Row(j)
            if ismember(ID(j), Exempt.FlightNumber)
                Slots_table.ID(i) = ID(j);
                Slots_table.Airline(i) = Airline(j);
                Slots_table.Aircraft(i) = Aircraft(j);
                Slots_table.AirDelay(i) = (Slots_table.Slot_time(i) - STA(j));
                Slots_table.TotalDelay(i) = Slots_table.AirDelay(i) + Slots_table.GroundDelay(i);
               

            elseif ismember(ID(j), Controlled.FlightNumber)
                Slots_table.ID(i) = ID(j);
                Slots_table.Airline(i) = Airline(j);
                Slots_table.Aircraft(i) = Aircraft(j);
                Slots_table.GroundDelay(i) = (Slots_table.Slot_time(i) - STA(j));
                Slots_table.TotalDelay(i) = Slots_table.AirDelay(i) + Slots_table.GroundDelay(i);
                
            end
            Slots_table.Cost(i) = Cost(i,j);
            
            break
        end
    end
end


% Calculate the Ground and Air Delay
GroundDelay = cumsum(Slots_table.GroundDelay);
GroundDelay_GHP = ceil(GroundDelay(end));
AirDelay = cumsum(Slots_table.AirDelay);
AirDelay_GHP = ceil(AirDelay(end));
TotalDelay_GHP = GroundDelay_GHP + AirDelay_GHP;


Slots_GHP = Slots_table;
            
            



