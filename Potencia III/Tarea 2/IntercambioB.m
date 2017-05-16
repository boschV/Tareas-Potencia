function [YbusK] = IntercambioB(YbusK,Inter1,Inter2)
    Aux1H = YbusK(Inter1,:);
    Aux1 = Aux1H(Inter1);
    Aux1H(Inter1) = Aux1H(Inter2);
    Aux1H(Inter2) = Aux1;

    Aux1V = YbusK(:,Inter1);
    Aux1 = Aux1V(Inter1);
    Aux1V(Inter1) = Aux1V(Inter2);
    Aux1V(Inter2) = Aux1;

    Aux2H = YbusK(Inter2,:);
    Aux1 = Aux2H(Inter1);
    Aux2H(Inter1) = Aux2H(Inter2);
    Aux2H(Inter2) = Aux1;

    Aux2V = YbusK(:,Inter2);
    Aux1 = Aux2V(Inter1);
    Aux2V(Inter1) = Aux2V(Inter2);
    Aux2V(Inter2) = Aux1;

    YbusK(Inter1,:) = Aux2H;
    YbusK(:,Inter1) = Aux2V;

    YbusK(Inter2,:) = Aux1H;
    YbusK(:,Inter2) = Aux1V;
end
