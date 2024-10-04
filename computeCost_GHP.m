function [Cost,Rtotal, Arrivals] = computeCost_GHP(Arrivals,Controlled,Exempt,ExemptFlying,slots)

Aviones = readtable("DataAir.xlsx","Sheet", "Aircraft");

Slots_table = cell2table(slots,'VariableNames', {'Slot_time', 'ID', 'Airline'});

num_Controlled= height(Controlled);
num_Exempt= height(Exempt);


num_flights = num_Controlled + num_Exempt;
num_slots = height(Slots_table);

Cost = zeros (num_flights,num_slots);
Rtotal = zeros (num_flights,num_slots);


fuel_cost = 0.5; %€/kg
pilot_cost = 50; %€/h
crew_cost = 14; %€/h

for i = 1:height(Aviones)
    Aviones.APUhconsumption(i) = Aviones.APUhconsumption(i) * fuel_cost;
end

costAir = Aviones.chourly;
costGround = Aviones.APUhconsumption;

%epsilon = Arrivals.epsilon;

Distances = Arrivals.distance;
Arrivals.Salaries = zeros(height(Arrivals), 1);
Arrivals.R = zeros(height(Arrivals), 1);
Arrivals.Cat = zeros(height(Arrivals), 1);

Arrivals.Cat= string(Arrivals.Cat);
Aviones.Cat= string(Aviones.Cat);

for i = 1:height(Arrivals)
    for j = 1:height(Aviones)
        if strcmp(Arrivals.aircraft_type(i),Aviones.aircraft(j))
            Arrivals.Cat(i) = Aviones.Cat(j);%AQUI 
        end
    end
end



for i = 1:height(Arrivals)

    if strcmp(Arrivals.Cat(i),"L")

        if Distances(i) < 4000
            Arrivals.Salaries(i) = (2*pilot_cost + 2*crew_cost);

        elseif 4000 <= Distances(i) && Distances(i) <= 8000
            Arrivals.Salaries(i) = (3*pilot_cost + 4*crew_cost);

        else
            Arrivals.Salaries(i) = (4*pilot_cost + 8*crew_cost);
        end

    elseif strcmp(Arrivals.Cat(i),"M")

        if Distances(i) < 4000
            Arrivals.Salaries(i) = (2*pilot_cost + 4*crew_cost);

        elseif 4000 <= Distances(i) && Distances(i) <= 8000
            Arrivals.Salaries(i) = (4*pilot_cost + 8*crew_cost);

        else
            Arrivals.Salaries(i) = (5*pilot_cost + 10*crew_cost);
        end

    elseif strcmp(Arrivals.Cat(i),"H")

        if Distances(i) < 4000
            Arrivals.Salaries(i) = (2*pilot_cost + 8*crew_cost);

        elseif 4000 <= Distances(i) && Distances(i) <= 8000
            Arrivals.Salaries(i) = (4*pilot_cost + 12*crew_cost);

        else
            Arrivals.Salaries(i) = (5*pilot_cost + 20*crew_cost);
        end
    elseif strcmp(Arrivals.Cat(i),"J")
        if Distances(i) < 4000
            Arrivals.Salaries(i) = (3*pilot_cost + 16*crew_cost);

        elseif 4000 <= Distances(i) && Distances(i) <= 8000
            Arrivals.Salaries(i) = (4*pilot_cost + 20*crew_cost);

        else
            Arrivals.Salaries(i) = (5*pilot_cost + 24*crew_cost);
        end

    end
end


for i = 1:height(Arrivals)
    for j = 1:height(Aviones)
        if strcmp(Arrivals.aircraft_type(i), Aviones.aircraft(j))

            if ismember(Arrivals.flight_number(i),Controlled.FlightNumber)
                Arrivals.R(i) = Arrivals.Salaries(i)/60 + costGround(j)/60;
            elseif ismember(Arrivals.flight_number(i),Exempt.FlightNumber)
                Arrivals.R(i) = Arrivals.Salaries(i)/60 + costAir(j)/60;
            else 
                Arrivals.R(i) = NaN;
            end
            break;
        end
    end

end


for i = 1:height(Slots_table)
    for j = 1:height(Arrivals)
        if ismember(Arrivals.flight_number(j),Exempt.FlightNumber) || ismember(Arrivals.flight_number(j),Controlled.FlightNumber)
            if (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >= 0 && ismember(Arrivals.flight_number(j), ExemptFlying.FlightNumber) &&  ismember(Arrivals.flight_number(j),Exempt.FlightNumber)
                if (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=15
                   Rtotal(i,j)= Arrivals.R(j) + 0.05*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <= 30 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >15
                   Rtotal(i,j)= Arrivals.R(j) + 0.12*Arrivals.pax(j);
                % elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=45 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >31
                %    Rtotal(i,j)= Arrivals.R(j) + 0.16*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=45 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >30
                   Rtotal(i,j)= 10^10;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=60 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >45
                   Rtotal(i,j)= 10^11; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=75 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >60
                   Rtotal(i,j)= 10^14;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=90 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >75
                   Rtotal(i,j)= 10^15; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=120 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >90
                   Rtotal(i,j)= 10^16; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=180 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >120
                   Rtotal(i,j)= 10^17;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=240 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >180
                   Rtotal(i,j)= 10^18; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=300 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >240
                   Rtotal(i,j)= 10^19;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >300
                   Rtotal(i,j)= 10^20;
                end

            elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >= 0 && ~ismember(Arrivals.flight_number(j), ExemptFlying.FlightNumber) && ismember(Arrivals.flight_number(j),Exempt.FlightNumber)
                if (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=15
                   Rtotal(i,j)= Arrivals.R(j) + 0.05*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <= 31 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >15
                   Rtotal(i,j)= Arrivals.R(j) + 0.12*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=45 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >31
                   Rtotal(i,j)= Arrivals.R(j) + 0.16*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=60 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >45
                   Rtotal(i,j)= 10^14; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=75 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >60
                   Rtotal(i,j)= 10^14;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=90 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >75
                   Rtotal(i,j)= 10^15; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=120 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >90
                   Rtotal(i,j)= 10^16; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=180 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >120
                   Rtotal(i,j)= 10^17;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=240 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >180
                   Rtotal(i,j)= 10^18; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=300 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >240
                   Rtotal(i,j)= 10^19;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >300
                   Rtotal(i,j)= 10^20;
                end

            elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >= 0 &&  ismember(Arrivals.flight_number(j),Controlled.FlightNumber)

                if (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=15
                   Rtotal(i,j)= Arrivals.R(j) + 0.05*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=31 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >15
                   Rtotal(i,j)= Arrivals.R(j) + 0.12*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=45 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >31
                   Rtotal(i,j)= Arrivals.R(j) + 0.16*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=60 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >45
                   Rtotal(i,j)= Arrivals.R(j) + 0.19*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=75 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >60
                   Rtotal(i,j)= Arrivals.R(j) + 0.21*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=90 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >75
                   Rtotal(i,j)= Arrivals.R(j) + 0.23*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=120 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >90
                   Rtotal(i,j)= Arrivals.R(j) + 0.32*Arrivals.pax(j); 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=180 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >120
                   Rtotal(i,j)= Arrivals.R(j) + 0.48*Arrivals.pax(j);
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=240 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >180
                   Rtotal(i,j)=10^6; 
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) <=300 && (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >240
                   Rtotal(i,j)= 10^7;
                elseif (Slots_table.Slot_time(i) - Arrivals.arrival_minute(j)) >300
                   Rtotal(i,j)= 10^12;
                end 

            else
                Rtotal(i,j) = 10^20;
            end
        else
           Rtotal(i,j)= NaN;
        end
    end
end



columnsToDelete = any(isnan(Rtotal), 1);
Rtotal(:, columnsToDelete) = [];

% if Rtotal(end,:) == 0
%     Rtotal(end, :) = [];
% end

Arrivals_modified = [];

for i = 1:height(Arrivals)
    if ismember(Arrivals.flight_number(i), Exempt.FlightNumber) || ismember(Arrivals.flight_number(i), Controlled.FlightNumber)
        Arrivals_modified = [Arrivals_modified; Arrivals(i, :)];
    end
end

for i = 1:height(Slots_table)
    for j = 1:height(Arrivals_modified)
        Slots_time = Slots_table.Slot_time(i);
        min_llegada = Arrivals_modified.arrival_minute(j);
        epsilon_escogida = 1+Arrivals_modified.epsilon(j);

        if Rtotal(i,j) ~= 10^20; 

            Cost(i,j) = Rtotal(i,j)*((Slots_table.Slot_time(i) - Arrivals_modified.arrival_minute(j)))^(1+Arrivals_modified.epsilon(j));
            Cost(i,j) = real(Cost(i,j));
        else
            Cost(i,j) = 10^20;
        end
    end
end

columnsToDelete = any(isnan(Cost), 1);
Cost(:, columnsToDelete) = [];

% if Cost(end,:) == 0
%     Cost(end, :) = [];
% end


