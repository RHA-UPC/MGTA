function [costGHP,x] = GHP_MATRIZ(cfs,slots,Exempt,Controlled)

Slots_table = cell2table(slots,'VariableNames', {'Slot_time', 'ID', 'Airline'});



% ---------CONSTRAIN------IGUALDADES-------
% matriz A 

num_Exempt = height(Exempt);
num_Controlled = height(Controlled);

num_flights = num_Exempt + num_Controlled;
num_slots = height(Slots_table);

A = zeros(num_flights, num_flights * num_slots);

for f = 1:num_flights
    A(f, (f-1)*num_slots + 1 : f*num_slots) = 1;
end

% disp(A);

% matriz B
BFEA =ones(1, num_flights);
B = BFEA';

% disp(B);

%-------INIGUALDADES-------
% MATRIZ Aineq nombres los tengo que cambiar 
tope = num_slots*num_flights;
AINQ = zeros(num_slots,num_slots*num_flights);
for i = 1:tope
    AINQ(mod(i-1, num_slots)+1, i) = 1;
end
% disp(AINQ);

% matriz Bineq

Bcardo = ones(1, num_slots);
BINQ = Bcardo';

% disp(BINQ);
% ------ limites----
lb=zeros(1, tope);
ub=[];
int=1:tope;
[x,costGHP] = intlinprog(cfs,int,AINQ,BINQ ,A,B,lb,ub);
% 0BSERVACION : en x se encuentra cada lenght(slots) la posición en la que se asigna el

end