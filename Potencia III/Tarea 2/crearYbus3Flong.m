function [Ybusf] = crearYbus3Flong(Ybus,barra1,barra2)
    Ybusf = Ybus;
    Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Ybusf(barra1,barra2); 
    Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Ybusf(barra1,barra2);
    Ybusf(barra1,barra2) = 0;
    Ybusf(barra2,barra1) = 0;
end
