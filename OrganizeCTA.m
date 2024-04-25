function [slots, AZA_flights, AZA_cancelled, NewAirD, NewGroundD, NewTotalD] = OrganizeCTA(slots, CTA, Hstart, HNoReg, Controlled, Exempt, AirlineCode, MaxDMin)

AZA_flights = [];
AZA_cancelled = [];

for i = 1:height(CTA)
    if strcmp(CTA.Airline(i), AirlineCode) && CTA.arrival_minute(i) > Hstart && CTA.arrival_minute(i) < HNoReg
        AZA_flights = [AZA_flights; CTA.arrival_minute(i), CTA.ID(i), CTA.Airline(i)];
    end

    for j =1:height(slots)

        if strcmp(slots.Airline(j), AirlineCode)

            slots.ID(j) = 0;
            slots.Airline(j) = 0;
            slots.GroundDelay(j) = 0;
            slots.AirDelay(j) = 0;
            slots.TotalDelay(j) = 0;

        end
    end
end

AZA_flights = cell2table(AZA_flights,'VariableNames', {'arrival_minute', 'ID', 'Airline'});
AZA_flights = sortrows(AZA_flights, 'arrival_minute', 'ascend');

% Loop through each flight
for i = 1:height(AZA_flights)
    % Loop through each slot
    for j = 1:height(slots)
        % Check if the slot is available
        if strcmp(slots.ID(j),"0") && slots.Slot_time(j) > AZA_flights.arrival_minute(i)
            if ((slots.Slot_time(j) - AZA_flights.arrival_minute(i))) < MaxDMin

                slots.ID(j) = AZA_flights.ID(i);
                slots.Airline(j) = AZA_flights.Airline(i);
                slots.GroundDelay(j) = (slots.Slot_time(j) - AZA_flights.arrival_minute(i));
                slots.TotalDelay(j) = slots.AirDelay(j) + slots.GroundDelay(j);
            else
                % Cancel the flight
                AZA_cancelled = [AZA_cancelled; {AZA_flights.arrival_minute(i), AZA_flights.ID(i), AZA_flights.Airline(i)}];
                break
            end
        end
        j = j+1;
    end
    i = i+1;
end

% Convert AZA_cancelled to a table
AZA_cancelled = cell2table(AZA_cancelled,'VariableNames', {'arrival_minute', 'ID', 'Airline'});

% Sort AZA_cancelled by arrival_minute
AZA_cancelled = sortrows(AZA_cancelled, 'arrival_minute','ascend');

for j =1:height(slots)
    % if ~strcmp(slots.Airline(j),"AZA")
    slots.ID(j) = 0;
    slots.Airline(j) = 0;
    slots.GroundDelay(j) = 0;
    slots.AirDelay(j) = 0;
    slots.TotalDelay(j) = 0;
    % end
end

for i = 1:height(Exempt)
    flight = Exempt.FlightNumber(i);
    % Loop through each slot
    for j = 1:height(slots)
        % Check if the slot is available
        if strcmp(slots.ID(j),"0") && slots.Slot_time(j) > Exempt.STA(i) && ~ismember(Exempt.FlightNumber(i), AZA_cancelled.ID)

            % Assign the slot to the flight
            slots.ID(j) = Exempt.FlightNumber(i);
            slots.Airline(j) = Exempt.Airline(i);
            slots.AirDelay(j) = (slots.Slot_time(j) - Exempt.STA(i));
            slots.TotalDelay(j) = slots.AirDelay(j) + slots.GroundDelay(j);
            break % Exit the loop since we found an available slot

        end
        j = j+ 1;
    end
    i = i+1;
end

for i = 1:height(Controlled)
    flight = Controlled.FlightNumber(i);
    % Loop through each slot
    for j = 1:height(slots)
        % Check if the slot is available
        if strcmp(slots.ID(j),"0") && slots.Slot_time(j) > Controlled.STA(i)&& ~ismember(Controlled.FlightNumber(i), AZA_cancelled.ID)

            % Assign the slot to the flight
            slots.ID(j) = Controlled.FlightNumber(i);
            slots.Airline(j) = Controlled.Airline(i);
            slots.GroundDelay(j) = (slots.Slot_time(j) - Controlled.STA(i));
            slots.TotalDelay(j) = slots.AirDelay(j) + slots.GroundDelay(j);
            break % Exit the loop since we found an available slot

        end
        j = j+1;
    end
    i = i+1;
end

% Find the unique names
unique_names = unique(slots.ID);

% Find the repeated names
repeated_names = [];
for i = 1:numel(unique_names)
    if unique_names(i) ~= "0" && sum(strcmp(slots.ID, unique_names(i))) > 1
        repeated_names = [repeated_names, unique_names(i)];
    end
end

% Check if there are repeated names
if isempty(repeated_names)
    disp('There are no repeated names in the table\n');
else
    disp(['There are repeated names in the table:\n', repeated_names]);
end

GroundDelay = cumsum(slots.GroundDelay);
NewGroundD = ceil(GroundDelay(end));
AirDelay = cumsum(slots.AirDelay);
NewAirD = ceil(AirDelay(end));
NewTotalD = NewGroundD + NewAirD;

end
