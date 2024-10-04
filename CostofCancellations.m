function [CostVoucher,CostGDP_Cancelado_Combinado] = CostofCancellations(Cancelados,Arrivals,Slots_GDP_Cancelado_Final)
for i = 1:height(Cancelados)
    if ismember(Cancelados.ID(i),Arrivals.flight_number)
        rowIndex = Arrivals.flight_number == Cancelados.ID(i);
        Cancelados.Pax(i) = Arrivals.pax(rowIndex);
        Cancelados.Distancia(i) = Arrivals.distance(rowIndex);
        Cancelados.Community(i) = Arrivals.CEAC(rowIndex);
    end
end

for i = 1:height(Cancelados)
    if (Cancelados.Distancia(i) <= 1500)
        Cancelados.Precio(i) = (250+100)*Cancelados.Pax(i);
    elseif (Cancelados.Distancia(i) > 1500) && (Cancelados.Distancia(i) <= 3500) && (Cancelados.Community(i) == 0)
        Cancelados.Precio(i) = (400+100)*Cancelados.Pax(i);
    elseif (Cancelados.Distancia(i) > 1500) && (Cancelados.Community(i) == 1)
        Cancelados.Precio(i) = (400+100)*Cancelados.Pax(i);
    elseif (Cancelados.Distancia(i) > 3500) && (Cancelados.Community(i) == 0)
        Cancelados.Precio(i) = (600+100)*Cancelados.Pax(i);
    end
end

CostVoucher = cumsum(Cancelados.Precio);
CostVoucher = ceil(CostVoucher(end));

CostNoCancelados = cumsum(Slots_GDP_Cancelado_Final.Cost);
CostNoCancelados = ceil(CostNoCancelados(end));

CostGDP_Cancelado_Combinado = CostVoucher + CostNoCancelados;
end
