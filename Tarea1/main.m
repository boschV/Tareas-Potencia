%main.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%Programa para la resolucion del flujo de carga utilizando el metodo de Gauss-Seidel
%
%Este programa consiste de 8 archivos distintos que tienen que estar dentro
%de la misma carpeta para que corra correctamente. Los archivos son:
%main.m, Input.m, GaussSiter.m ,Flujos_De_Potencia.m, Vpq.m, Qpv.m, Pik.m, Qik.m
%
%El ingreso de los datos se hace en el archivo Input.m
%
%--------------------------------------------------------------------------

clear

Input

GaussSiter

Flujos_De_Potencia

%----------------------------Resultados------------------------------------
%

%Cuando la barra 2 entrega 0.9 pu de potencia activa
%
%Voltajes:
%   Barra: 1, V= 1.0000 ang 0.0000 
% 
%   Barra: 2, V= 1.0100 ang -0.0024 
% 
%   Barra: 3, V= 0.9896 ang -0.0942 
% 
%Flujos de P:
% 
% Flujo de P de 1 a 2: 0.00938 pu 
%  
% Flujo de P de 2 a 1: -0.00935 pu 
%  
% Flujo de P de 1 a 3: 0.62267 pu 
%  
% Flujo de P de 3 a 1: -0.61491 pu 
%  
% Flujo de P de 2 a 3: 0.90943 pu 
%  
% Flujo de P de 3 a 2: -0.88509 pu
%
%Flujos de Q:
%
% Flujo de Q de 1 a 2: -0.10045 pu
%  
% Flujo de Q de 2 a 1: -0.00002 pu
%  
% Flujo de Q de 1 a 3: -0.08412 pu
%  
% Flujo de Q de 3 a 1: -0.05561 pu
%  
% Flujo de Q de 2 a 3: -0.17719 pu
%  
% Flujo de Q de 3 a 2: -0.04157 pu
%
%Perdidas de P:
% 
% Perdidas de P entre 1 y 2: 0.00003 pu 
%  
% Perdidas de P entre 1 y 3: 0.00776 pu 
%  
% Perdidas de P entre 2 y 3: 0.02434 pu 
%
% Perdidas de Potencia activa total : 0.03213 pu
%
%Perdidas de Q:
%
% Perdidas de Q entre 1 y 2: -0.10048 pu 
%  
% Perdidas de Q entre 1 y 3: -0.13973 pu 
%  
% Perdidas de Q entre 2 y 3: -0.21876 pu 
%
% Perdidas de Potencia reactiva total : -0.45897 pu 
%
%Potencia reactiva consumida por el capacitor: -0.65281 pu (entrega Q)
%
%Potencia entregada por la barra slack:
% Barra=1 Pgen= 0.63205 pu Qgen= -0.18457 pu
%
%Potencia entregada por la barra PV: 
% Barra=2 Pgen= 0.90000 pu Qgen= -0.17724 pu 
%

%Cuando la barra 2 consume 0.2 pu de potencia activa:
%
%Voltajes:
%  
%  Barra: 1, V= 1.0000 ang 0.0000 
% 
%  Barra: 2, V= 1.0100 ang -0.1260 
% 
%  Barra: 3, V= 0.9928 ang -0.1672 
% 
% Flujos de P:
% 
% Flujo de P de 1 a 2: 0.63279 pu 
%  
% Flujo de P de 2 a 1: -0.62876 pu 
%  
% Flujo de P de 1 a 3: 1.10088 pu 
%  
% Flujo de P de 3 a 1: -1.07664 pu 
%  
% Flujo de P de 2 a 3: 0.42885 pu 
%  
% Flujo de P de 3 a 2: -0.42336 pu 
%  
% Flujos de Q:
% 
% Flujo de Q de 1 a 2: -0.09157 pu
%  
% Flujo de Q de 2 a 1: 0.07100 pu
%  
% Flujo de Q de 1 a 3: -0.10669 pu
%  
% Flujo de Q de 3 a 1: 0.08991 pu
%  
% Flujo de Q de 2 a 3: -0.09982 pu
%  
% Flujo de Q de 3 a 2: -0.18275 pu
% 
% Perdidas de P:
% 
% Perdidas de P entre 1 y 2: 0.00402 pu 
%  
% Perdidas de P entre 1 y 3: 0.02424 pu 
%  
% Perdidas de P entre 2 y 3: 0.00549 pu 
%  
% Perdidas de Potencia activa total : 0.03375 pu 
%  
% Perdidas de Q:
% 
% Perdidas de Q entre 1 y 2: -0.02058 pu 
%  
% Perdidas de Q entre 1 y 3: -0.01677 pu 
%  
% Perdidas de Q entre 2 y 3: -0.28257 pu 
% 
% Perdidas de Potencia reactiva total : -0.31992 pu 
% 
%  Potencia rectiva consumida por el capacitor: -0.65715 pu (entrega Q)
% 
% Potencia entregada por la barra slack:
% Barra=1 Pgen= 1.73367 pu Qgen= -0.19826 pu
% 
% Potencia entregada por la barra PV:
% Barra=2 Pgen= -0.20000 pu Qgen= -0.02886 pu 