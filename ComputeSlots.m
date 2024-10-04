function slots = ComputeSlots(Hstart,Hend,HNoReg,PAAR,AAR)
Slots_AAR = 60/AAR;
% REDONDEAR mas bajo o al mas alto;
Slots_PAAR = 60/PAAR;

time1 = Hstart+4: Slots_PAAR :Hend;
% si quiero añadir mas slots lo que deberia hacer es sumarle tiempo al h noreg
time2= Hend+Slots_AAR:Slots_AAR:HNoReg-1.5;
time=[time1 time2];
id = zeros(1,length(time));
Airline = zeros(1,length(time));

slots(1,:)=time;

slots(2,:)=id;

slots(3,:)=Airline;

slots=slots';

slots = num2cell(slots, 3);

end