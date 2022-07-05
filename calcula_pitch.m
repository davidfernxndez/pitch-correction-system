% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function [fo,idx]=calcula_pitch(x,Fs,WinLength,OverlapLength,FoMin,FoMax,flag)
%
% INPUTS:
% x: Señal de entrada
% Fs: Frecuencia de muestreo
% WinLength: Duración de la trama en muestras
% OverlapLength: Duración del solapado en muestras
% FoMin: Frecuencia mínima permitida
% FoMax: Frecuencia máxima permitida
% flag: Vector que contiene 0 si el sonido es silencioso, 2 si el sonido es
% sordo y 1 si el sonido es sonoro

% OUTPUTS:
% fo: Vector que contiene la frecuencia de pitch de cada trama en la que se
% ha segmentado la señal de entrada x.
% idx: Vector que contiene los indices de la última muestra de cada trama.

%% Cálculo del número de tramas
n=length(x);
ntramas=(n/WinLength)*(WinLength/OverlapLength)-1;

fo=zeros(ntramas,1);
idx=zeros(ntramas,1);

%% Método de autocorrelación
for i =1:ntramas
    trama=x(1+(i-1)*OverlapLength:(i-1)*OverlapLength+WinLength);
    idx(i)=(i-1)*OverlapLength+WinLength;
    if flag(i)==1 || flag(i)==2 
       
       [fo(i),flag(i),v_fo_posibles]=corr_method(trama,Fs,FoMin,FoMax,flag(i));      
       fo_posibles(i)=struct('fo_posibles',v_fo_posibles);
 
    else
        fo(i)=nan;
    end
end

%% Primera corrección
[fo,flag]=primera_correccion(fo,fo_posibles,flag);

%% Segunda corrección
fo=segunda_correccion(fo,fo_posibles,flag);
end