classdef datosNariz
    properties
        ID
        P
        Q
        V
    end
    methods
        function obj = datosNariz(p,q,v)
            if nargin == 0    
            else
                obj.V = v;
                obj.Q = q;
                obj.P = p;
            end
        end
        
        function plotPV(obj)
            figure;
            plot(-obj.P,obj.V);
            xlabel('Potencia activa (pu)');
            ylabel('Voltaje (pu)');
            title(['Barra ', num2str(obj.ID),': Voltaje vs. Potencia activa']);
        end
        
        function plotQV(obj)
            figure;
            plot(-obj.Q,obj.V);
            xlabel('Potencia reactiva (pu)');
            ylabel('Voltaje (pu)');
            title(['Barra ', num2str(obj.ID),': Voltaje vs. Potencia reactiva']);
        end
    end
end