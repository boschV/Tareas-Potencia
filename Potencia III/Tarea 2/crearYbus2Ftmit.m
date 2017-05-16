
function [Ybusf] = crearYbus2Ftmit(Ybus,BikShunt,barra1,barra2,Zsecn,Zsec0)
    Ybusf = Ybus;
    Ybusf(end+1,end+1) = -Ybus(barra1,barra2) + 1j*BikShunt(barra1,barra2);
    Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Ybus(barra1,barra2)/2 - ...
                           1j*BikShunt(barra1,barra2)/2;
    Ybusf(barra1,end) = Ybus(barra1,barra2)/2;
    Ybusf(end,barra1) = Ybusf(barra1,end);

    Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Ybus(barra1,barra2)/2 - ...
                           1j*BikShunt(barra2,barra1)/2;
    Ybusf(barra2,end) = Ybus(barra1,barra2)/2;
    Ybusf(end,barra2) = Ybusf(barra2,end);

    Ybusf(barra1,barra2) = 0;
    Ybusf(barra2,barra1) = 0;

    Zbusf = inv(Ybusf);
    Zth = Zbusf(end,end);
    Zfalla = inv(inv(Zth)+inv(Zth));
    if (Zsecn ~= 0)&&(Zsec0 ~= 0)
        Zfalla = inv(inv(Zsecn) + inv(Zsec0));
    end    
    Ybusf(end,end) = Ybusf(end,end) + inv(Zfalla);
end
