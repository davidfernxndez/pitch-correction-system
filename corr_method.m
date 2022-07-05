% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function [fo,flag,fo_posibles]=corr_method(x,Fs,FoMin,FoMax,flag)
%
% INPUTS:
% x: Trama de la señal de audio
% Fs: Frecuencia de muestreo
% FoMin: Frecuencia mínima de pitch permitida
% FoMax: Frecuencia máxima de pitch permitida
% flag: Valor de flag de la trama, 2 si se considera sonido sordo y 1 si se
% considera sonido sonoro.
%
% OUTPUTS:
% fo: Frecuencia de pitch
% flag: Valor flag de entrada corregido
% fo_posibles: Vector con las frecuencias de pitch asociadas al resto de
% máximos localizados en la función de autocorrelación.


%% PASO 2: Cálculo de la función de autocorrelación

% En primer lugar se calcula la autocorrelación

r=xcorr(x,x);

% Se trabaja con la mitad de la autocorrelación al ser simétrica
r=r(round(length(r)/2):length(r));

% Se aplica suavizado para favorecer la búsqueda del máximo y se normaliza

r=smooth(r);
r=r/max(r);

%% PASO 3: Selección de todos los máximos locales

[pks,locs]=findpeaks(r);
n=1;

%% PASO 4: Se establece un rango de frecuencias de pitch posible.

lim_inf=round(Fs/FoMax);
lim_sup=round(Fs/FoMin);


%% PASO 5: Selección del máximo local

% Se eliminan los picos que esten fuera  del rango permitido

encontrado=0;
for i=1:length(pks)
    if pks(i)~=1 && pks(i)>0.25 && locs(i)<lim_sup && locs(i)>lim_inf
        pks_def(n)=pks(i);
        locs_def(n)=locs(i);
        n=n+1;
        encontrado=1;
    end
end

if encontrado
    [max_global,pos_max_global]=max(pks_def);
    
    %% PASO 6: Comprobación trama sorda
    
    if max_global<0.5 && flag==2
        
        % SONIDO SORDO
        fo=nan;
        flag=0;
        fo_posibles=0;
    else
        
        % SONIDO SONORO
        fo=Fs/(locs_def(pos_max_global)-1);
        
        %% PASO 7: Posibilidad de confusión con armónicos.
        
        % Se almacenan las frecuencias de pitch asociadas al resto de
        % máximos dentro del rango permitido.
        fo_posibles=Fs./(locs_def-1);
    end
        
else
    flag=0;
    fo=nan;
    fo_posibles=0;

end

end