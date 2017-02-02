%Qik.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%Con esta funcion se obtiene el flujo de potencia reactiva entre dos barras

function Q = Qik(i,k,Vi,Ai,Vk,Ak,G,B,BikShunt)
    Q = (-(Vi)^2)*(B(i,k)+BikShunt(i,k)) + ...
        (abs(Vi*Vk)*(B(i,k)*cos(Ai-Ak)-G(i,k)*sin(Ai-Ak)));
end