%Pik.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%Con esta funcion se obtiene el flujo de potencia activa entre dos barras

function P = Pik(i,k,Vi,Ai,Vk,Ak,G,B)
    P = G(i,k)*(Vi^2) - ...
       (abs(Vi*Vk)*(G(i,k)*cos(Ai-Ak)+B(i,k)*sin(Ai-Ak)));
end