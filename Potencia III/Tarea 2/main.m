clear
close all


opts = optimoptions(@fsolve,'Display','off','MaxFunctionEvaluations',10000,'MaxIterations',10000);
filename = 'input.xlsx';

%Lee los distintos datos del archivo de entrada
[datosbarras] = xlsread(filename,1);
[datoslineas] = xlsread(filename,2);
[datosGen] = xlsread(filename,3);
[datosFalla] = xlsread(filename,4);
[datosSim] = xlsread(filename,5);

%Crea un vector de objetos con toda la informacion de las barras
[obj,BikShunt] = crearVecBar(datosbarras, datoslineas);

%Le agrega la informacion de los generadores a la barras correnspondientes
obj = confGen(datosGen,obj);

%Se obtiene la Ybus del sistema
Ybus1 = barra.setgetYbus();
Ybus = Ybus1(1:3,1:3);

barra.setgetData(obj);

%Se realiza el flujo de carga
[obj,res,ef]=barra.FCsolve();

%Se calcula el numero de generadores y se inicializa el vector de
%graficacion
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

%Se modelan las barras PQ como impedancia constante, y se suma a la Ybus
%junto con las impedancias de los generadores
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

%Se obtienen los datos para la simulacion
[tsim,durFalla,tfalla,dt,frec] = confSim(datosSim);

%Se configura la frecuencia del circuito a la establecida en el input
barra.setgetW0(2*pi*frec);

%Se obtienen los datos de las fallas
[TipoDeFalla,barra1,barra2,Zsecn,Zsec0] = confFalla(datosFalla);

%Segun el tipo de falla se genera una Ybus de falla
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


%Se crea el vector de valores iniciales para el fsolve
ValIni = [];
Pev = [];
for i = 1:size(obj,2)-1
    if obj(i).Gen == 1
        ValIni(end+1) = 0;
        ValIni(end+1) = obj(i).Ag;
        Pev(end+1) = obj(i).Pm; 
    end
end

%Segun el tamano de la Ybus de falla se cambia este modificador para que el
%vector de corrientes inyectadas tenga la magnitud apropiada

switch TipoDeFalla
    case 1
        modI = TipoDeFalla;
    case {5, 6}
        modI = -1;
    otherwise
        modI = 0;
end

%loop de simulacion
for t = 0:dt:tsim
%A partir del tiempo de falla los angulos y velocidades varian segun el
%fsolve, se capturan los valores para las graficas y se toman como entrada
%para el proximo ciclo del fsolve, despues de la falla el sistema vuelve a
%su estado original
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

%Se realizan las graficas necesarias
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

