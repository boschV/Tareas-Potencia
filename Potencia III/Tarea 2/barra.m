classdef barra
    properties
        ID
        Gen
        Falla3f
        Aux
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
        Q
        E
        mE
        Ag
        del
        omg
        Zg
        Iny
        H
        K
        Pm
        Pe
    end
    methods (Static)
        function out = setgetW0(data)
            persistent W0;
            if nargin
                W0 = data;
            end
            out = W0;
        end
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
        
        
        function [obj,resultado, exitflag] = FCsolve()
            opts = optimoptions(@fsolve,'Display','off','MaxFunctionEvaluations',10000,'MaxIterations',10000);
            
            obj = barra.setgetData();

            ValIni = [];
            
            for i = 1:size(obj,2)
                if obj(i).Falla3f ~= 1
                    ValIni(end+1:end+2) = [0 0];
                    switch obj(i).Tipo
                        case 0
                            ValIni(2*i-1) = 1;
                            ValIni(2*i) = 1;
                        case 1
                            ValIni(2*i-1) = 0;
                            ValIni(2*i) = 1;
                        case 2
                            ValIni(2*i-1) = 1;
                            ValIni(2*i) = 0;
                        case 3
                    end
                end
            end   
            
            [resultado,~,exitflag,~] = fsolve(@(incog)FlujoDeCarga(incog, obj), ValIni,opts);
           if exitflag > 0 
            for i = 1:size(obj,2)
                if obj(i).Falla3f ~= 1
                    switch obj(i).Tipo
                        case 0
                            obj(i).P = resultado(2*i-1);
                            obj(i).Q = resultado(2*i);
                        case 1
                            obj(i).A = resultado(2*i-1);
                            obj(i).Q = resultado(2*i);
                        case 2
                            obj(i).V = resultado(2*i-1);
                            obj(i).A = resultado(2*i);
                        case 3
                    end
                end
            end
            barra.setgetData(obj);
           end
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
                obj.Falla3f = 0;
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
            
            dP = -obj.P + s;            
        end
        
        function dQ = deltaQ(obj)
            data = barra.setgetData();
            G = barra.setgetG();
            B = barra.setgetB();
            Bsh = barra.setgetBsh();
            
            s = 0;
            for i = 1:size(obj.Ady,2)
                s = s + Qik(obj.ID,obj.Ady(i),obj.V,obj.A,data(obj.Ady(i)).V,data(obj.Ady(i)).A,G,B);
            end
            dQ = -obj.Q + s;          
        end
        function Pe = Pelec(obj)
            G = real(1/obj.Zg);
            B = imag(1/obj.Zg);
            E = abs(obj.E);
            delta = angle(obj.E);
            V = obj.V;
            theta = obj.A;
            Pe = -G*(E^2) + ...
                ((E*V)*(G*cos(delta-theta)-B*sin(delta-theta)));
        end
        function [F] = Feq(obj,angv,wv,Pev,dt)
            angn = obj.del;
            w0 = barra.setgetW0();
            Pm = obj.Pm;
            Pen = obj.Pelec();
            K = obj.K;
            H = obj.H;
            wn = obj.omg;
            deltaP = @(Pm,Pe,K,W) Pm - Pe - K*W;
            F(1) = -wn + wv + dt*(0.5*(w0/(2*H))*(deltaP(Pm,Pev,K,wv) + deltaP(Pm,Pen,K,wn)));
            F(2) = -angn + angv + dt*0.5*(wn+wv);
        end
    end
end

function Q = Qik(i,k,Vi,Ai,Vk,Ak,G,B)
    Q = (-(Vi)^2)*(B(i,k)) + ...
        (abs(Vi*Vk)*(B(i,k)*cos(Ai-Ak)-G(i,k)*sin(Ai-Ak)));
end

function P = Pik(i,k,Vi,Ai,Vk,Ak,G,B)
    P = G(i,k)*(Vi^2) - ...
        (abs(Vi*Vk)*(G(i,k)*cos(Ai-Ak)+B(i,k)*sin(Ai-Ak)));
end

function [F] = FlujoDeCarga(incog,obj)

    for i = 1:size(obj,2)
        if obj(i).Falla3f ~= 1
            switch obj(i).Tipo
                case 0
                    obj(i).P = incog(2*i-1);
                    obj(i).Q = incog(2*i);
                case 1
                    obj(i).A = incog(2*i-1);
                    obj(i).Q = incog(2*i);
                case 2
                    obj(i).V = incog(2*i-1);
                    obj(i).A = incog(2*i);
                case 3
            end
        end
    end

    barra.setgetData(obj);
    
    for i = 1:size(obj,2)-1
        if obj(i).Falla3f ~= 1
            F(2*i-1) = obj(i).deltaP();
            F(2*i) = obj(i).deltaQ();
        end
    end
end