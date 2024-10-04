function [Arrivals] = computeEpsilon(Arrivals)
% Assume around 33.3% of passangers have another conexion
% In order to make the calculations easier we will select every third row

Arrivals.Conexion = zeros(height(Arrivals), 1);

Arrivals.epsilon = zeros(height(Arrivals), 1);

Arrivals.Conexion(3:3:end) = 1;

Aviones = readtable("DataAir.xlsx","Sheet", "Aircraft");

% Supongamos una R para un A320 y A380 y asumimos una distancia de
% hasta 8000 km para ground delay y una compensacion media de 0.2€ por
% pasajero

fuel_cost = 0.5; %€/kg
pilot_cost = 50; %€/h
crew_cost = 14; %€/h

for i = 1:height(Aviones)
    Aviones.APUhconsumption(i) = Aviones.APUhconsumption(i) * fuel_cost;
    if strcmp(Aviones.aircraft(i),'A320')
        costGround_A320 = Aviones.APUhconsumption(i);
        costAir_A320 = Aviones.chourly(i);
    elseif strcmp(Aviones.aircraft(i),'A388')
        costGround_A380 = Aviones.APUhconsumption(i);
        costAir_A380 = Aviones.chourly(i);


    end
end


R_A320 = ((4*pilot_cost)+ (8*crew_cost) + costGround_A320)/60;
R_A380 = ((4*pilot_cost) + (20*crew_cost)+ costGround_A380)/60;

Rtotal_A320 = R_A320 + 0.2*149;
Rtotal_A380 = R_A380 + 0.2*678;


epsilon_values = [0.2,0.4,0.6,0.8];


delay = 0:180;
figure;

for i = 1:length(epsilon_values)
    epsilon = epsilon_values(i);
    cost_A320 = Rtotal_A320*delay.^(1+epsilon);
    cost_A380 = Rtotal_A380*delay.^(1+epsilon);
    plot(delay, cost_A320, 'DisplayName', ['A320, Epsilon = ' num2str(epsilon)]);
    hold on;
    plot(delay, cost_A380, 'DisplayName', ['A380, Epsilon = ' num2str(epsilon)]);
    hold on;
end

xlabel('Delay (minutes)');
ylabel('Cost (€)');
title('Cost vs Ground Delay for A320 and A380');
legend('show');

R_A320 = ((4*pilot_cost)+ (8*crew_cost) + costAir_A320)/60;
R_A380 = ((4*pilot_cost) + (20*crew_cost)+ costAir_A380)/60;

Rtotal_A320 = R_A320 + 0.2*149;
Rtotal_A380 = R_A380 + 0.2*678;

delay = 0:60;
figure;
for i = 1:length(epsilon_values)
    epsilon = epsilon_values(i);
    cost_A320 = Rtotal_A320*delay.^(1+epsilon);
    cost_A380 = Rtotal_A380*delay.^(1+epsilon);
    plot(delay, cost_A320, 'DisplayName', ['A320, Epsilon = ' num2str(epsilon)]);
    hold on;
    plot(delay, cost_A380, 'DisplayName', ['A380, Epsilon = ' num2str(epsilon)]);
    hold on;
end

xlabel('Delay (minutes)');
ylabel('Cost (€)');
title('Cost vs Air Delay for A320 and A380');
legend('show');



for i =1: height(Arrivals)
    if Arrivals.Conexion(i) == 0
        Arrivals.epsilon(i) = 0.2;
    elseif Arrivals.Conexion(i) == 1
        Arrivals.epsilon(i) = 0.6;
    end
end
