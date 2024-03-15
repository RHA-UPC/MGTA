function [slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(slots, Controlled, Exempt, NotAffected, Hfile)

    % Convert to table
    Exempt_table = Exempt;
    Controlled_table = Controlled;
    NotAffected_table = NotAffected;
    Controlled_table = Controlled_table(~ismember(Controlled_table.FlightNumber, Exempt_table.FlightNumber), :);
    Slots_table = cell2table(slots,'VariableNames', {'Slot_time', 'ID', 'Airline'});

    % Initialize delays
    Slots_table.GroundDelay = zeros(height(Slots_table), 1);
    Slots_table.AirDelay = zeros(height(Slots_table), 1);
    Slots_table.TotalDelay = zeros(height(Slots_table), 1);
  

    Slots_table.ID = string(Slots_table.ID);
    Slots_table.Airline = string(Slots_table.Airline);
    
    % Loop through each row
    for i = 1:height(Exempt_table)
    flight = Exempt_table.FlightNumber(i);
            % Loop through each slot
            for j = 1:height(Slots_table)
                % Check if the slot is available
                if strcmp(Slots_table.ID(j),"0") && Slots_table.Slot_time(j) > Exempt_table.STA(i)

                    % Assign the slot to the flight
                    Slots_table.ID(j) = Exempt_table.FlightNumber(i);
                    Slots_table.Airline(j) = Exempt_table.Airline(i);
                    Slots_table.AirDelay(j) = (Slots_table.Slot_time(j) - Exempt_table.STA(i));
                    Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
                    break % Exit the loop since we found an available slot
                    
                end
            j = j+ 1;
            end
    end

for i = 1:height(Controlled_table)
    flight = Controlled_table.FlightNumber(i);
    % Loop through each slot
    for j = 1:height(Slots_table)
        % Check if the slot is available
        if strcmp(Slots_table.ID(j),"0") && Slots_table.Slot_time(j) > Controlled_table.STA(i)

            % Assign the slot to the flight
                    Slots_table.ID(j) = Controlled_table.FlightNumber(i);
                    Slots_table.Airline(j) = Controlled_table.Airline(i);
                    Slots_table.GroundDelay(j) = (Slots_table.Slot_time(j) - Controlled_table.STA(i));
                    Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
            break % Exit the loop since we found an available slot

        end
        j = j+1;
    end
end

    % Convert Slots_table back to cell array & calculate the Ground and Air Delay
    Slots_table = sortrows(Slots_table, 'Slot_time', 'ascend');
    GroundDelay = cumsum(Slots_table.GroundDelay);
    GroundDelay = ceil(GroundDelay(end));
    AirDelay = cumsum(Slots_table.AirDelay);
    AirDelay = ceil(AirDelay(end));
    TotalDelay = GroundDelay + AirDelay;


    slots = Slots_table;

end