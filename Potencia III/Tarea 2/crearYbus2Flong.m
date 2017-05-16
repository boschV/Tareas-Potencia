
function [Ybusf] = crearYbus2Flong(Ybus,obj,ngen,barra1,barra2,Zsecn,Zsec0)
    YbusK = zeros(size(Ybus,2)+ngen);

    j=1;
    for i = 1:size(obj,2)
         if obj(i).Gen == 1
             YbusK(j,j) = YbusK(j,j) + inv(obj(i).Zg); 
             YbusK(j,i+ngen) = YbusK(j,i+ngen) - inv(obj(i).Zg);
             YbusK(i+ngen,j) = YbusK(j,i+ngen);
             j=j+1;
        end
    end
    YbusK(ngen+1:end,ngen+1:end) = Ybus;
    Inter1 = barra1+ngen;
    Inter2 = barra2+ngen;
    YbusK = IntercambioB(YbusK,Inter1,1);
    YbusK = IntercambioB(YbusK,Inter2,2);

    A = YbusK(1:2,1:2);
    B = YbusK(1:2,2+1:end);
    C = YbusK(2+1:end,1:2);
    D = YbusK(2+1:end,2+1:end);

    Kron = A - B*(D\C);
    Zkron = inv(-Kron(1,2));
    Zth= Zkron + Zkron;
    if (Zsecn ~= 0)&&(Zsec0 ~= 0)
        Zth = Zsecn + Zsec0;
    end
    Ybusf = Ybus;
    Ybusf(barra1,barra2) = Ybusf(barra1,barra2) - inv(Zth);
    Ybusf(barra2,barra1) = Ybusf(barra1,barra2);
    Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + inv(Zth);
    Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + inv(Zth);
end
