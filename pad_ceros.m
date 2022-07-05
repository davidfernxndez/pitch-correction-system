% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.


function [x,contador]=pad_ceros(x,n)
%
% INPUTS:
% x: Señal de entrada.
% n: duración de la trama en muestras.
% 
% OUTPUTS:
% x: Señal de entrada con padding de ceros.
% contador: número de ceros añadido.

contador=0;

% Se añade un cero al final de la señal hasta que sea divisible por el
% tamaño de la trama

while mod(length(x),n)~=0
    x(length(x)+1)=0;
    contador=contador+1;
    
end


end