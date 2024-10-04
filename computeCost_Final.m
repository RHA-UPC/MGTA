function [cost,Slots] = computeCost_Final(Slots, Arrivals, Exempt, Controlled)


Arrivals_modified = [];

for i = 1:height(Arrivals)
    if ismember(Arrivals.flight_number(i), Exempt.FlightNumber) || ismember(Arrivals.flight_number(i), Controlled.FlightNumber)
        Arrivals_modified = [Arrivals_modified; Arrivals(i, :)];
    end
end



for i = 1:height(Slots)
    for j = 1:height(Arrivals_modified)

            if strcmp(Slots.ID(i),Arrivals_modified.flight_number(j))

                if Slots.TotalDelay(i) <=15
                   Rtotal = Arrivals_modified.R(j) + 0.05*Arrivals_modified.pax(j);
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=31 && Slots.TotalDelay(i) >15
                   Rtotal= Arrivals_modified.R(j) + 0.12*Arrivals_modified.pax(j);
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=45 && Slots.TotalDelay(i) >31
                   Rtotal= Arrivals_modified.R(j) + 0.16*Arrivals_modified.pax(j);
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=60 && Slots.TotalDelay(i) >45
                   Rtotal= Arrivals_modified.R(j) + 0.19*Arrivals_modified.pax(j); 
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=75 && Slots.TotalDelay(i) >60
                   Rtotal= Arrivals_modified.R(j) + 0.21*Arrivals_modified.pax(j); 
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=90 && Slots.TotalDelay(i) >75
                   Rtotal= Arrivals_modified.R(j) + 0.23*Arrivals_modified.pax(j); 
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=120 && Slots.TotalDelay(i) >90
                   Rtotal= Arrivals_modified.R(j) + 0.32*Arrivals_modified.pax(j); 
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=180 && Slots.TotalDelay(i) >120
                   Rtotal= Arrivals_modified.R(j) + 0.48*Arrivals_modified.pax(j);
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=240 && Slots.TotalDelay(i) >180
                   Rtotal=  Arrivals_modified.R(j) + 0.63*Arrivals_modified.pax(j);; 
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) <=300 && Slots.TotalDelay(i) >240
                   Rtotal= Arrivals_modified.R(j) + 0.66*Arrivals_modified.pax(j);;
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));

                elseif Slots.TotalDelay(i) >300
                   Rtotal= Arrivals_modified.R(j) + 0.88*Arrivals_modified.pax(j);;
                   Slots.Cost(i) = Rtotal*(Slots.TotalDelay(i))^(1+Arrivals_modified.epsilon(j));
                end 

            end
    end
end

cost = cumsum(Slots.Cost);
cost = cost(end);


end