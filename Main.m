clc
clear

%Establecemos la variable del nombre de nuestro aeropuerto y la zona
%horaria donde se encuentra

name = 'LIRF';
Time_zone = 'Europe/Rome'; 

AAR = 40;
PAAR = 15;
HStart = 660;
HEnd = HStart + 300;
HFile = HStart-60;
Radius = 2000;

%% WP1
%Llama a la función que creará la tabla

[Arrivals] = Arrivals(name, Time_zone);

%Llama a la función que crea la gráfica
[Histograma] = Histograma(Arrivals,AAR,PAAR,HStart,HEnd);

[HNoReg,delay] = AggregateDemand(Arrivals, HStart, HEnd,PAAR,AAR);

[Slots] = ComputeSlots(HStart,HEnd,HNoReg,PAAR,AAR);


%% WP2

% lowest_delay = inf;
% for radius = 500: 5000
%         [Slots] = ComputeSlots(HStart,HEnd,HNoReg,PAAR,AAR);
%         [NotAffected, Controlled, Exempt] = DameAvioncito(Arrivals, HFile, HStart, HNoReg, radius);
%         TotalDelay = DameDelaysito(Slots, Controlled, Exempt, NotAffected, HFile);
%         if TotalDelay < lowest_delay
%             lowest_delay = TotalDelay;
%             RadioOpt = radius;
%         end
%         radius = radius + 100;
% end
% 
% for i = 1: Hstart-1
%     HFile = HStart-i;
%         [Slots] = ComputeSlots(Hstart,Hend,HNoReg,PAAR,AAR);
%         [NotAffected, Controlled, Exempt] = DameAvioncito(Arrivals, HFile, HStart, HNoReg, RadioOpt);
%         TotalDelay = DameDelaysito(Slots, Controlled, Exempt, NotAffected, HFile);
%         if TotalDelay < lowest_delay
%             lowest_delay = TotalDelay;
%             HfileOpt = HFile;
%         end
%         i = i + 10;
% end


%Comprobamos los vuelos afectados por la regulacion
[NotAffected, ExemptRadius, ExemptInternational, ExemptFlying, Controlled, Exempt] = computeAircraftStatus(Arrivals, HFile, HStart, HNoReg, Radius);

%Assignamos Slots a los GDP
[Slots, GroundDelay, AirDelay, TotalDelay] = assignSlotsGDP(Slots, Controlled, Exempt, NotAffected, HFile);

[CTA, SlotsUsed] = computeCTA(Arrivals, Slots);

[UnrecDelay] = ComputeUnrecoverableDelay(Arrivals, Slots, HFile, HStart);

[Slots, AZA_flights, AZA_cancelled, NewAirD, NewGroundD, NewTotalD] = OrganizeCTA(Slots, CTA, HStart, HNoReg);



