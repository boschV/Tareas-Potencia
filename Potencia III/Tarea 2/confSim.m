
function [tsim,durFalla,tfalla,dt,frec] = confSim(datosSim)

    tsim = datosSim(1,1);
    tfalla = datosSim(3,1);
    dt = datosSim(4,1);
    frec = datosSim(5,1);
    if dt == 0
        dt = 1/frec;
    end
    durFalla = datosSim(2,1)*dt;
end
