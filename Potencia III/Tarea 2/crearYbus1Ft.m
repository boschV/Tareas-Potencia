
function [Ybusf] = crearYbus1Ft(Ybus,bfalla,Zsecn,Zsec0)
    Ybusf = Ybus;
    Zthfalla = inv(Ybus(bfalla,bfalla));
    Zth = Zthfalla + Zthfalla;
    if (Zsecn ~= 0)&&(Zsec0 ~= 0)
        Zth = Zsecn + Zsec0;
    end
    Ybusf(bfalla,bfalla) = Ybusf(bfalla,bfalla) + inv(Zth);
end
