
function [Graf] = insertarValorGraf(obj,Graf,t)
    for i = 1:size(obj,2)-1
        Graf(i).t(end+1) = t;
        Graf(i).V(end+1) = obj(i).V;
        Graf(i).A(end+1) = obj(i).A;
        if Graf(i).Gen == 1
            Graf(i).omg(end+1) = obj(i).omg;
            Graf(i).del(end+1) = obj(i).del;
            Graf(i).Pe(end+1) =  obj(i).Pe;
        end
    end
end