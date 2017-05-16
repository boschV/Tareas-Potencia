function [obj,BikShunt] = crearVecBar(datosbarras, datoslineas)

    [Ybus, BikShunt] = constYbus(datoslineas, datosbarras);
    
    barra.setgetYbus(Ybus);
    barra.setgetG(real(-Ybus));
    barra.setgetB(imag(-Ybus));
    barra.setgetBsh(BikShunt);
    
    N_barras = size(datosbarras, 1);
    
    for i = 1:N_barras+1
        if i <= N_barras
            ID = datosbarras(i,1);
            Tipo = datosbarras(i,2);
            V = datosbarras(i,3);
            A = datosbarras(i,4);

            Pg = datosbarras(i,5);
            Pc = datosbarras(i,7);

            Qg = datosbarras(i,6);
            Qc = datosbarras(i,8);

            Z = 0;

            for j = 1:size(datoslineas,1)
                if (datoslineas(j,1) == ID) && (datoslineas(j,2) == ID)
                   if Z ~= 0
                       Z = inv(inv(Z) + inv(datoslineas(j,3) + 1j*datoslineas(j,4)));
                   else
                       Z = datoslineas(j,3) + 1j*datoslineas(j,4);
                   end
                end
            end
        else
            ID = N_barras+1;
            Tipo = 3;
            V = 0;
            A = 0;

            Pg = 0;
            Pc = 0;

            Qg = 0;
            Qc = 0;

            Z = 0;
        end
        Ady = [];
        
        for j = 1:size(Ybus, 1)
            if (ID ~= j) && (Ybus(ID,j) ~= 0)
                Ady(end+1) = j;
            end
        end
        
        obj(ID) = barra(ID, Tipo, Ady, V, A, Z, Pg, Qg, Pc, Qc);

    end
end
