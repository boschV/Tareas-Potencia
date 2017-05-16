%% primer caso
syms Xl Rl Rc Xc Vc Ic Pc ang fp real
syms f
assumeAlso(Xl > 0);
assumeAlso(Rl > 0);
assumeAlso(Rc > 0);
assumeAlso(Xc > 0);
assumeAlso(Vc > 0);
Ic = 1/(Rc + 1j*Xl);
Vc = Ic * (Rc);
%Pc = Vc^2/conj(Rc + 1j*Xc);
Pc = Vc*conj(Ic);
dPc = factor(diff(Pc,Rc));
res = solve(dPc(2) == 0, Rc);
pretty(res);

%% factor de Potencia constante
syms Xl Rl Rc Xc Vc Ic Pc ang fp real
assumeAlso(Xl > 0);
assumeAlso(Rl > 0);
assumeAlso(Rc > 0);
assumeAlso(Xc > 0);
assumeAlso(Vc > 0);
%Xc = Rc*tan(acos(fp));
Xc = Rc*tan(ang);
Ic = 1/(Rl + Rc + 1j*Xl + 1j*Xc);
Vc = Ic * (Rc + 1j*Xc);
%Pc = Vc^2/conj(Rc + 1j*Xc);
Pc = Vc*conj(Ic);
dPc = factor(diff(Pc,Rc));
res = solve(dPc(3) == 0, Rc);
pretty(res);

%% Xc constante
syms Xl Rl Rc Xc Vc Ic Pc ang fp real
assumeAlso(Xl > 0);
assumeAlso(Rl > 0);
assumeAlso(Rc > 0);
assumeAlso(Xc > 0);
assumeAlso(Vc > 0);
Ic = 1/(Rl + Rc + 1j*Xl + 1j*Xc);
Vc = Ic * (Rc + 1j*Xc);
Pc = Vc^2/conj(Rc + 1j*Xc);
%Pc = Vc*conj(Ic);
dPc = factor(diff(Pc,Rc));
res = solve(dPc(3) == 0,Rc);
pretty(res);

%% Rc constante
syms Xl Rl Rc Xc Vc Ic Pc ang fp real
assumeAlso(Xl > 0);
assumeAlso(Rl > 0);
assumeAlso(Rc > 0);
assumeAlso(Xc > 0);
assumeAlso(Vc > 0);
Ic = 1/(Rl + Rc + 1j*Xl + 1j*Xc);
Vc = Ic * (Rc + 1j*Xc);
Pc = Vc^2/conj(Rc + 1j*Xc);
%Pc = Vc*conj(Ic);
dPc = factor(diff(Pc,Xc));
res = solve(dPc(3) == 0,Xc);
pretty(res);