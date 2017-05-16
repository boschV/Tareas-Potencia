function [Ybusf] = crearYbus3Fb(Ybus,bfalla)
    Ybusf = [Ybus(1:bfalla-1,1:bfalla-1),   Ybus(1:bfalla-1,bfalla+1:end);
             Ybus(bfalla+1:end,1:bfalla-1), Ybus(bfalla+1:end,bfalla+1:end)];
end
