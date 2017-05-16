%vainas que graficar
%omg
%del
%Pe
%Voltajes
classdef dGraf
    properties
        Gen
        ID
        t
        omg
        del
        Pe
        V
        A
    end
    methods
        function obj = dGraf(gen,t,omg,del,pe,v,a)
            if nargin == 0    
            else
                obj.Gen = gen;
                obj.t = t;
                obj.omg = omg;
                obj.del = del;
                obj.Pe = pe;
                obj.V = v;
                obj.A = a;
            end
        end
        
        function plotOmg(obj)
            figure;
            plot(obj.t,obj.omg);
            xlabel('Tiempo (s)');
            ylabel('Velocidad relativa');
            title(['Barra ', num2str(obj.ID),': Tiempo vs. Velocidad relativa']);
        end
        
        function plotOmgG(obj)
            plot(obj.t,obj.omg,'DisplayName',['Generador Barra: ', num2str(obj.ID)]);
        end
        
        function plotDel(obj)
            figure;
            plot(obj.t,obj.del);
            xlabel('Tiempo (s)');
            ylabel('Angulo del Generador (rad)');
            title(['Barra ', num2str(obj.ID),': Tiempo vs. Angulo del generador']);
        end
        
        function plotDelG(obj)
            plot(obj.t,obj.del,'DisplayName',['Generador Barra: ', num2str(obj.ID)]);
        end      
        
        function plotPe(obj)
            figure;
            plot(obj.t,obj.Pe);
            xlabel('Tiempo (s)');
            ylabel('Potencia electrica (pu)');
            title(['Barra ', num2str(obj.ID),': Tiempo vs. Potencia electrica']);
        end
        
        function plotV(obj)
            figure;
            plot(obj.t,obj.V);
            xlabel('Tiempo (s)');
            ylabel('Voltaje (pu)');
            title(['Barra ', num2str(obj.ID),': Tiempo vs. Voltaje']);
        end
        
        function plotA(obj)
            figure;
            plot(obj.t,obj.A);
            xlabel('Tiempo (s)');
            ylabel('Angulo (rad)');
            title(['Barra ', num2str(obj.ID),': Tiempo vs. Angulo']);
        end
        
        function plotTodo(obj)
            if obj.Gen == 1
                plotOmg(obj);
                plotDel(obj);
                plotPe(obj);
            end
            plotV(obj);
            plotA(obj);
        end
    end
end