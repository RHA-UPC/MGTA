function [ASTD, GSTD, TSTD, mA, mG, mT, AirDelay, GroundDelay, TotalDelay] = RelStd(slotsG, HNoReg, Controlled, Exempt)
%Elimina todos los slots que hay despues del HNoReg ya que serian vuelos ya
%sin regular y no nos interesan para el computo general
i = 1;
while i <= height(slotsG)
    if (slotsG.Slot_time(i) > HNoReg)
        slotsG(i,:) = [];
        size(slotsG);
        i = 0;
    end
    i = i+1;
end
%Elimina, en el caso de que exista, las filas vacias que no contegan ningun
%avion, ya que al calcular el HNoReg se utilizan ints y podria ocurrir que
%el primer slot vacio (el HNoReg real) fuese un double. 
i = 1;
while i <= height(slotsG)
    if strcmp(slotsG.ID(i),"0")
        slotsG(i,:) = [];
        size(slotsG);
        i = 0;
    end
    i = i+1;
end

%Creamos listas paralelas para los slots que tienen AirDelay y los que
%tienen ground delay
sltAir = slotsG;
sltGrnd = slotsG;
%Eliminamos de sltAir todos los vuelos que no sean Exempt
i = 1;
while i <= height(sltAir)
    if ~ismember(sltAir.ID(i),Exempt.FlightNumber)
        sltAir(i,:) = [];
        size(sltAir);
        i = 0;
    end
    i = i+1;
end
%Eliminamos de sltGrnd todos los vuelos que no sean Controlled
i = 1;
while i <= height(sltGrnd)
    if ~ismember(sltGrnd.ID(i),Controlled.FlightNumber)
        sltGrnd(i,:) = [];
        size(sltGrnd);
        i = 0;
    end
    i = i+1;
end

%Calculamos las medias
mA = mean(sltAir.AirDelay);
mG = mean(sltGrnd.GroundDelay);
mT = mean(slotsG.TotalDelay);
%Calculamos las desviaciones estandar
sA = std(sltAir.AirDelay);
sG = std(sltGrnd.GroundDelay);
sT = std(slotsG.TotalDelay);
%Calculamos las desviaciones estandar relativas
ASTD = sA/mA;
GSTD = sG/mG;
TSTD = sT/mT;

GD = cumsum(sltGrnd.GroundDelay);
GroundDelay = ceil(GD(end));
AD = cumsum(sltAir.AirDelay);
AirDelay = ceil(AD(end));
TotalDelay = GroundDelay + AirDelay;
TD = cumsum(slotsG.TotalDelay);
TotalDelay2 = ceil(TD(end));

end