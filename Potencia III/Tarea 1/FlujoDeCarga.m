function [F] = FlujoDeCarga(incog,obj)

    for i = 1:size(obj,2)
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
        end
    end
    
    barra.setgetData(obj);
    
    for i = 1:size(obj,2)
        F(2*i-1) = obj(i).deltaP();
        F(2*i) = obj(i).deltaQ();
    end
end

