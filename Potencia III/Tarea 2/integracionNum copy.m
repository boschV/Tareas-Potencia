clear
close all
tic

opts = optimoptions(@fsolve,'Display','off','MaxFunctionEvaluations',10000,'MaxIterations',10000);
filename = 'input.xlsx';
[datosbarras] = xlsread(filename,1);
[datoslineas] = xlsread(filename,2);
[datosGen] = xlsread(filename,3);
[datosFalla] = xlsread(filename,4);
[datosSim] = xlsread(filename,5);

[obj,BikShunt] = crearVecBar(datosbarras, datoslineas);

obj = confGen(datosGen,obj);

Ybus1 = barra.setgetYbus();
Ybus = Ybus1(1:3,1:3);

barra.setgetData(obj);

[obj,res,ef]=barra.FCsolve();

%Se calcula el numero de generadores
ngen = 0;
j=1;
for i = 1:size(obj,2)-1
    Graf(j) = dGraf();
    Graf(j).ID = obj(i).ID;
    if obj(i).Gen == 1
        ngen = ngen+1;
        Graf(j).Gen = 1;
    end
    j=j+1;
end


for i = 1:size(obj,2)-1
    if obj(i).Tipo == 2
        obj(i).Z = 0;
        if obj(i).Z == 0
            obj(i).Z = (conj(((obj(i).V)^2)/(-obj(i).P-1j*obj(i).Q)));
        else
            obj(i).Z = inv(inv(obj(i).Z) + inv(conj(((obj(i).V)^2)/(-obj(i).P-1j*obj(i).Q))));
        end
        Ybus(i,i) = Ybus(i,i) + inv(obj(i).Z);

    elseif (obj(i).Tipo == 1) || (obj(i).Tipo == 0)
        Ybus(i,i) = Ybus(i,i) + inv(obj(i).Zg);
    end
end


[tsim,durFalla,tfalla,dt,frec] = confSim(datosSim);

barra.setgetW0(2*pi*frec);

[TipoDeFalla,barra1,barra2,Zsecn,Zsec0] = confFalla(datosFalla);


switch TipoDeFalla
    case 1
        %%Fallas trifasicas en barra
        obj(barra1).Falla3f = 1;
        Ybusf = crearYbus3Fb(Ybus,barra1);
    case 2
        %%falla trifasica a mitad de linea
        Ybusf = crearYbus3Fl(Ybus,barra1,barra2);
    case 3
        %%Fallas monofasicas a tierra en barra
        Ybusf = crearYbus1Ft(Ybus,barra1,Zsecn,Zsec0);
    case 4
        %%Fallas bifasicas a tierra en barra
        Ybusf = crearYbus2Ft(Ybus,barra1,Zsecn,Zsec0);
    case 5
        %%Fallas monofasicas transversales en mitad de linea
        Ybusf = crearYbus1Ftmit(Ybus,BikShunt,barra1,barra2,Zsecn,Zsec0);        
    case 6
        %%Fallas bifasicas transversales a mitad de linea
        Ybusf = crearYbus2Ftmit(Ybus,BikShunt,barra1,barra2,Zsecn,Zsec0);        
    case 7
        %%falla longitudinal monofasica
        Ybusf = crearYbus1Flong(Ybus,obj,ngen,barra1,barra2,Zsecn,Zsec0);
    case 8
        %%falla longitudinal bifasica
        Ybusf = crearYbus2Flong(Ybus,obj,ngen,barra1,barra2,Zsecn,Zsec0);
    case 9
        %%Falla longitudinal trifasica
        Ybusf = crearYbus3Flong(Ybus,barra1,barra2);
end

%Se calcula la E inicial
for i = 1:size(obj,2)-1
    if (obj(i).Tipo == 1) || (obj(i).Tipo == 0)
        I = 0;
        Vpi = obj(i).V*exp(1j*obj(i).A);
        
        I = conj((obj(i).P+1j*obj(i).Q)/(abs(obj(i).V)*exp(1j*obj(i).A)));
        obj(i).E = Vpi + I*obj(i).Zg;
        obj(i).mE = abs(obj(i).E);
        obj(i).Ag = angle(Vpi + I*obj(i).Zg);
        obj(i).del = obj(i).Ag;
    end
end


%Se calcula la potencia mecanica inicial
for i = 1:size(obj,2)-1
    if obj(i).Gen == 1
        obj(i).Pm = obj(i).Pelec();
        obj(i).Pe = obj(i).Pelec();
    end
end


ValIni = [];
Pev = [];
for i = 1:size(obj,2)-1
    if obj(i).Gen == 1
        ValIni(end+1) = 0;
        ValIni(end+1) = obj(i).Ag;
        
        Pev(end+1) = obj(i).Pm; 
    end
end

switch TipoDeFalla
    case 1
        modI = TipoDeFalla;
    case {5, 6}
        modI = -1;
    otherwise
        modI = 0;
end
  
h = 0; 
for t = 0:dt:tsim
    h = h+1;
    
    if t <= tfalla
        res1 = ValIni;
        Graf = insertarValorGraf(obj,Graf,t);
    elseif (t > tfalla) && (t <= tfalla+durFalla)
        dviej = ValIni;
        [res1] = fsolve(@(incog)SisFalla(obj,Ybusf,dt,incog,dviej,Pev,modI), ValIni,opts);
        obj = barra.setgetData();
        dviej = res1;
        j = 1;
        Pev = [];
        for i = 1:size(obj,2)-1
            if obj(i).Gen == 1
                obj(i).omg = res1(2*j-1);
                obj(i).del = res1(2*j);
                Pev(end+1) = obj(i).Pe;
            end
        end
        ValIni = res1;
        Graf = insertarValorGraf(obj,Graf,t);
    else
        for i = 1:size(obj,2)
            obj(i).Falla3f = 0;
        end
        dviej = ValIni;
        [res1] = fsolve(@(incog)SisFalla(obj,Ybus,dt,incog,dviej,Pev,0), ValIni,opts);
        obj = barra.setgetData();
        dviej = res1;
        j = 1;
        Pev = [];
        for i = 1:size(obj,2)-1
            if obj(i).Gen == 1
                obj(i).omg = res1(2*j-1);
                obj(i).del = res1(2*j);
                Pev(end+1) = obj(i).Pe;
                j = j+1;
            end
        end
        ValIni = res1;
        Graf = insertarValorGraf(obj,Graf,t);
    end

end

figure;
for i = 1:size(Graf,2)
    if Graf(i).Gen == 1
        Graf(i).plotOmgG();
    end
    hold on;
end
hold off;
xlabel('Tiempo (s)');
ylabel('Velocidad relativa de los Generadores');
title('Tiempo vs. Velocidad de los Generadores');
legend('show');

figure;
for i = 1:size(Graf,2)
    if Graf(i).Gen == 1
        Graf(i).plotDelG();
    end
    hold on;
end
hold off;
xlabel('Tiempo (s)');
ylabel('Angulo de los Generadores');
title('Tiempo vs. Angulo de los Generadores');
legend('show');

for i = 1:size(Graf,2)
    Graf(i).plotTodo();
end
toc



% 
% function [res] = SisFalla(obj,Ybusf,dt,incog,dviej,Pev,bfalla)
%     ngen = 0;
%     Iny = zeros(size(obj,2)-1,1);
%     
%     for i=1:size(obj,2)-1
%         if obj(i).Gen == 1
%             obj(i).E = abs(obj(i).E)*exp(1j*obj(i).del);
%             obj(i).del = incog(2*i);
%             obj(i).omg = incog(2*i-1);
%          %Calculo del vector de corrientes inyectadas
%             obj(i).Iny = obj(i).E/obj(i).Zg;
%             Iny(i) = obj(i).E/obj(i).Zg;            
%             ngen = ngen + 1;
%         else
%             obj(i).Iny = 0;
%             Iny(i) = 0;  
%         end
%     end
% 
%     
%     if bfalla > 0
%         %borra la columna afectada
%         Iny = [Iny(1:bfalla-1);Iny(bfalla+1:end)];
%     elseif bfalla == -1
%         Iny = [Iny;0];
%     end
%     
%     Vbusp = inv(Ybusf)*Iny;
%     Vbus = zeros(size(obj,2)-1,1);
% 
%     j = 1;
%     for  i = 1:size(obj,2)-1
%         if obj(i).Falla3f == 1
%             obj(i).V = 0;
%         else
%             Vbus(i) = Vbusp(j);
%             obj(i).V = abs(Vbusp(j));
%             obj(i).A = angle(Vbusp(j));
%             j = j+1;
%         end
%     end
% 
%     res = [];
%     j=0;
%     for i=1:size(obj,2)-1
%         if obj(i).Gen == 1
%             j = j+1;
%             obj(i).Pe = obj(i).Pelec();
%             res(end+1:end+2) = obj(i).Feq(dviej(2*j),dviej(2*j-1),Pev(j),dt);
%         end
%     end
%     
%     barra.setgetData(obj);
% end
% 
% function [Ybusf] = crearYbus3Fb(Ybus,bfalla)
%     Ybusf = [Ybus(1:bfalla-1,1:bfalla-1),   Ybus(1:bfalla-1,bfalla+1:end);
%              Ybus(bfalla+1:end,1:bfalla-1), Ybus(bfalla+1:end,bfalla+1:end)];
% end
% 
% function [Ybusf] = crearYbus3Fl(Ybus,barra1,barra2)
%     Ybusf = Ybus;
%     Yelem = Ybus(barra1,barra2);
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Yelem/2;
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Yelem/2;
%     Ybusf(barra1,barra2) = 0;
%     Ybusf(barra2,barra1) = 0;
% end
% 
% function [Ybusf] = crearYbus1Ft(Ybus,bfalla,Zsecn,Zsec0)
%     Ybusf = Ybus;
%     Zthfalla = inv(Ybus(bfalla,bfalla));
%     Zth = Zthfalla + Zthfalla;
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zth = Zsecn + Zsec0;
%     end
%     Ybusf(bfalla,bfalla) = Ybusf(bfalla,bfalla) + inv(Zth);
% end
% 
% function [Ybusf] = crearYbus2Ft(Ybus,bfalla,Zsecn,Zsec0)
%     Ybusf = Ybus;
%     Zthfalla = inv(Ybus(bfalla,bfalla));
%     Zthfallabf = inv(inv(Zthfalla)+inv(Zthfalla));
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zthfallabf = inv(inv(Zsecn) + inv(Zsec0));
%     end    
%     Ybusf(bfalla,bfalla) = Ybusf(bfalla,bfalla) + inv(Zthfallabf);
% end
% 
% function [Ybusf] = crearYbus1Ftmit(Ybus,BikShunt,barra1,barra2,Zsecn,Zsec0)
%     Ybusf = Ybus;
%     Ybusf(end+1,end+1) = -Ybus(barra1,barra2) + 1j*BikShunt(barra1,barra2);
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Ybus(barra1,barra2)/2 - ...
%                            1j*BikShunt(barra1,barra2)/2;
%     Ybusf(barra1,end) = -Ybus(barra1,barra2)/2;
%     Ybusf(end,barra1) = Ybusf(barra1,end);
% 
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Ybus(barra1,barra2)/2 - ...
%                            1j*BikShunt(barra2,barra1)/2;
%     Ybusf(barra2,end) = -Ybus(barra1,barra2)/2;
%     Ybusf(end,barra2) = Ybusf(barra2,end);
%     Ybusf(barra1,barra2) = 0;
%     Ybusf(barra2,barra1) = 0;
% 
%     Zbusf = inv(Ybusf);
%     Zths = Zbusf(end,end);
%     Zth = Zths+Zths;
%     
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zth = Zsecn + Zsec0;
%     end   
%     Ybusf(end,end) = Ybusf(end,end) + inv(Zth);
% end
% 
% function [Ybusf] = crearYbus2Ftmit(Ybus,BikShunt,barra1,barra2,Zsecn,Zsec0)
%     Ybusf = Ybus;
%     Ybusf(end+1,end+1) = -Ybus(barra1,barra2) + 1j*BikShunt(barra1,barra2);
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Ybus(barra1,barra2)/2 - ...
%                            1j*BikShunt(barra1,barra2)/2;
%     Ybusf(barra1,end) = Ybus(barra1,barra2)/2;
%     Ybusf(end,barra1) = Ybusf(barra1,end);
% 
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Ybus(barra1,barra2)/2 - ...
%                            1j*BikShunt(barra2,barra1)/2;
%     Ybusf(barra2,end) = Ybus(barra1,barra2)/2;
%     Ybusf(end,barra2) = Ybusf(barra2,end);
% 
%     Ybusf(barra1,barra2) = 0;
%     Ybusf(barra2,barra1) = 0;
% 
%     Zbusf = inv(Ybusf);
%     Zth = Zbusf(end,end);
%     Zfalla = inv(inv(Zth)+inv(Zth));
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zfalla = inv(inv(Zsecn) + inv(Zsec0));
%     end    
%     Ybusf(end,end) = Ybusf(end,end) + inv(Zfalla);
% end
% 
% function [Ybusf] = crearYbus1Flong(Ybus,obj,ngen,barra1,barra2,Zsecn,Zsec0)
%     YbusK = zeros(size(Ybus,2)+ngen);
% 
% 
%     j=1;
%     for i = 1:size(obj,2)
%          if obj(i).Gen == 1
%              YbusK(j,j) = YbusK(j,j) + inv(obj(i).Zg); 
%              YbusK(j,i+ngen) = YbusK(j,i+ngen) - inv(obj(i).Zg);
%              YbusK(i+ngen,j) = YbusK(j,i+ngen);
%              j=j+1;
%         end
%     end
%     YbusK(ngen+1:end,ngen+1:end) = Ybus;
%     Inter1 = barra1+ngen;
%     Inter2 = barra2+ngen;
%     YbusK = IntercambioB(YbusK,Inter1,1);
%     YbusK = IntercambioB(YbusK,Inter2,2);
% 
%     A = YbusK(1:2,1:2);
%     B = YbusK(1:2,2+1:end);
%     C = YbusK(2+1:end,1:2);
%     D = YbusK(2+1:end,2+1:end);
% 
%     Kron = A - B*(D\C);
%     Zkron = inv(-Kron(1,2));
%     Zth= inv(inv(Zkron)+inv(Zkron));
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zth = inv(inv(Zsecn) + inv(Zsec0));
%     end
%     Ybusf = Ybus;
%     Ybusf(barra1,barra2) = Ybusf(barra1,barra2) - inv(Zth);
%     Ybusf(barra2,barra1) = Ybusf(barra1,barra2);
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + inv(Zth);
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + inv(Zth);
% end
% 
% function [Ybusf] = crearYbus2Flong(Ybus,obj,ngen,barra1,barra2,Zsecn,Zsec0)
%     YbusK = zeros(size(Ybus,2)+ngen);
% 
%     j=1;
%     for i = 1:size(obj,2)
%          if obj(i).Gen == 1
%              YbusK(j,j) = YbusK(j,j) + inv(obj(i).Zg); 
%              YbusK(j,i+ngen) = YbusK(j,i+ngen) - inv(obj(i).Zg);
%              YbusK(i+ngen,j) = YbusK(j,i+ngen);
%              j=j+1;
%         end
%     end
%     YbusK(ngen+1:end,ngen+1:end) = Ybus;
%     Inter1 = barra1+ngen;
%     Inter2 = barra2+ngen;
%     YbusK = IntercambioB(YbusK,Inter1,1);
%     YbusK = IntercambioB(YbusK,Inter2,2);
% 
%     A = YbusK(1:2,1:2);
%     B = YbusK(1:2,2+1:end);
%     C = YbusK(2+1:end,1:2);
%     D = YbusK(2+1:end,2+1:end);
% 
%     Kron = A - B*(D\C);
%     Zkron = inv(-Kron(1,2));
%     Zth= Zkron + Zkron;
%     if (Zsecn ~= 0)&&(Zsec0 ~= 0)
%         Zth = Zsecn + Zsec0;
%     end
%     Ybusf = Ybus;
%     Ybusf(barra1,barra2) = Ybusf(barra1,barra2) - inv(Zth);
%     Ybusf(barra2,barra1) = Ybusf(barra1,barra2);
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + inv(Zth);
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + inv(Zth);
% end
% function [Ybusf] = crearYbus3Flong(Ybus,barra1,barra2)
%     Ybusf = Ybus;
%     Ybusf(barra1,barra1) = Ybusf(barra1,barra1) + Ybusf(barra1,barra2); 
%     Ybusf(barra2,barra2) = Ybusf(barra2,barra2) + Ybusf(barra1,barra2);
%     Ybusf(barra1,barra2) = 0;
%     Ybusf(barra2,barra1) = 0;
% end
% function [YbusK] = IntercambioB(YbusK,Inter1,Inter2)
%     Aux1H = YbusK(Inter1,:);
%     Aux1 = Aux1H(Inter1);
%     Aux1H(Inter1) = Aux1H(Inter2);
%     Aux1H(Inter2) = Aux1;
% 
%     Aux1V = YbusK(:,Inter1);
%     Aux1 = Aux1V(Inter1);
%     Aux1V(Inter1) = Aux1V(Inter2);
%     Aux1V(Inter2) = Aux1;
% 
%     Aux2H = YbusK(Inter2,:);
%     Aux1 = Aux2H(Inter1);
%     Aux2H(Inter1) = Aux2H(Inter2);
%     Aux2H(Inter2) = Aux1;
% 
%     Aux2V = YbusK(:,Inter2);
%     Aux1 = Aux2V(Inter1);
%     Aux2V(Inter1) = Aux2V(Inter2);
%     Aux2V(Inter2) = Aux1;
% 
%     YbusK(Inter1,:) = Aux2H;
%     YbusK(:,Inter1) = Aux2V;
% 
%     YbusK(Inter2,:) = Aux1H;
%     YbusK(:,Inter2) = Aux1V;
% end
% 
% function [obj]= confGen(dGen,obj)
%     for i = 1:size(obj,2)
%         for j = 1:size(dGen,1)
%             if i == dGen(j,1)
%                 obj(i).Gen = 1;
%                 obj(i).Zg = dGen(j,2)+1j*dGen(j,3);
%                 obj(i).H = dGen(j,4);
%                 obj(i).K = dGen(j,5);
%                 obj(i).omg = 0;
%             end
%         end
%     end
% end
% 
% function [TipoDeFalla,barra1,barra2,Zsecn,Zsec0] = confFalla(datosFalla)
%     for i = 1:size(datosFalla,1)
%         if datosFalla(i,1) ~= 0
%             TipoDeFalla = i;
%             barra1 = datosFalla(i,2);
%             barra2 = datosFalla(i,3);
%             Zsecn = datosFalla(i,4) + 1j*datosFalla(i,5);
%             Zsec0 = datosFalla(i,6) + 1j*datosFalla(i,7);
%             break;
%         end
%     end
% end
% 
% function [tsim,durFalla,tfalla,dt,frec] = confSim(datosSim)
% 
%     tsim = datosSim(1,1);
%     tfalla = datosSim(3,1);
%     dt = datosSim(4,1);
%     frec = datosSim(5,1);
%     if dt == 0
%         dt = 1/frec;
%     end
%     durFalla = datosSim(2,1)*dt;
% end
% 
% function [Graf] = insertarValorGraf(obj,Graf,t)
%     for i = 1:size(obj,2)-1
%         Graf(i).t(end+1) = t;
%         Graf(i).V(end+1) = obj(i).V;
%         Graf(i).A(end+1) = obj(i).A;
%         if Graf(i).Gen == 1
%             Graf(i).omg(end+1) = obj(i).omg;
%             Graf(i).del(end+1) = obj(i).del;
%             Graf(i).Pe(end+1) =  obj(i).Pe;
%         end
%     end
% end