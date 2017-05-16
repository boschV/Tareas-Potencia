close all
clear

opts = optimoptions(@fsolve,'Display','off');
filename = 'input9b.xlsx';
[datosbarras] = xlsread(filename,1);
[datoslineas] = xlsread(filename,2);

obj = crearVecBar(datosbarras,datoslineas);


ValIni = zeros(1,2*size(obj,2));

Pstep = 0.05;
npq = 0;
%Calcula las narices para las barras PQ que tienen carga conectadas
for i = 1:size(obj,2)
    if (obj(i).Tipo == 2) && (obj(i).P ~= 0) && (obj(i).Q ~= 0)
        npq = npq + 1;
        dNariz(npq) = datosNariz();
        dNariz(npq).ID = obj(i).ID;
        
        for j = 1:size(obj,2)
            switch obj(j).Tipo
                case 0
                    ValIni(2*j-1) = 1;
                    ValIni(2*j) = 1;
                case 1
                    ValIni(2*j-1) = 0;
                    ValIni(2*j) = 1;
                case 2
                    ValIni(2*j-1) = 1;
                    ValIni(2*j) = 0;  
            end
        end
        
        ang = atan(obj(i).Q/obj(i).P);   
        if isnan(ang)
            ang = atan(1);
        end
        exitflag = 1;
        
        while exitflag > 0

            [resultado,fval,exitflag,output] = fsolve(@(incog)FlujoDeCarga(incog, obj), ValIni,opts);

            dNariz(npq).V(end+1) = resultado(2*i-1);
            dNariz(npq).P(end+1) = obj(i).P;
            dNariz(npq).Q(end+1) = obj(i).Q;   
            
            obj(i).P = obj(i).P - Pstep;
            obj(i).Q = obj(i).P*tan(ang);
            barra.setgetData(obj);
            
            ValIni = resultado;
        end
        
            obj(i).P = obj(i).Pini;
            obj(i).Q = obj(i).Qini;
            barra.setgetData(obj);
    end
end

for i = 1:size(dNariz,2)
    dNariz(i).plotPV();
    dNariz(i).plotQV();
end

