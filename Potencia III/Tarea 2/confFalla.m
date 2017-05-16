
function [TipoDeFalla,barra1,barra2,Zsecn,Zsec0] = confFalla(datosFalla)
    for i = 1:size(datosFalla,1)
        if datosFalla(i,1) ~= 0
            TipoDeFalla = i;
            barra1 = datosFalla(i,2);
            barra2 = datosFalla(i,3);
            Zsecn = datosFalla(i,4) + 1j*datosFalla(i,5);
            Zsec0 = datosFalla(i,6) + 1j*datosFalla(i,7);
            break;
        end
    end
end
