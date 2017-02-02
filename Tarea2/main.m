%main.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%El programa tiene seis archivos: input.xlsx, main.m, CrearStrBar.m, Pik.m,
%Qik.m, y FlujoDeCarga.m.


clear
%Se define el archivo excel de entrada
filename = 'input.xlsx';

%Se extraen las dos tablas del archivo
[datosbarras] = xlsread(filename,1);
[datoslineas] = xlsread(filename,2);

%Se construye la Ybus, y una matriz de las susceptancias shunt de las
%lineas
[Ybus, BikShunt] = constYbus(datoslineas, datosbarras);

%Se crea una estructura con todos los datos de las barras
vbarra = CrearStrBar(datosbarras);

%Se definen las matrices de conductancia y susceptancia
G = real(-Ybus);
B = imag(-Ybus);

%Se define el vector de valores iniciales
ValIni = [1 1 0 1 1 0];

%Se resuelve el sistema utilizando fsolve
[resultado] = fsolve(@(incog)FlujoDeCarga(incog, G, B, BikShunt, vbarra), ValIni);

%Se escriben las variables en la estructura
vbarra(1).P = resultado(1);
vbarra(1).Q = resultado(2);

vbarra(2).A = resultado(3);
vbarra(2).Q = resultado(4);
vbarra(2).Vp = vbarra(2).V*exp(1j*vbarra(2).A);

vbarra(3).V = resultado(5);
vbarra(3).A = resultado(6);
vbarra(3).Vp = vbarra(3).V*exp(1j*vbarra(3).A);

 matVol = zeros(size(vbarra, 2),3);
 for i = 1 : size(vbarra, 2)
     matVol(i, :) = [i vbarra(i).V vbarra(i).A];
 end
 
%-------------Imprime los Voltajes---------------------
for i=1:size(datosbarras, 1)
    fprintf('\n Barra: %i, V= %5.4f ang %5.4f \n',i,matVol(i,2),matVol(i,3));
end

matP=[]; %Matriz de potencias activas ordenadas
matPperd = []; %matriz con las perdidas activas
matQ=[]; %Matriz de potencias reactivas ordenadas
matQperd = []; %matriz con las perdidas reactivas

%-------------Imprime los Flujos---------------------
for i = 1:size(datosbarras, 1)
    for k = 1:size(datosbarras, 1)
        if (i ~= k) && (i < k)
            P1 = Pik(i,k,vbarra(i).V,vbarra(i).A,vbarra(k).V,vbarra(k).A,G,B);
            P2 = Pik(k,i,vbarra(k).V,vbarra(k).A,vbarra(i).V,vbarra(i).A,G,B);
            Pperd = P1 + P2;

            matP(end+1,:) = [i k P1];
            matP(end+1,:) = [k i P2];
            matPperd(end+1,:) = [i k Pperd];
            
            fprintf('\n Flujo de Potencia activa de %i a %i: %5.7f pu \n', i, k, P1);
            fprintf('\n Flujo de Potencia activa de %i a %i: %5.7f pu \n', k, i, P2);
            fprintf('\n Perdidas de Potencia activa entre %i y %i: %5.7f pu \n', i, k, Pperd);

            Q1 = Qik(i,k,vbarra(i).V,vbarra(i).A,vbarra(k).V,vbarra(k).A,G,B, BikShunt);
            Q2 = Qik(k,i,vbarra(k).V,vbarra(k).A,vbarra(i).V,vbarra(i).A,G,B, BikShunt);
            Qperd = Q1 + Q2;

            matQ(end+1,:) = [i k Q1];
            matQ(end+1,:) = [k i Q2];
            matQperd(end+1,:) = [i k Qperd];
            
            fprintf('\n Flujo de Potencia reactiva de %i a %i: %5.7f pu \n', i, k, Q1);
            fprintf('\n Flujo de Potencia reactiva de %i a %i: %5.7f pu \n', k, i, Q2);
            fprintf('\n Perdidas de Potencia reactiva entre %i y %i: %5.7f pu \n', i, k, Qperd);
        
        elseif k == i
        	P1 = Pik(i,k,abs(vbarra(i).Vp),angle(vbarra(i).Vp),abs(vbarra(k).Vp),angle(vbarra(k).Vp),G,B);
        	if P1 ~= 0
         		fprintf('\n Potencia activa consumida por la carga shunt en %i: %5.7f pu \n', i, P1);
         	end
         	
         	Q1 = Qik(i,k,abs(vbarra(i).Vp),angle(vbarra(i).Vp),abs(vbarra(k).Vp),angle(vbarra(k).Vp),G,B, BikShunt);
         	if Q1 ~= 0
         		fprintf('\n Potencia reactiva consumida por la carga shunt en la barra %i: %5.7f pu \n', i, Q1);
         	end
        end
    end
end

Pperdtot = sum(matPperd(:,3));
Qperdtot = sum(matQperd(:,3));

fprintf('\n Las perdidas activas totales son: %5.7f pu \n', Pperdtot);
fprintf('\n Las perdidas reactivas totales son: %5.7f pu \n', Qperdtot);

for i = 1:size(datosbarras, 1)
    if vbarra(i).ID == 0
        fprintf('\n Potencia activa entregada por la barra slack: %5.7f pu\n', vbarra(i).P);
        fprintf('\n Potencia reactiva entregada por la barra slack: %5.7f pu\n', vbarra(i).Q);
    elseif vbarra(i).ID == 1
        fprintf('\n Potencia reactiva entregada por la barra %i (PV): %5.7f pu\n', i, vbarra(i).Q);
    end
end

 %-------------------------------COMENTARIO-------------------------------
 % Las matrices matVol, matP, matPperd, matQ, matQperd pueden ser
 % utilizadas para escribir la respuesta en un archivo de excel pero para
 % poder usar esa funcion hace falta tener excel, pero no lo tengo asi que
 % no la puedo implementar
 