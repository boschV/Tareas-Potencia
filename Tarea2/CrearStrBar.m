%CrearStrbar.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%Esta función tiene como objetivo crear una estructura que contenga toda la
%información pertinente a las barras del sistema
%

function vbarra = CrearStrBar(datosbarras)

N_barras = size(datosbarras, 1);

%cell que se usa para inicializar las variables del struct
iniV = cell([1 N_barras]);

%Se hace una estructura para guardar toda la informacion necesaria para cada
%barra

%Codigo Voltaje Angulo VoltajePolar P Q S Pgen Qgen Pcar Qcar
vbarra = struct('ID',iniV,'V',iniV,'A',iniV,'Vp',iniV,'P',iniV,'Q',iniV,'S',iniV, ...
    'Pgen', iniV, 'Qgen',iniV,'Pcar',iniV,'Qcar',iniV);

%Codigos: 0->Slack, 1->PV, 2->PQ

%Se rellena la estructura
for i = 1:N_barras
    vbarra(datosbarras(i,1)).ID = datosbarras(i,2);
    vbarra(datosbarras(i,1)).V = datosbarras(i,3);
    vbarra(datosbarras(i,1)).A = datosbarras(i,4);
    vbarra(datosbarras(i,1)).Vp = vbarra(datosbarras(i,1)).V*exp(1j*vbarra(datosbarras(i,1)).A);
    
    vbarra(datosbarras(i,1)).Pgen = datosbarras(i,5);
    vbarra(datosbarras(i,1)).Pcar = datosbarras(i,7);
    vbarra(datosbarras(i,1)).P = datosbarras(i,5)-datosbarras(i,7);
    
    vbarra(datosbarras(i,1)).Qgen = datosbarras(i,6);
    vbarra(datosbarras(i,1)).Qcar = datosbarras(i,8);
    vbarra(datosbarras(i,1)).Q = datosbarras(i,6)-datosbarras(i,8);
    
    vbarra(datosbarras(i,1)).S = vbarra(datosbarras(i,1)).P +1j* vbarra(datosbarras(i,1)).Q;
    
end

%Se inicializan los distintos campos segun el tipo de barra (Slack,PV,PQ)
for i = 1:N_barras
    if vbarra(i).ID == 0
        vbarra(i).P = 0;
        vbarra(i).Q = 0;
        vbarra(i).S = 0;

    elseif vbarra(i).ID == 1
        vbarra(i).Q = [];
        vbarra(i).S = [];
        vbarra(i).A = 0;
        vbarra(i).Vp = vbarra(i).V*exp(1j*vbarra(i).A);

    elseif vbarra(i).ID == 2
        vbarra(i).V = 1;
        vbarra(i).A = 0;
        vbarra(i).Vp = vbarra(i).V*exp(1j*vbarra(i).A);

    end
end

end
