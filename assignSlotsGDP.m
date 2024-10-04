function [slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(slots, Controlled, Exempt, NotAffected, ExemptFlying)

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
Slots_table.Aircraft = zeros(height(Slots_table), 1);


Slots_table.ID = string(Slots_table.ID);
Slots_table.Aircraft = string(Slots_table.Aircraft);
Slots_table.Airline = string(Slots_table.Airline);

% Loop through each row

if height(ExemptFlying)>0
    for i = 1:height(Exempt_table)
        flight = Exempt_table.FlightNumber(i);
        % Loop through each slot
        for j = 1:height(Slots_table)
            % Check if the slot is available
            if strcmp(Slots_table.ID(j),"0") && ismember(Exempt_table.FlightNumber(i),ExemptFlying.FlightNumber) &&(Slots_table.Slot_time(j) >= Exempt_table.STA(i))
                % Assign the slot to the flight
                Slots_table.ID(j) = Exempt_table.FlightNumber(i);
                Slots_table.Airline(j) = Exempt_table.Airline(i);
                Slots_table.Aircraft(j) = Exempt_table.Aircraft(i);
                Slots_table.AirDelay(j) = (Slots_table.Slot_time(j) - Exempt_table.STA(i));
                Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
                break % Exit the loop since we found an available slot
            end
            %j = j+ 1;
        end
    end

    % Loop through each row
    for i = 1:height(Exempt_table)
        flight = Exempt_table.FlightNumber(i);
        % Loop through each slot
        for j = 1:height(Slots_table)
            % Check if the slot is available
            if strcmp(Slots_table.ID(j),"0") && ~ismember(Exempt_table.FlightNumber(i),ExemptFlying.FlightNumber) && (Slots_table.Slot_time(j) >= Exempt_table.STA(i))
                % Assign the slot to the flight
                Slots_table.ID(j) = Exempt_table.FlightNumber(i);
                Slots_table.Airline(j) = Exempt_table.Airline(i);
                Slots_table.Aircraft(j) = Exempt_table.Aircraft(i);
                Slots_table.AirDelay(j) = (Slots_table.Slot_time(j) - Exempt_table.STA(i));
                Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
                break % Exit the loop since we found an available slot
            end
            %j = j+ 1;
        end
    end
else
    for i = 1:height(Exempt_table)
        flight = Exempt_table.FlightNumber(i);
        % Loop through each slot
        for j = 1:height(Slots_table)
            % Check if the slot is available
            if strcmp(Slots_table.ID(j),"0") && (Slots_table.Slot_time(j) >= Exempt_table.STA(i))
                % Assign the slot to the flight
                Slots_table.ID(j) = Exempt_table.FlightNumber(i);
                Slots_table.Airline(j) = Exempt_table.Airline(i);
                Slots_table.Aircraft(j) = Exempt_table.Aircraft(i);
                Slots_table.AirDelay(j) = (Slots_table.Slot_time(j) - Exempt_table.STA(i));
                Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
                break % Exit the loop since we found an available slot
            end
            %j = j+ 1;
        end
    end
end
  


for i = 1:height(Controlled_table)
    flight = Controlled_table.FlightNumber(i);
    % Loop through each slot
    for j = 1:height(Slots_table)
        % Check if the slot is available
        if strcmp(Slots_table.ID(j),"0") && Slots_table.Slot_time(j) >= Controlled_table.STA(i)
            % Assign the slot to the flight
            Slots_table.ID(j) = Controlled_table.FlightNumber(i);
            Slots_table.Airline(j) = Controlled_table.Airline(i);
            Slots_table.Aircraft(j) = Controlled_table.Aircraft(i);
            Slots_table.GroundDelay(j) = (Slots_table.Slot_time(j) - Controlled_table.STA(i));
            Slots_table.TotalDelay(j) = Slots_table.AirDelay(j) + Slots_table.GroundDelay(j);
            break % Exit the loop since we found an available slot
        end
        %j = j+1;
    end
end

% Convert Slots_table back to cell array & calculate the Ground and Air Delay
Slots_table = sortrows(Slots_table, 'Slot_time', 'ascend');

%Next we create a loop to check if it's possible to lower exempt not by
%radius delay times.
% Exemptmod = Exempt_table;
% i = 1;
% while i <= height(Exemptmod)
%     if ismember(Exemptmod.FlightNumber(i), ExemptFlying.FlightNumber)
%         Exemptmod(i,:) = [];
%         size(Exemptmod);
%         i = 0;
%     end
%     i = i+1;
% end
% % for i = 1:height(Exemptmod)
% % rowsToDelete =  string(ExemptFlying.FlightNumber) == string(Exemptmod.FlightNumber(i));
% % Exemptmod(rowsToDelete, :) = [];
% % end
% % size(Exemptmod);
% 
slotsmod = Slots_table;
for i = 1:height(slotsmod)
    if ismember(slotsmod.ID(i), Controlled_table.FlightNumber)
        rowIndex = Controlled_table.FlightNumber == slotsmod.ID(i);
        slotsmod.STA(i) = Controlled_table.STA(rowIndex);
    elseif ismember(slotsmod.ID(i), Exempt_table.FlightNumber)
        rowIndex = Exempt_table.FlightNumber == slotsmod.ID(i);
        slotsmod.STA(i) = Exempt_table.STA(rowIndex);
    end
end
Slots_table = slotsmod;

% Exemptmod.FlighNumber = string(Exemptmod.FlightNumber);
% Exemptmod.Airline = string(Exemptmod.Airline);
% Exemptmod.Aircraft = string(Exemptmod.Aircraft);
% % Exemptmod.AirDelay = str2double(Exemptmod.AirDelay);
% % Exemptmod.TotalDelay = Exemptmod.GroundDelay + Exemptmod.AirDelay;
% GroundDelay = cumsum(Slots_table.GroundDelay);
% GroundDelayAntes = ceil(GroundDelay(end));
% AirDelay = cumsum(Slots_table.AirDelay);
% AirDelayAntes = ceil(AirDelay(end));
% TotalDelayAntes = GroundDelayAntes + AirDelayAntes;
% 
% i=1;
% while i <= height(Slots_table)
%     if ismember(Slots_table.ID(i), Exemptmod.FlightNumber) || strcmp(Slots_table.ID(i),"0")
%         for j = 1:height(Exemptmod)
%             if strcmp(Slots_table.ID(i),"0")
%                 ActDelay = 5000;
%             else
%                 ActDelay = Slots_table.TotalDelay(i);
%             end                
%             SustDelay = Slots_table.Slot_time(i) - Exemptmod.STA(j);
%             if (Slots_table.Slot_time(i) >= Exemptmod.STA(j)) && ~ismember(Slots_table.ID(i),ExemptFlying.FlightNumber) && (ActDelay > SustDelay)
%                 l = height(Exemptmod) + 1;
%                 zerosRow = array2table(zeros(1, width(Exemptmod)), 'VariableNames', Exemptmod.Properties.VariableNames);
%                 Exemptmod = [Exemptmod; zerosRow];
% 
%                 Exemptmod.FlightNumber(l) = cellstr(Slots_table.ID(i));
%                 Exemptmod.STA(l) = Slots_table.STA(i);
%                 Exemptmod.Airline(l) = cellstr(Slots_table.Airline(i));
%                 Exemptmod.Aircraft(l) = cellstr(Slots_table.Aircraft(i));
% 
%                 Slots_table.ID(i) = string(Exemptmod.FlightNumber(j));
%                 Slots_table.Airline(i) = string(Exemptmod.Airline(j));
%                 Slots_table.Aircraft(i) = string(Exemptmod.Aircraft(j));
%                 Slots_table.STA(i) = Exemptmod.STA(j);
%                 Slots_table.AirDelay(i) = Slots_table.Slot_time(i) - Slots_table.STA(i);
%                 Slots_table.TotalDelay(i) = Slots_table.AirDelay(i) + Slots_table.GroundDelay(i);
% 
%                 for k = [1:(i-1),(i+1):height(Slots_table)]
%                     if strcmp(Slots_table.ID(i),Slots_table.ID(k))
%                         Slots_table.ID(k) = "0";
%                         Slots_table.Airline(k) = 0;
%                         Slots_table.Aircraft(k) = "0";
%                         Slots_table.STA(k) = 0;
%                         Slots_table.AirDelay(k) = 0;
%                         Slots_table.TotalDelay(k) = 5000;
%                     end
%                 end
% 
%                %Exemptmod(j,:) = [];
%                rowsToDelete = Exemptmod.FlightNumber == "0";
%                Exemptmod(rowsToDelete, :) = [];
%                size(Exemptmod);
%                i = 0;
%                break
%             end
%         end
%     end
%     i = i+1;
% end



% Controlledmod = Controlled_table;
% i = 1;
% while i <= height(Controlledmod)
%     if ismember(Controlledmod.FlightNumber(i), ExemptFlying.FlightNumber)
%         Controlledmod(i,:) = [];
%         size(Controlledmod);
%         i = 0;
%     end
%     i = i+1;
% end

% %Lo mismo con los controlled
% i=1;
% while i <= height(Slots_table)
%     if ismember(Slots_table.ID(i), Controlledmod.FlightNumber) || strcmp(Slots_table.ID(i),"0")
%         for j = 1:height(Controlledmod)
% 
%                 ActDelay = Slots_table.TotalDelay(i);
%             SustDelay = Slots_table.Slot_time(i) - Controlledmod.STA(j);
%             if (Slots_table.Slot_time(i) >= Controlledmod.STA(j)) && ~ismember(Slots_table.ID(i),Exempt_table.FlightNumber) && (ActDelay > SustDelay)
%                 l = height(Controlledmod) + 1;
%                 zerosRow = array2table(zeros(1, width(Controlledmod)), 'VariableNames', Controlledmod.Properties.VariableNames);
%                 Controlledmod = [Controlledmod; zerosRow];
% 
%                 Controlledmod.FlightNumber(l) = cellstr(Slots_table.ID(i));
%                 Controlledmod.STA(l) = Slots_table.STA(i);
%                 Controlledmod.Airline(l) = cellstr(Slots_table.Airline(i));
%                 Controlledmod.Aircraft(l) = cellstr(Slots_table.Aircraft(i));
% 
%                 Slots_table.ID(i) = string(Controlledmod.FlightNumber(j));
%                 Slots_table.Airline(i) = string(Controlledmod.Airline(j));
%                 Slots_table.Aircraft(i) = string(Controlledmod.Aircraft(j));
%                 Slots_table.STA(i) = Controlledmod.STA(j);
%                 Slots_table.GroundDelay(i) = Slots_table.Slot_time(i) - Slots_table.STA(i);
%                 Slots_table.TotalDelay(i) = Slots_table.AirDelay(i) + Slots_table.GroundDelay(i);
% 
%                 for k = [1:(i-1),(i+1):height(Slots_table)]
%                     if strcmp(Slots_table.ID(i),Slots_table.ID(k))
%                         Slots_table.ID(k) = "0";
%                         Slots_table.Airline(k) = 0;
%                         Slots_table.Aircraft(k) = "0";
%                         Slots_table.STA(k) = 0;
%                         Slots_table.GroundDelay(k) = 0;
%                         Slots_table.TotalDelay(k) = 5000;
%                     end
%                 end
% 
%                Controlledmod(j,:) = [];
%                rowsToDelete = Controlledmod.FlightNumber == "0";
%                Controlledmod(rowsToDelete, :) = [];
%                size(Controlledmod);
%                i = 0;
%                break
%             end
%         end
%     end
%     i = i+1;
% end




GroundDelay = cumsum(Slots_table.GroundDelay);
GroundDelay = ceil(GroundDelay(end));
AirDelay = cumsum(Slots_table.AirDelay);
AirDelay = ceil(AirDelay(end));
TotalDelay = GroundDelay + AirDelay;

slots = Slots_table;

% % Find the unique names
% unique_names = unique(slots.ID);
% % Find the repeated names
% repeated_names = [];
% for i = 1:numel(unique_names)
%     if unique_names(i) ~= "0" && sum(strcmp(slots.ID, unique_names(i))) > 1
%         repeated_names = [repeated_names, unique_names(i)];
%     end
% end
% % Check if there are repeated names
% if isempty(repeated_names)
%     disp('There are no repeated names in the table');
% else
%     disp(['There are repeated names in the table: ', repeated_names]);
% end

end