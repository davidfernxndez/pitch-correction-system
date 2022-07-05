% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function [fo,idx,x]=deteccion_pitch(x,Fs,FoMin,FoMax)
%
% INPUTS:
% x:  Señal de entrada
% Fs: Frecuencia de muestreo
% FoMin: Frecuencia mínima de pitch permitida
% FoMax: Frecuencia máxima de pitch permitida
%
% OUTPUTS:
% fo: Vector que contiene la frecuencia de pitch de cada trama en la que se
% ha segmentado la señal de entrada x.
% idx: Vector que contiene los indices de la última muestra de cada trama.
% x: Señal de audio de entrada con el padding de ceros.


tW=20e-3;                   % Duración trama en segundos
tO=10e-3;                   % Duración solapado en segundos
WinLength=round(tW*Fs);     % Duración trama en muestras
OverlapLength=round(tO*Fs); % Duración solapado en muestras

% Padding de ceros 
[x,~]=pad_ceros(x,WinLength);

% Detección del tipo de sonido
flag=detector_sonido(x,WinLength,OverlapLength);

% Cálculo del pitch
[fo,idx]=calcula_pitch(x,Fs,WinLength,OverlapLength,FoMin,FoMax,flag);
end
