function [res] = SisFalla(obj,Ybusf,dt,incog,dviej,Pev,bfalla)
    ngen = 0;
    Iny = zeros(size(obj,2)-1,1);
    
    for i=1:size(obj,2)-1
        if obj(i).Gen == 1
            obj(i).E = abs(obj(i).E)*exp(1j*obj(i).del);
            obj(i).del = incog(2*i);
            obj(i).omg = incog(2*i-1);
         %Calculo del vector de corrientes inyectadas
            obj(i).Iny = obj(i).E/obj(i).Zg;
            Iny(i) = obj(i).E/obj(i).Zg;            
            ngen = ngen + 1;
        else
            obj(i).Iny = 0;
            Iny(i) = 0;  
        end
    end

    
    if bfalla > 0
        %borra la columna afectada
        Iny = [Iny(1:bfalla-1);Iny(bfalla+1:end)];
    elseif bfalla == -1
        Iny = [Iny;0];
    end
    
    Vbusp = inv(Ybusf)*Iny;
    Vbus = zeros(size(obj,2)-1,1);

    j = 1;
    for  i = 1:size(obj,2)-1
        if obj(i).Falla3f == 1
            obj(i).V = 0;
        else
            Vbus(i) = Vbusp(j);
            obj(i).V = abs(Vbusp(j));
            obj(i).A = angle(Vbusp(j));
            j = j+1;
        end
    end

    res = [];
    j=0;
    for i=1:size(obj,2)-1
        if obj(i).Gen == 1
            j = j+1;
            obj(i).Pe = obj(i).Pelec();
            res(end+1:end+2) = obj(i).Feq(dviej(2*j),dviej(2*j-1),Pev(j),dt);
        end
    end
    
    barra.setgetData(obj);
end

