% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function y=pitchShift(x,Fs,fo,idx,beta)
%
% INPUTS:
% x: Señal de entrada
% Fs: Frecuencia de muestreo
% fo: Vector que contiene la frecuencia de pitch de cada trama en la que se
% ha segmentado la señal de entrada x.
% idx: Vector de indices que contiene la última muestra de cada trama en la
% que se ha segmentado la señal de entrada x.
% beta:  Vector que contiene los factores de pitch shifting de cada trama
% en la que se ha segmentado la señal de entrada x.
%
% OUTPUTS:
% y: Señal de salida

% DEFINICIÓN DE PARÁMETROS

tW=20e-3;  % Duración trama en segundos
tO=10e-3;  % Duración solapado en segundos


WinLength=round(tW*Fs);     % Duración trama en muestras
OverlapLength=round(tO*Fs); % Duración solapado en muestras


m=PitchMarks(x,Fs,fo,WinLength,OverlapLength);
y=psola(x,Fs,fo,m,idx,beta);
end
