%FlujoDeCarga.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%En esta función se define el conjunto de ecuaciones de flujo de potencia
%activa y reactiva que fsolve va a utilizar para resolver el sistema


function [F] = FlujoDeCarga(incog, G, B, BikShunt, vbarra)
    Ps = incog(1);
    Qs = incog(2);
    A2 = incog(3);
    Q2 = incog(4);
    V3 = incog(5);
    A3 = incog(6);
    
    F(1)= -Ps + Pik(1,2,vbarra(1).V,vbarra(1).A,vbarra(2).V,A2,G,B) + ...
          Pik(1,3,vbarra(1).V,vbarra(1).A,V3,A3,G,B);
    F(2)= -Qs + ...
          Qik(1,2,vbarra(1).V,vbarra(1).A,vbarra(2).V,A2,G,B,BikShunt) + ...
          Qik(1,3,vbarra(1).V,vbarra(1).A,V3,A3,G,B,BikShunt);
    
    F(3)= -vbarra(2).P + Pik(2,1,vbarra(2).V,A2,vbarra(1).V,vbarra(1).A,G,B) + ... 
          Pik(2,3,vbarra(2).V,A2,V3,A3,G,B);
    F(4)= -Q2 + Qik(2,1,vbarra(2).V,A2,vbarra(1).V,vbarra(1).A,G,B,BikShunt) + ...
          Qik(2,3,vbarra(2).V,A2,V3,A3,G,B,BikShunt);
    
    F(5)= -vbarra(3).P + Pik(3,1,V3,A3,vbarra(1).V,vbarra(1).A,G,B) + ...
        Pik(3,2,V3,A3,vbarra(2).V,A2,G,B);
    F(6)= -vbarra(3).Q + ...
        Qik(3,1,V3,A3,vbarra(1).V,vbarra(1).A,G,B,BikShunt) + ...
        Qik(3,2,V3,A3,vbarra(2).V,A2,G,B,BikShunt) + ...
        Qik(3,3,V3,A3,V3,A3,G,B,BikShunt);
end