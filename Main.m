clc
clear

%Establecemos la variable del nombre de nuestro aeropuerto, la zona
%horaria donde se encuentra, la aerolinea de bandera y el retraso maximo
%antes de cancelar

name = 'LIRF';
Time_zone = 'Europe/Rome';
Airline_Code = 'AZA'; %three letters
MaxDelayMin = 180;

AAR = 40;
PAAR = 15;
HStart = 660;
HEnd = HStart + 300;
HFile = HStart-60;

%% WP1
%Llama a la función que creará la tabla

[Arrivals] = Arrivals(name, Time_zone);

%Llama a la función que crea la gráfica
Histograma = Histograma(Arrivals,AAR,PAAR,HStart,HEnd);

[HNoReg,delay] = AggregateDemand(Arrivals, HStart, HEnd,PAAR,AAR);

[Slots] = ComputeSlots(HStart,HEnd,HNoReg,PAAR,AAR);


%% WP2

%Calcula el Radio Optimo
[RadioOpt] = OptimusRadius(Arrivals,HStart,HEnd,HNoReg,HFile,PAAR,AAR);

%Calcula la hora para avisar las restricciones optima
[HFileOpt] = HFileOptimo(Arrivals,HStart,HEnd,HNoReg,HFile,PAAR,AAR,RadioOpt);

%Comprobamos los vuelos afectados por la regulacion
[NotAffected, ExemptRadius, ExemptInternational, ExemptFlying, Controlled, Exempt] = computeAircraftStatus(Arrivals, HFileOpt, HStart, HNoReg, RadioOpt);

%Assignamos Slots a los GDP
[Slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(Slots, Controlled, Exempt, NotAffected, HFileOpt);

[CTA, SlotsUsed] = computeCTA(Arrivals, Slots);

[UnrecDelay] = ComputeUnrecoverableDelay(Arrivals,Slots,HStart,HFileOpt);

[Slots, AZA_flights, AZA_cancelled, NewAirD, NewGroundD, NewTotalD] = OrganizeCTA(Slots, CTA, HStart, HNoReg, Controlled, Exempt, Airline_Code, MaxDelayMin);

HistogramaComputado = HistogramaComputado(CTA,AAR,PAAR,HStart,HEnd);