syms b y x t alfa w delta Irms B real

a = 2*pi/3;
b = w*t + delta + pi/2;
y = w*t + alfa;

%% Modulos de Id, Iq
absId = sqrt((cos(x))^2+(cos(x-a))^2+(cos(x+a))^2); %resultado: sqrt(3/2)
absIq = sqrt((sin(x))^2+(sin(x-a))^2+(sin(x+a))^2); %resultado: sqrt(3/2)

%% calculo id
expr3 = cos(b-a)*cos(y-a);
expr4 = cos(b+a)*cos(y+a);
expr5 = cos(b)*cos(y);
% pretty(expand(expr3));
% pretty(expand(expr4));
% pretty(expr5 + expand(expr4+expr3));
% pretty(simplify(expr5 + expand(expr4+expr3)));
id(Irms, delta, alfa) = (2/sqrt(3))*Irms*simplify(expr5 + expand(expr4+expr3));

%% calculo iq
expr6 = sin(b-a)*cos(y-a);
expr7 = sin(b+a)*cos(y+a);
expr8 = sin(b)*cos(y);

% pretty(expand(expr6));
% pretty(expand(expr7));
% pretty(expr8 + expand(expr7+expr6));
% pretty(simplify(expr8 + expand(expr7+expr6)));

iq(Irms, delta, alfa) = (2/sqrt(3))*Irms*simplify(expr8 + expand(expr7+expr6));

% pretty(id);
% pretty(iq);

iqEv = @(Irms, delta, alfa) eval(iq(Irms, delta, alfa));
idEv = @(Irms, delta, alfa) eval(id(Irms, delta, alfa));

%% De forma Matricial
Tpinv = sqrt(2/3)*[  cos(b)   cos(b-a)  cos(b+a);
                     sin(b)   sin(b-a)  sin(b+a);
                   1/sqrt(2) 1/sqrt(2) 1/sqrt(2)];
              
Iabc = [sqrt(2)*Irms*cos(w*t + alfa);
        sqrt(2)*Irms*cos(w*t + alfa - a);
        sqrt(2)*Irms*cos(w*t + alfa + a)];
                   
Idqo = simplify(Tpinv*Iabc);

Tp = Tpinv';

Iabc1(Irms, delta, alfa) = simplify(Tp*Idqo);

%% Para un Irms,delta, alfa especifico
IrmsE = 1;
deltaE = 0.234;
alfaE = 0;
w = 377;
t = 0.234;

disp('Iq')
iqEv(IrmsE, deltaE, alfaE)
disp('Id')
idEv(IrmsE, deltaE, alfaE)

%% Para un Irms,delta, alfa, omega, tiempo especifico
IrmsE = 1;
deltaE = 0.234;
alfaE = 0;
w = 377;
t = 0.234;

IabcEv = @(Irms, delta, alfa,w,t) eval(Iabc1(Irms, delta, alfa));
IabcEv(IrmsE, deltaE, alfaE,w,t)