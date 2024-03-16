function [UnrecDela] = ComputeUnrecoverableDelay(Arrivals,slots,Hstart,HfileOpt)
% TRES CASOS
% 1 ESTE no me dara unrec delay si STD>Hstart se puede recuperar
% 2 si se cumple que Hstart > STD  Y Hstart < CTD por lo tanto si
% cancelamos en hstart tendremos de unrec= CTD- STD
% 3 Mezcla de los dos casos, STD < Hstart; CTD > Hstart unrec=Hstart-STD
UnrecDela = 0;
% % QUEREMOS LOS PARAMETROS DE STD Y CTD DE LOS VUELOS EN VECTORES O
% % TABLAS
% STD = Arrivals.departure_minute;
% CTD = Arrivals.departure_minute + slots.GroundDelay;
vector_arrival = [];
k = 1;
j=2;


for i = 1 :1:height(slots)
    for j = 1 : 1 : height(Arrivals)
        if strcmp(Arrivals.flight_number(j),slots.ID(i))== true
            vector_arrival(k,1)= Arrivals.departure_minute(j);
            vector_arrival(k,2)= slots.GroundDelay(i);
            vector_arrival(k,3)= i;
            k = k + 1;
        end
    end
end

string_unc = string(vector_arrival(:, 3));

% for i = 1 :1:height(Arrivals)
%    if strcmp(Arrivals.flight_number(i),slots.ID(j))== true
%        vector_arrival(k,1)= Arrivals.departure_minute(i);
%        vector_arrival(k,2)= slots.GroundDelay(j);
%        vector_arrival(k,3)= slots.ID(j);
%        j = j+1;
%        k = k+1;
%        i = 1;
%    end
% end

STD = vector_arrival(:,1);
CTD = vector_arrival(:,1) + vector_arrival(:,2);



% common_elements = intersect(STD, CTD);
% CASO 1 VAMOS A DEFINIR UN VECTOR DE 1 Y O SI SE CUMPLE NO SE SUMA
% DELAY
Caso1 = Hstart < STD   & Hstart < CTD;
% CASO 2
Caso2 = Hstart > STD & Hstart > CTD & STD > HfileOpt;
% caso 3
Caso3 = STD <Hstart & CTD > Hstart;
% estos tres vectores tiene que tener todos la misma longitud
% contador no puede empezar en cero
Contador = 1;
Longitud = numel(Caso3);
while Contador <= Longitud
    if Caso1(Contador) == 1
        UnrecDela = UnrecDela;
    end

    if Caso2(Contador) == 1
        UnrecDela = UnrecDela + (CTD(Contador)-STD(Contador));
    end

    if Caso3(Contador)==1
        UnrecDela = UnrecDela + (Hstart - STD(Contador));
    end

    Contador = Contador + 1;
end

% Longitud = numel(CTD);
% Contador = 1;
% while Contador <= Longitud
%     disp(Contador);
%     Contador = Contador + 1 ;
% end
% UnrecDelay = zeros(height(Arrivals), 2);
% STD = Arrivals.departure_minute;
% Arrivals.flight_number = string(Arrivals.flight_number);



end