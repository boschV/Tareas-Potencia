
function [obj]= confGen(dGen,obj)
    for i = 1:size(obj,2)
        for j = 1:size(dGen,1)
            if i == dGen(j,1)
                obj(i).Gen = 1;
                obj(i).Zg = dGen(j,2)+1j*dGen(j,3);
                obj(i).H = dGen(j,4);
                obj(i).K = dGen(j,5);
                obj(i).omg = 0;
            end
        end
    end
end
