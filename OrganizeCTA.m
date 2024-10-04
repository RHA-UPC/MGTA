%function [SlotsCancelled, AZA_Flights, AZA_Cancelled, AZA_Exempt, AZA_Controlled, NewAirD, NewGroundD, NewTotalD] = OrganizeCTA(Slots_GDP, Controlled, Exempt, Airline_Code, MaxDelayMin)
function [SlotsCancelled, AZA_Cancelled] = OrganizeCTA(Slots_GDP, Controlled, Exempt, ExemptFlying,Airline_Code, MaxDelayMin)
%AZA_Flights = [];
AZAAirDAntes = [];
AZAAirDDesp = [];
AZAGrdDAntes = [];
AZAGrdDDesp = [];
Cancelado = [];
%AZA_Flightsdps = [];
%AZA_Cancelled = [];

%Primero, seleccionamos todos los vuelos de AZA que estan exemptos de
%regulacion
Aerolineas = unique(Slots_GDP.Airline);
Aerolineas = cellstr(Aerolineas);
Aerolineas = cell2table(Aerolineas,'VariableName',{'Airline'});

%for q = 1:height(Aerolineas)
    %Airline_Code = Aerolineas.Airline(q);
    SlotsAZA = Slots_GDP;
    k = 1;
    while k <= height(SlotsAZA)
        if SlotsAZA.Airline(k) ~= Airline_Code
            SlotsAZA(k,:) = [];
            size(SlotsAZA);
            k = 0;
        end
        k = k+1;
    end
    AZA_Flights = SlotsAZA;

    a = 1;
    Exemptmod = Exempt;
    while a <= height(Exemptmod)
        %if (Exemptmod.Airline(a) ~= Airline_Code)
        if ~strcmp(Exemptmod.Airline(a), Airline_Code)
            Exemptmod(a,:) = [];
            size(Exemptmod);
            a = 0;
        else
        end
        a = a+1;
    end
    AZA_Exempt = Exemptmod;
    %AZA_Exempt2 = AZA_Exempt;

    %Aqui seleccionamos todos los vuelos de AZA que esten regulados.
    b = 1;
    Controlledmod = Controlled;
    while b <= height(Controlledmod)
        %if (Controlledmod.Airline(b) ~= Airline_Code)
        if ~strcmp(Controlledmod.Airline(b), Airline_Code)
            Controlledmod(b,:) = [];
            size(Controlledmod);
            b = 0;
        else
        end
        b = b+1;
    end
    AZA_Controlled = Controlledmod;

    %Ahora vaciamos los slots de la aerolinea para despues reorganizarlos
    slotsmod = Slots_GDP;
    for c = 1:height(slotsmod)
        if strcmp(slotsmod.Airline(c), Airline_Code)
            if slotsmod.AirDelay(c) ~= 0
                AZAAirDAntes = [AZAAirDAntes; slotsmod.AirDelay(c)];
            end
            if slotsmod.GroundDelay(c) ~= 0
                AZAGrdDAntes = [AZAGrdDAntes; slotsmod.GroundDelay(c)];
            end
            slotsmod.ID(c) = 0;
            %slotsmod.Airline(c) = 0;
            slotsmod.GroundDelay(c) = 0;
            slotsmod.AirDelay(c) = 0;
            slotsmod.TotalDelay(c) = 0;
            slotsmod.Aircraft(c) = 0;
        else
        end
    end
    AZAAirDelayAntes = cumsum(AZAAirDAntes,1);
    AZAGroundDelayAntes = cumsum(AZAGrdDAntes,1);

    %Volvemos a rellenar los slots disponibles primero con los Excempt al
    %tener prioridad y luego los controlled.
    d = 1;
    while d <= height(slotsmod)
        if strcmp(slotsmod.ID(d), "0") && strcmp(slotsmod.Airline(d), Airline_Code)
            for e = 1:height(Exemptmod)
                if strcmp(slotsmod.ID(d), "0") && ismember(Exemptmod.FlightNumber(e), ExemptFlying.FlightNumber) && strcmp(slotsmod.Airline(d), Airline_Code) && (slotsmod.Slot_time(d) >= Exemptmod.STA(e))
                    slotsmod.ID(d) = Exemptmod.FlightNumber(e);
                    %slotsmod.Airline(d) = Exemptmod.Airline(e);
                    slotsmod.AirDelay(d) = (slotsmod.Slot_time(d) - Exemptmod.STA(e));
                    slotsmod.TotalDelay(d) = (slotsmod.GroundDelay(d) + slotsmod.AirDelay(d));
                    slotsmod.Aircraft(d) = Exemptmod.Aircraft(e);
                    Exemptmod(e,:) = [];
                    size(Exemptmod);
                    AZAAirDDesp = [AZAAirDDesp; slotsmod.AirDelay(d)];
                    d = 0;
                    break;
                end
            end
        end
        d = d+1;
    end

        d = 1;
    while d <= height(slotsmod)
        if strcmp(slotsmod.ID(d), "0") && strcmp(slotsmod.Airline(d), Airline_Code)
            for e = 1:height(Exemptmod)
                if strcmp(slotsmod.ID(d), "0") && ~ismember(Exemptmod.FlightNumber(e), ExemptFlying.FlightNumber) && strcmp(slotsmod.Airline(d), Airline_Code) && (slotsmod.Slot_time(d) >= Exemptmod.STA(e))
                    slotsmod.ID(d) = Exemptmod.FlightNumber(e);
                    %slotsmod.Airline(d) = Exemptmod.Airline(e);
                    slotsmod.AirDelay(d) = (slotsmod.Slot_time(d) - Exemptmod.STA(e));
                    slotsmod.TotalDelay(d) = (slotsmod.GroundDelay(d) + slotsmod.AirDelay(d));
                    slotsmod.Aircraft(d) = Exemptmod.Aircraft(e);
                    Exemptmod(e,:) = [];
                    size(Exemptmod);
                    AZAAirDDesp = [AZAAirDDesp; slotsmod.AirDelay(d)];
                    d = 0;
                    break;
                end
            end
        end
        d = d+1;
    end

    AZAairDelayDespues = cumsum(AZAAirDDesp,1);

    %Ahora añadimos los controlled y comprobamos los que quedarian cancelados
    f = 1;
    h = 0;
    m = 0;
    while f <= height(slotsmod)
        if strcmp(slotsmod.ID(f), "0") && strcmp(slotsmod.Airline(f), Airline_Code)
            for g = 1:height(Controlledmod)
                if strcmp(slotsmod.ID(f), "0") && strcmp(slotsmod.Airline(f), Airline_Code) && (slotsmod.Slot_time(f) >= Controlledmod.STA(g)) && (abs(slotsmod.Slot_time(f) - Controlledmod.STA(g)) < MaxDelayMin)
                    slotsmod.ID(f) = Controlledmod.FlightNumber(g);
                    %slotsmod.Airline(f) = Controlledmod.Airline(g);
                    slotsmod.GroundDelay(f) = (slotsmod.Slot_time(f) - Controlledmod.STA(g));
                    slotsmod.TotalDelay(f) = (slotsmod.GroundDelay(f) + slotsmod.AirDelay(f));
                    slotsmod.Aircraft(f) = Controlledmod.Aircraft(g);
                    Controlledmod(g,:) = [];
                    size(Controlledmod);
                    AZAGrdDDesp = [AZAGrdDDesp; slotsmod.GroundDelay(f)];
                    f = 0;
                    m = m +1;
                    break;
                elseif strcmp(slotsmod.ID(f), "0") && strcmp(Airline_Code, "AZA") && (slotsmod.Slot_time(f) >= Controlledmod.STA(g)) && (abs(slotsmod.Slot_time(f) - Controlledmod.STA(g)) >= MaxDelayMin)
                    Cancelado = [Cancelado; slotsmod.Slot_time(f), Controlledmod.FlightNumber(g), Controlledmod.Airline(g), Controlledmod.STA(g),"0", (slotsmod.Slot_time(f) - Controlledmod.STA(g)),(slotsmod.GroundDelay(f) + slotsmod.AirDelay(f)), Controlledmod.Aircraft(g)];
                    Controlledmod(g,:) = [];
                    size(Controlledmod);
                    f = 0;
                    h = h+1;
                    break;
                end
            end
        end
        f = f+1;
    end

    if height(Cancelado) ~= 0
        % AZA_Cancelled2 = cellstr(Cancelado);
        % AZA_Cancelled = cell2table(AZA_Cancelled2,'VariableNames', {'arrival_minute', 'ID', 'Airline','STA','AirDelay','GroundDelay','TotalDelay','Aircraft'});
        AZA_Cancelled = array2table(Cancelado,'VariableNames', {'arrival_minute', 'ID', 'Airline','STA','AirDelay','GroundDelay','TotalDelay','Aircraft'});

        AZAGroundDelayDespues = cumsum(AZAGrdDDesp,1);
        %AZA_Cancelled = Controlledmod;
    end

    %Hacemos la compresion.
    % i = 1;
    % while i < height(slotsmod)
    %     j = i+1;
    %     if strcmp(slotsmod.ID(i), "0") && strcmp(slotsmod.Airline(i), Airline_Code) && ~strcmp(slotsmod.Airline(j), Airline_Code)
    %         if (slotsmod.Slot_time(j) - slotsmod.TotalDelay(j)) <= slotsmod.Slot_time(i)
    %             slotsmod.ID(i) = slotsmod.ID(j);
    %             slotsmod.Airline(i) = slotsmod.Airline(j);
    %             if slotsmod.GroundDelay(j) > 0
    %                 slotsmod.GroundDelay(i) = slotsmod.GroundDelay(j) - abs(slotsmod.Slot_time(j) -slotsmod.Slot_time(i));
    %             end
    %             if slotsmod.AirDelay(j) > 0
    %                 slotsmod.AirDelay(i) = slotsmod.AirDelay(j) - abs(slotsmod.Slot_time(j) -slotsmod.Slot_time(i));
    %             end
    %             slotsmod.TotalDelay(i) = slotsmod.GroundDelay(i) + slotsmod.AirDelay(i);
    %             slotsmod.Aircraft(i) = slotsmod.Aircraft(j);
    % 
    %             slotsmod.ID(j) = "0";
    %             %slotsmod.Airline(j) = "0";
    %             slotsmod.Airline(j) = Airline_Code;
    %             slotsmod.GroundDelay(j) = "0";
    %             slotsmod.AirDelay(j) = "0";
    %             slotsmod.TotalDelay(j) = "0";
    %             slotsmod.Aircraft(j) = "0";
    %             i = 0;
    %         end
    %     end
    %     i = i+1;
    % end
    % 
    % %We try to fit the Cancelled Flights again only to see if they fit anywhere
    % %after compression.
    % f =1;
    % g = 1;
    % while f <= height(slotsmod)
    %     if strcmp(slotsmod.ID(f), "0") && strcmp(slotsmod.Airline(f), Airline_Code)
    %         for g = 1:height(AZA_Cancelled)
    %             if strcmp(slotsmod.ID(f), "0") && strcmp(slotsmod.Airline(f), Airline_Code) && (slotsmod.Slot_time(f) >= str2double(cell2mat(AZA_Cancelled.STA(g)))) && (abs(slotsmod.Slot_time(f) - str2double(cell2mat(AZA_Cancelled.STA(g)))) < MaxDelayMin)
    %                 slotsmod.ID(f) = AZA_Cancelled.FlightNumber(g);
    %                 %slotsmod.Airline(f) = Controlledmod.Airline(g);
    %                 slotsmod.GroundDelay(f) = (slotsmod.Slot_time(f) - AZA_Cancelled.STA(g));
    %                 slotsmod.TotalDelay(f) = (slotsmod.GroundDelay(f) + slotsmod.AirDelay(f));
    %                 slotsmod.Aircraft(f) = AZA_Cancelled.Aircraft(g);
    %                 AZA_Cancelled(g,:) = [];
    %                 size(AZA_Cancelled);
    %                 f = 0;
    %                 break;
    %             end
    %         end
    %     end
    %     f = f+1;
    % end
%end


for i = 1:height(slotsmod)
    if ismember(slotsmod.ID(i), Controlled.FlightNumber)
        rowIndex = Controlled.FlightNumber == slotsmod.ID(i);
        slotsmod.STA(i) = Controlled.STA(rowIndex);
    elseif ismember(slotsmod.ID(i), Exempt.FlightNumber)
        rowIndex = Exempt.FlightNumber == slotsmod.ID(i);
        slotsmod.STA(i) = Exempt.STA(rowIndex);
    end
end

AZA_Cancelled.STA = str2double(AZA_Cancelled.STA);
AZA_Cancelled.arrival_minute = str2double(AZA_Cancelled.arrival_minute);
AZA_Cancelled.GroundDelay = str2double(AZA_Cancelled.GroundDelay);
AZA_Cancelled.AirDelay = str2double(AZA_Cancelled.AirDelay);
AZA_Cancelled.TotalDelay = AZA_Cancelled.GroundDelay + AZA_Cancelled.AirDelay;


%Comprobamos si las cancelaciones son las que tienen menos delay y sino las
%sustituimos.
i = 1;
while i <= height(slotsmod)
    if strcmp(slotsmod.Airline(i),Airline_Code) 
        for j = 1:height(AZA_Cancelled)
            %DelayCancelado = str2double(cell2mat(AZA_Cancelled.STA(j))) - slotsmod.Slot_time(i);
            DelayCancelado = slotsmod.Slot_time(i) - AZA_Cancelled.STA(j);
            DelayAnterior = slotsmod.TotalDelay(i);
            if (slotsmod.Slot_time(i) >= AZA_Cancelled.STA(j)) && ismember(slotsmod.ID(i),Controlled.FlightNumber) && (DelayAnterior > DelayCancelado)
                l = height(AZA_Cancelled) + 1;
                zerosRow = array2table(zeros(1, width(AZA_Cancelled)), 'VariableNames', AZA_Cancelled.Properties.VariableNames);
                AZA_Cancelled = [AZA_Cancelled; zerosRow];
                AZA_Cancelled.arrival_minute(l) = AZA_Cancelled.arrival_minute(j);
                AZA_Cancelled.ID(l) = slotsmod.ID(i);
                AZA_Cancelled.Airline(l) = slotsmod.Airline(i);
                AZA_Cancelled.STA(l) = slotsmod.STA(i);
                AZA_Cancelled.AirDelay(l) = "0";
                AZA_Cancelled.GroundDelay(l) = AZA_Cancelled.arrival_minute(l) - slotsmod.STA(i);
                AZA_Cancelled.TotalDelay(l) = AZA_Cancelled.GroundDelay(l);
                AZA_Cancelled.Aircraft(l) = slotsmod.Aircraft(i);

                slotsmod.ID(i) = AZA_Cancelled.ID(j);
                %slotsmod.Airline(f) = Controlledmod.Airline(g);
                slotsmod.GroundDelay(i) = (slotsmod.Slot_time(i) - AZA_Cancelled.STA(j));
                slotsmod.AirDelay(i) = AZA_Cancelled.AirDelay(j);
                slotsmod.TotalDelay(i) = (slotsmod.GroundDelay(i) + slotsmod.AirDelay(i));
                slotsmod.Aircraft(i) = AZA_Cancelled.Aircraft(j);
                slotsmod.STA(i) = AZA_Cancelled.STA(j);

                AZA_Cancelled(j,:) = [];
                size(AZA_Cancelled);
                i = 0;
                break
            elseif (slotsmod.Slot_time(i) >= AZA_Cancelled.STA(j)) && ismember(slotsmod.ID(i),"0") && (slotsmod.Slot_time(i) - AZA_Cancelled.STA(j) < 180)
                slotsmod.ID(i) = AZA_Cancelled.ID(j);
                slotsmod.Airline(i) = AZA_Cancelled.Airline(j);
                slotsmod.GroundDelay(i) = (slotsmod.Slot_time(i) - AZA_Cancelled.STA(j));
                slotsmod.AirDelay(i) = AZA_Cancelled.AirDelay(j);
                slotsmod.TotalDelay(i) = (slotsmod.GroundDelay(i) + slotsmod.AirDelay(i));
                slotsmod.Aircraft(i) = AZA_Cancelled.Aircraft(j);
                slotsmod.STA(i) = AZA_Cancelled.STA(j);

                AZA_Cancelled(j,:) = [];
                size(AZA_Cancelled);
                i = 0;
                break
            end
        end
    end
    i = i+1;
end


Slots_GDP_modified = slotsmod;

for i = 1:height(Slots_GDP_modified)
    if strcmp(Slots_GDP_modified.Aircraft(i), "0")
        Slots_GDP_modified.ID(i) = "0";
    end
end

for i = 1:height(Slots_GDP_modified)
    for j = 1:height(AZA_Flights)
        if strcmp(Slots_GDP_modified.ID(i), "0") && ~ismember(AZA_Flights.ID(j), Slots_GDP_modified.ID) && strcmp(Slots_GDP_modified.Airline(i), AZA_Flights.Airline(j)) && (Slots_GDP_modified.Slot_time(i) - AZA_Flights.STA(j)) <= MaxDMin
            Slots_GDP_modified.ID(i) = AZA_Flights.ID(j);
            Slots_GDP_modified.Airline(i) = AZA_Flights.Airline(j);
            Slots_GDP_modified.Aircraft(i) = AZA_Flights.Aircraft(j);
            Slots_GDP_modified.GroundDelay(i) = Slots_GDP_modified.Slot_time(i) - AZA_Flights.STA(j);
            Slots_GDP_modified.TotalDelay(i) = Slots_GDP_modified.AirDelay(i) + Slots_GDP_modified.GroundDelay(i);

        elseif strcmp(Slots_GDP_modified.ID(i), "0") && ~ismember(AZA_Flights.ID(j), Slots_GDP_modified.ID) && strcmp(Slots_GDP_modified.Airline(i), AZA_Flights.Airline(j)) && (Slots_GDP_modified.Slot_time(i) - AZA_Flights.STA(j)) >= MaxDMin
            Slots_GDP_modified.ID(i) = "0";
            Slots_GDP_modified.Airline(i) = "0";
            Slots_GDP_modified.GroundDelay(i) = 0;
            Slots_GDP_modified.AirDelay(i) = 0;
            Slots_GDP_modified.TotalDelay(i) = 0;
            Slots_GDP_modified.Aircraft(i) = "0";
        end
        break;
    end
end



for i=1:height(Slots_GDP_modified)
    if(strcmp(Slots_GDP_modified.ID(i), "0")) && ~strcmp(Slots_GDP_modified.Airline(i),"0")
        aerolinea = Slots_GDP_modified.Airline(i);
        for j=i+1:height(Slots_GDP_modified)

            if strcmp(Slots_GDP_modified.Airline(j), aerolinea) && (Slots_GDP_modified.Slot_time(j) - Slots_GDP_modified.TotalDelay(j)) <= Slots_GDP_modified.Slot_time(i)
                Slots_GDP_modified.ID(i) = Slots_GDP_modified.ID(j);
                %Slots_GDP_modified.Airline(i) = "0";
                Slots_GDP_modified.TotalDelay(i) = Slots_GDP_modified.Slot_time(i)-(Slots_GDP_modified.Slot_time(j) - Slots_GDP_modified.TotalDelay(j));
                if Slots_GDP_modified.GroundDelay(j) ~= 0
                    Slots_GDP_modified.GroundDelay(i) = Slots_GDP_modified.TotalDelay(i);
                else
                    Slots_GDP_modified.AirDelay(i) = Slots_GDP_modified.TotalDelay(i);
                end
                Slots_GDP_modified.Aircraft(i) = Slots_GDP_modified.Aircraft(j);
    
                Slots_GDP_modified.ID(j) = "0";
                %Slots_GDP_modified.Airline(j) = "0";
                Slots_GDP_modified.GroundDelay(j) = 0;
                Slots_GDP_modified.AirDelay(j) = 0;
                Slots_GDP_modified.TotalDelay(j) = 0;
                Slots_GDP_modified.Aircraft(j) = "0";
                break;
            end
        end
    end
end

for i=1:height(Slots_GDP_modified)
    if(strcmp(Slots_GDP_modified.ID(i), "0"))
        for j=i+1:height(Slots_GDP_modified)
            if (Slots_GDP_modified.Slot_time(j) - Slots_GDP_modified.TotalDelay(j)) <= Slots_GDP_modified.Slot_time(i)
                Slots_GDP_modified.ID(i) = Slots_GDP_modified.ID(j);
                Slots_GDP_modified.Airline(i) = Slots_GDP_modified.Airline(j);
                Slots_GDP_modified.TotalDelay(i) = Slots_GDP_modified.Slot_time(i)-(Slots_GDP_modified.Slot_time(j) - Slots_GDP_modified.TotalDelay(j));
                if Slots_GDP_modified.GroundDelay(j) ~= 0
                    Slots_GDP_modified.GroundDelay(i) = Slots_GDP_modified.TotalDelay(i);
                else
                    Slots_GDP_modified.AirDelay(i) = Slots_GDP_modified.TotalDelay(i);
                end
                Slots_GDP_modified.Aircraft(i) = Slots_GDP_modified.Aircraft(j);
    
                Slots_GDP_modified.ID(j) = "0";
                Slots_GDP_modified.Airline(j) = "0";
                Slots_GDP_modified.GroundDelay(j) = 0;
                Slots_GDP_modified.AirDelay(j) = 0;
                Slots_GDP_modified.TotalDelay(j) = 0;
                Slots_GDP_modified.Aircraft(j) = "0";
                break;
            end
        end
    end
end

for i=1:height(Slots_GDP_modified)
    if(strcmp(Slots_GDP_modified.ID(i), "0"))
        Slots_GDP_modified.Airline(i) = "0";
    end
end

AZA_Cancelled(ismember(AZA_Cancelled.ID, Slots_GDP_modified.ID), :) = [];

SlotsCancelledFrankenstein = Slots_GDP_modified;

slotsmod = SlotsCancelledFrankenstein;
% Find the unique names
unique_names = unique(slotsmod.ID);

% Find the repeated names
repeated_names = [];
for i = 1:numel(unique_names)
    if unique_names(i) ~= "0" && sum(strcmp(slotsmod.ID, unique_names(i))) > 1
        repeated_names = [repeated_names, unique_names(i)];
    end
end

% Check if there are repeated names
if isempty(repeated_names)
    disp('There are no repeated names in the table');
else
    disp(['There are repeated names in the table: ', repeated_names]);
end

% GroundDelay = cumsum(slotsmod.GroundDelay);
% NewGroundD = ceil(GroundDelay(end));
% AirDelay = cumsum(slotsmod.AirDelay);
% NewAirD = ceil(AirDelay(end));
% NewTotalD = NewGroundD + NewAirD;
SlotsCancelled = slotsmod;

end
