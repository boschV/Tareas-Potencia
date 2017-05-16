function [Ybusf] = crearYbus3Fl(Ybus,barra1,barra2)
    Ybusf = Ybus;
    Yelem = Ybus(barra1,barra2);
    Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Yelem/2;
    Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Yelem/2;
    Ybusf(barra1,barra2) = 0;
    Ybusf(barra2,barra1) = 0;
end
