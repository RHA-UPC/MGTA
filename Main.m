clear
clc
%Establecemos la variable del nombre de nuestro aeropuerto, la zona
%horaria donde se encuentra, la aerolinea de bandera y el retraso maximo
%antes de cancelar
name = "LIRF";
Time_zone = 'Europe/Rome';
Airline_Code = "AZA"; %three letters
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
%Plotea la grafica de los vuelos y obtenemos el HNoReg y el delay total
[HNoReg,delay] = AggregateDemand(Arrivals, HStart, HEnd,PAAR,AAR);
%Calcula los slots que necesitamos
[Slots] = ComputeSlots(HStart,HEnd,HNoReg,PAAR,AAR);

%% WP2
%Calcula el Radio Optimo
[RadioOpt] = OptimusRadius(Arrivals,HStart,HEnd,HNoReg,HFile,PAAR,AAR);
%Calcula la hora para avisar las restricciones optima
[HFileOpt] = HFileOptimo(Arrivals,HStart,HEnd,HNoReg,HFile,PAAR,AAR,RadioOpt);
%Comprobamos los vuelos afectados por la regulacion
%[NotAffected, ExemptRadius, ExemptInternational, ExemptFlying, Controlled, Exempt] = computeAircraftStatus(Arrivals, HFileOpt, HStart, HNoReg, RadioOpt);
[NotAffected, Controlled, Exempt, ExemptFlying] = computeAircraftStatus(Arrivals, HFileOpt, HStart, HNoReg, RadioOpt);

%% GDP
%Assignamos Slots a los GDP
[Slots_GDP, GroundDelay_GDP, AirDelay_GDP, TotalDelay_GDP] = assignSlotsGDP(Slots, Controlled, Exempt, NotAffected, ExemptFlying);
%Calcula el Unrecoverable Delay
[UnrecDelayGDP] = ComputeUnrecoverableDelay(Arrivals,Slots_GDP,HStart,HFileOpt);
%Asigna un time of arrival a TODOS los aviones despues de introducir la 
%regulacion. Ponemos [] donde iria la lista de cancelados ya que no
%cancelamos nada en GDP
[CTAGDP] = computeCTA(Arrivals, Slots_GDP, []);
%Calculate the new HNoReg
[HNoRegGDP] = AggregateDemandforSlots(CTAGDP, Arrivals, HStart, HEnd,PAAR,AAR);
%Deviations
[STDGDPAir, STDGDPGrnd, STDGDPTot, MeanGDPAir, MeanGDPGrnd, MeanGDPTotal, AirDelay_GDP2, GroundDelay_GDP2, TotalDelay_GDP2] = RelStd(Slots_GDP,HNoRegGDP,Controlled,Exempt);
%Histograma despues de aplicar la regulacion
HistogramaComputadoGDP = HistogramaComputado(CTAGDP,AAR,PAAR,HStart,HEnd);

%% Cancelados
%Cancelamos vuelos con mayor Delay de AZA y hacemos compresión 
%[Slots_Cancelled, AZA_Flights, AZA_Cancelled, AZA_Exempt, AZA_Controlled, AirDelay_Canc, GroundDelay_Canc, TotalDelay_Canc] = OrganizeCTA(Slots_GDP, Controlled, Exempt, Airline_Code, MaxDelayMin);
[Slots_Cancelled, AZA_Cancelled] = OrganizeCTA(Slots_GDP, Controlled, Exempt,ExemptFlying, Airline_Code, MaxDelayMin);
%Calcula el Unrecoverable Delay
[UnrecDelayCanc] = ComputeUnrecoverableDelay(Arrivals,Slots_Cancelled,HStart,HFileOpt);
%Computamos CTA para cancelado
[CTACanc] = computeCTA(Arrivals, Slots_Cancelled, AZA_Cancelled);
%Calculamos la nueva HNoReg
[HNoRegCanc] = AggregateDemandforSlots(CTACanc, Arrivals, HStart, HEnd,PAAR,AAR);
%Calculamos medias y desviaciones estandar
[STDCancAir, STDCancGrnd, STDCancTot, MeanCancAir, MeanCancGrnd, MeanCancTotal, AirDelay_Canc, GroundDelay_Canc, TotalDelay_Canc] = RelStd(Slots_Cancelled, HNoRegCanc,Controlled,Exempt);
%Nuevo Histograma
HistogramaComputadoCancelado = HistogramaComputado(CTACanc,AAR,PAAR,HStart,HEnd);

%% WP3
%Calcula la Epsilon para cada vuelo
[ArrivalsGHP] = computeEpsilon(Arrivals);
%Calcula el coste para cada vuelo
[Cost, Rtotal, ArrivalsGHP] = computeCost_GHP(ArrivalsGHP,Controlled,Exempt,ExemptFlying,Slots);
%Devuelve matriz de costes y el vector de slots ocupados
[CostGHP, Slots_Selected] = GHP_MATRIZ(Cost, Slots, Exempt, Controlled);
%Apartir de los Slots_Selected rellena toda la información necesaria
[Slots_GHP, GroundDelay_GHP, AirDelay_GHP, TotalDelay_GHP] = AssignSlots_GHP(ArrivalsGHP,Exempt, Controlled, Slots, Slots_Selected, Cost);

%% GHP
%Calcula el Unrecoverable Delay
[UnrecDelayGHP] = ComputeUnrecoverableDelay(Arrivals,Slots_GHP,HStart,HFileOpt);
%Asigna un time of arrival a TODOS los aviones despues de introducir la 
%regulacion. Ponemos [] donde iria la lista de cancelados ya que no
%cancelamos nada en GHP
[CTAGHP] = computeCTA(Arrivals, Slots_GHP, []);
%Calculate the new HNoReg
[HNoRegGHP] = AggregateDemandforSlots(CTAGHP, Arrivals, HStart, HEnd,PAAR,AAR);
%Deviations
[STDGHPAir, STDGHPGrnd, STDGHPTot, MeanGHPAir, MeanGHPGrnd, MeanGHPTotal, AirDelay_GHP2, GroundDelay_GHP2, TotalDelay_GHP2] = RelStd(Slots_GHP,HNoRegGHP,Controlled,Exempt);
%Histograma despues de aplicar la regulacion
HistogramaComputadoGHP = HistogramaComputado(CTAGHP,AAR,PAAR,HStart,HEnd);

%% WP4
%Miramos que vuelos son regionales 
[ITALIA_VUELOS] = computeItalia(Arrivals, Exempt, Controlled);
%Comprobamos si los vuelos a esas ciudades se pueden hacer en tren y hacemos comparativa Emisiones CO2 entre vuelo y tren
[TRENES_ITALIA] = computeTrenes(ITALIA_VUELOS);
%Creamos una nueva lista de Arrivals que no incluye los vuelos sustituidos
[Arrivals_Intermodality] = Arrivals(~ismember(Arrivals.flight_number, TRENES_ITALIA.ID), :);
%Nuevo Histograma
%Calculamos el HNoreg y el Delay minimo posible con Intermodality
[HNoReg_Intermodality,delay_Intermodality] = AggregateDemand(Arrivals_Intermodality, HStart, HEnd,PAAR,AAR);
%Generampos los slots vacios para intermodality
[Slots_Intermodality] = ComputeSlots_Intermodality(HStart,HEnd,HNoReg_Intermodality,PAAR,AAR);
%Calculamos los nuevos exempt y controlled
[NotAffected_Intermodality, Controlled_Intermodality, Exempt_Intermodality, ExemptHFile_Intermodality] = computeAircraftStatus(Arrivals_Intermodality, HFileOpt, HStart, HNoReg_Intermodality, RadioOpt);

%Eliminamos de la tabla de Slots los vuelos que pueden ir en tren por coste
[Slots_GDP_Intermodality] = assignSlotsGDP(Slots_Intermodality, Controlled_Intermodality, Exempt_Intermodality, NotAffected_Intermodality, ExemptHFile_Intermodality);
%Calcula la Epsilon para cada vuelo
[Arrivals_Intermodality] = computeEpsilon(Arrivals_Intermodality);

%Calcula el coste para cada vuelo
[Cost_GHP_Inter, Rtotal_GHP_Intermodality, Arrivals_Intermodality] = computeCost_GHP(Arrivals_Intermodality,Controlled_Intermodality,Exempt_Intermodality,ExemptHFile_Intermodality,Slots_Intermodality);
%Devuelve matriz de costes y el vector de slots ocupados
[Cost_GHP_Intermodality, Slots_Selected_GHP_Intermodality] = GHP_MATRIZ(Cost_GHP_Inter, Slots_Intermodality, Exempt_Intermodality, Controlled_Intermodality);

%Apartir de los Slots_Selected rellena toda la información necesaria
[Slots_GHP_Intermodality] = AssignSlots_GHP(Arrivals_Intermodality,Exempt_Intermodality, Controlled_Intermodality, Slots_Intermodality, Slots_Selected_GHP_Intermodality, Cost_GHP_Inter);

%% GDP_Intermodality
%Calcula el Unrecoverable Delay
[UnrecDelayGDP_Inter] = ComputeUnrecoverableDelay(Arrivals_Intermodality,Slots_GDP_Intermodality,HStart,HFileOpt);
%Computamos CTA para cancelado
[CTAGDP_Inter] = computeCTA(Arrivals_Intermodality, Slots_GDP_Intermodality, TRENES_ITALIA);
%Calculamos la nueva HNoReg
[HNoRegGDP_Inter] = AggregateDemandforSlots(CTAGDP_Inter, Arrivals_Intermodality, HStart, HEnd,PAAR,AAR);
%Calculamos medias y desviaciones estandar
[STDGDP_InterAir, STDGDP_InterGrnd, STDGDP_InterTot, MeanGDP_InterAir, MeanGDP_InterGrnd, MeanGDP_InterTotal, AirDelay_GDP_Inter, GroundDelay_GDP_Inter, TotalDelay_GDP_Inter] = RelStd(Slots_GDP_Intermodality, HNoRegGDP_Inter, Controlled_Intermodality, Exempt_Intermodality);
%Nuevo Histograma
HistogramaComputadoGDP_Inter = HistogramaComputado(CTAGDP_Inter,AAR,PAAR,HStart,HEnd);

%% GHP_Intermodality
%Calcula el Unrecoverable Delay
[UnrecDelayGHP_Inter] = ComputeUnrecoverableDelay(Arrivals_Intermodality,Slots_GHP_Intermodality,HStart,HFileOpt);
%Computamos CTA para cancelado
[CTAGHP_Inter] = computeCTA(Arrivals_Intermodality, Slots_GHP_Intermodality, TRENES_ITALIA);
%Calculamos la nueva HNoReg
[HNoRegGHP_Inter] = AggregateDemandforSlots(CTAGHP_Inter, Arrivals_Intermodality, HStart, HEnd,PAAR,AAR);
%Calculamos medias y desviaciones estandar
[STDGHP_InterAir, STDGHP_InterGrnd, STDGHP_InterTor, MeanGHP_InterAir, MeanGHP_InterGrnd, MeanGHP_InterTotal, AirDelay_GHP_Inter, GroundDelay_GHP_Inter, TotalDelay_GHP_Inter] = RelStd(Slots_GHP_Intermodality, HNoRegGHP_Inter, Controlled_Intermodality, Exempt_Intermodality);
%Nuevo Histograma
HistogramaComputadoGHP_Inter = HistogramaComputado(CTAGHP_Inter,AAR,PAAR,HStart,HEnd);

%% WP5 
% %Computar el coste de para GDP, GHP, Cancelados y intermodality

[CostGDP_Final, Slots_GDP_Final] = computeCost_Final(Slots_GDP, ArrivalsGHP, Exempt, Controlled);

[CostGDP_Cancelado_Final, Slots_GDP_Cancelado_Final] = computeCost_Final(Slots_Cancelled, ArrivalsGHP, Exempt, Controlled);

[CostGDP_Intermodality_Final, Slots_GDP_Intermodality_Final] = computeCost_Final(Slots_GDP_Intermodality, ArrivalsGHP, Exempt, Controlled);

[CostGHP_Final, Slots_GHP_Final] = computeCost_Final(Slots_GHP, ArrivalsGHP, Exempt, Controlled);

[CostGHP_Intermodality_Final, Slots_GHP_Intermodality_Final] = computeCost_Final(Slots_GHP_Intermodality, ArrivalsGHP, Exempt, Controlled);

[CostVoucher,CostGDP_Cancelado_Combinado] = CostofCancellations(AZA_Cancelled,Arrivals,Slots_GDP_Cancelado_Final);



















