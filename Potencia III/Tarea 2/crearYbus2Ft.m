
function [Ybusf] = crearYbus2Ft(Ybus,bfalla,Zsecn,Zsec0)
    Ybusf = Ybus;
    Zthfalla = inv(Ybus(bfalla,bfalla));
    Zthfallabf = inv(inv(Zthfalla)+inv(Zthfalla));
    if (Zsecn ~= 0)&&(Zsec0 ~= 0)
        Zthfallabf = inv(inv(Zsecn) + inv(Zsec0));
    end    
    Ybusf(bfalla,bfalla) = Ybusf(bfalla,bfalla) + inv(Zthfallabf);
end
