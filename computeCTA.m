function [CTA, SlotsUsed] = computeCTA(Arrivals, slots)
CTA = cell(height(Arrivals), 3);
SlotsUsed = 0;
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
CTA = sortrows(CTA, 1, 'ascend');
CTA = cell2table(CTA,'VariableNames', {'Slot_time', 'ID','Airline' , 'arrival_minute'});
end