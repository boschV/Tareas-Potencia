function [Ybus, BikShunt] = constYbus(datoslineas, datosbarras)
    
    N_barras = size(datosbarras, 1);
    N_lineas = size(datoslineas, 1);
    
    Ybus=zeros(N_barras+1);
    
    %Se rellena la Ybus
    for i = 1:size(datoslineas,1)
        if datoslineas(i,1) == datoslineas(i,2)
            Ybus(datoslineas(i,1),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,1))+inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(end,end)=Ybus(end,end)+inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(datoslineas(i,1),end)=Ybus(datoslineas(i,1),end)-inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(end,datoslineas(i,1))=Ybus(datoslineas(i,1),end);
        else 
            Ybus(datoslineas(i,1),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,1))+inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(datoslineas(i,1),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,1))+ 1j*datoslineas(i,5);
            Ybus(end,end)=Ybus(end,end)+ 1j*datoslineas(i,5);

            Ybus(datoslineas(i,2),datoslineas(i,2))=Ybus(datoslineas(i,2),datoslineas(i,2))+inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(datoslineas(i,2),datoslineas(i,2))=Ybus(datoslineas(i,2),datoslineas(i,2))+ 1j*datoslineas(i,6);
            Ybus(end,end)=Ybus(end,end)+ 1j*datoslineas(i,6);
            
            Ybus(datoslineas(i,1),datoslineas(i,2))=Ybus(datoslineas(i,1),datoslineas(i,2))-inv(datoslineas(i,3)+1j*datoslineas(i,4));
            Ybus(datoslineas(i,2),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,2));
            
            Ybus(datoslineas(i,1),end)=Ybus(datoslineas(i,1),end)- 1j*datoslineas(i,5);
            Ybus(end,datoslineas(i,1))=Ybus(end,datoslineas(i,1))- 1j*datoslineas(i,5);
            
            Ybus(datoslineas(i,2),end)=Ybus(datoslineas(i,2),end)- 1j*datoslineas(i,6);
            Ybus(end,datoslineas(i,2))=Ybus(end,datoslineas(i,2))- 1j*datoslineas(i,6);
        end
    end
    
    %BikShunt Solo incluye los datos de las lineas
    BikShunt= zeros(N_barras);
    for i = 1:size(datoslineas,1)

        if datoslineas(i,1) ~= datoslineas(i,2)
           BikShunt(datoslineas(i,1),datoslineas(i,2))= datoslineas(i,5);
           BikShunt(datoslineas(i,2),datoslineas(i,1))= datoslineas(i,6);
        end
    end
end
