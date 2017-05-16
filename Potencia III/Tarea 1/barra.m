classdef barra
    properties
        ID
        Ady
        Tipo
        V
        A
        Z
        Pg
        Qg
        Pc
        Qc
        P
        Pini
        Q
        Qini
    end
    methods (Static)
        function out = setgetB(data)
            persistent B;
            if nargin
                B = data;
            end
            out = B;
        end
        function out = setgetG(data)
            persistent G;
            if nargin
                G = data;
            end
            out = G;
        end
        function out = setgetBsh(data)
            persistent Bsh;
            if nargin
                Bsh = data;
            end
            out = Bsh;
        end  
        function out = setgetData(data)
            persistent Data;
            if nargin
                Data = data;
            end
            out = Data;
        end  
        
        function out = setgetYbus(data)
            persistent Ybus;
            if nargin
                Ybus = data;
            end
            out = Ybus;
        end  
    end
    methods
        function obj = barra(id, tipo, ady, v, a, z, pg, qg, pc, qc)
            if nargin == 0
                
            else
                obj.ID = id;
                obj.Tipo = tipo;
                obj.Ady = ady;
                obj.V = v;
                obj.A = a;
                obj.Z = z;
                obj.Pg = pg;
                obj.Qg = qg;
                obj.Pc = pc;
                obj.Qc = qc;
                obj.P = pg - pc;
                obj.Q = qg - qc;
                obj.Pini = pg - pc;
                obj.Qini = qg - qc;
            end
        end
        
        function dP = deltaP(obj)
            data = barra.setgetData();
            G = barra.setgetG();
            B = barra.setgetB(); 
            
            s = 0;
            for i = 1:size(obj.Ady,2)
                s = s + Pik(obj.ID,obj.Ady(i),obj.V,obj.A ,data(obj.Ady(i)).V,data(obj.Ady(i)).A,G,B);
            end
            
            dP = -obj.P + s + Pii(obj.V,obj.Z);
            
        end
        
        function dQ = deltaQ(obj)
            data = barra.setgetData();
            G = barra.setgetG();
            B = barra.setgetB();
            Bsh = barra.setgetBsh();
            
            s = 0;
            for i = 1:size(obj.Ady,2)
                s = s + Qik(obj.ID,obj.Ady(i),obj.V,obj.A,data(obj.Ady(i)).V,data(obj.Ady(i)).A,G,B,Bsh);
            end
            dQ = -obj.Q + s + Qii(obj.V,obj.Z);
           
        end
    end
end

function Q = Qik(i,k,Vi,Ai,Vk,Ak,G,B,BikShunt)
    Q = (-(Vi)^2)*(B(i,k)+BikShunt(i,k)) + ...
        (abs(Vi*Vk)*(B(i,k)*cos(Ai-Ak)-G(i,k)*sin(Ai-Ak)));
end

function P = Pik(i,k,Vi,Ai,Vk,Ak,G,B)
    P = G(i,k)*(Vi^2) - ...
        (abs(Vi*Vk)*(G(i,k)*cos(Ai-Ak)+B(i,k)*sin(Ai-Ak)));
end

function P = Pii(V,Z)
    if Z ~= 0
        P = real((V^2)/(conj(Z)));
    else
        P = 0;
    end
end

function Q = Qii(V,Z)
    if Z ~= 0
        Q = imag((V^2)/(conj(Z)));
    else
        Q = 0;
    end
end