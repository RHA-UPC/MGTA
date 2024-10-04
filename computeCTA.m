function [CTA] = computeCTA(Arrivals, slots, cancelled)
CTA = cell(height(Arrivals), 3);
SlotsUsed = 0;
%Miramos si la columna de cancelled es mayor que 0, si es asi ejecutamos un
%if u otro
if height(cancelled)  ~= 0
    for k = 1:height(Arrivals)
        flight = Arrivals.flight_number(k);
        is_in_slots = false;
        for i = 1:height(slots)
            if ismember(flight, slots.ID(i))
                CTA{k,1} = slots.Slot_time(i);
                CTA{k,2} = Arrivals.flight_number(k);
                CTA{k,3} = Arrivals.airline_code(k);
                CTA{k,4} = Arrivals.arrival_minute(k);
                is_in_slots = true;
                SlotsUsed = SlotsUsed +1;
                break; % Exit the inner loop once a matching slot is found
            elseif ismember(Arrivals.flight_number(k), cancelled.ID)
                CTA{k,1} = 0; %Los vuelos que han sido cancelados los añadimos como slot time 0 asi no aparecen en el histograma.
            end
        end
        if ~is_in_slots && ~ismember(Arrivals.flight_number(k), cancelled.ID)
            CTA{k,1} = Arrivals.arrival_minute(k);
            CTA{k,2} = Arrivals.flight_number(k);
            CTA{k,3} = Arrivals.airline_code(k);
            CTA{k,4} = Arrivals.arrival_minute(k);
        end
    end
else
    for k = 1:height(Arrivals)
        flight = Arrivals.flight_number(k);
        is_in_slots = false;
        for i = 1:height(slots)
            if ismember(flight, slots.ID(i))
                CTA{k,1} = slots.Slot_time(i);
                CTA{k,2} = Arrivals.flight_number(k);
                CTA{k,3} = Arrivals.airline_code(k);
                CTA{k,4} = Arrivals.arrival_minute(k);
                is_in_slots = true;
                SlotsUsed = SlotsUsed +1;
                break; % Exit the inner loop once a matching slot is found
            end
        end
        if ~is_in_slots
            CTA{k,1} = Arrivals.arrival_minute(k);
            CTA{k,2} = Arrivals.flight_number(k);
            CTA{k,3} = Arrivals.airline_code(k);
            CTA{k,4} = Arrivals.arrival_minute(k);
        end
    end
end



CTA = sortrows(CTA, 1, 'ascend');
CTA = cell2table(CTA,'VariableNames', {'Slot_time', 'ID','Airline' , 'arrival_minute'});
k = 1;
while k <= height(CTA)
    if CTA.Slot_time(k) == 0
        CTA(k,:) = [];
        size(CTA);
        k = 0;
    end
    k = k+1;
end

end