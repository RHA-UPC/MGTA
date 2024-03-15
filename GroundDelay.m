function [GDelay, slots] =  GroundDelay(Controlled,slots,Hfile,Hstart,Hend, HNoReg)

    GDelay = [];

    Slots_table = cell2table(slots,'VariableNames', {'Slot_time', 'ID', 'Airline', 'GD'});
    Controlled_table = cell2table(Controlled, 'VariableNames', {'FlightNumber', 'STA', 'STD','Distace', 'International', 'Airline'});

    FlightNumber = Controlled_table.FlightNumber;
    Airline = Controlled_table.Airline;
    STA = Controlled_table.STA;
    STD = Controlled_table.STD;
    Distance = Controlled_table.Distance

    Slots_table.ID = string(Slots_table.ID);
    Slots_table.Airline = string(Slots_table.Airline);

    
    for i=1:size(Controlled_table.FlightNumber, 1)
            if STD < Hfile



                Slots_table.Slot_time(i) >= Controlled_table.STA(i) && strcmp(Slots_table.ID(i), "0")              
                Slots_table.ID(i) = FlightNumber(i);
                Slots_table.Airline(i) = Airline(i);
                GD = Slots_table.Slot_time(i) - Controlled_table.STA(i);
                Slots_table.GD(i) = GD;
            else

            end
    end

    slots = table2cell(Slots_table);

end