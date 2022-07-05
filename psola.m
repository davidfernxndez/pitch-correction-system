% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function y=psola(x,Fs,fo,m,idx,beta_in)
%
% INPUTS:
% x: Señal de entrada
% Fs: Frecuencia de muestreo
% fo: Vector que contiene la frecuencia de pitch de cada trama en la que se
% ha segmentado la señal de entrada x.
% m: Vector de pitch marks
% idx: Vector de indices que contiene la última muestra de cada trama en la
% que se ha segmentado la señal de entrada x.
% beta_in: Vector que contiene los factores de pitch shifting de cada trama
% en la que se ha segmentado la señal de entrada x.
%
% OUTPUTS:
% y: Señal de salida


% Se asigna el periodo de pitch y el factor de pitch shifting beta asociado
% a cada pitch mark

[Po,beta]=periodo_y_factor(m,idx,fo,Fs,beta_in);

% Comprobación de errores en primera pitch mark
while m(1)<=Po(1)      
    m=m(2:length(m));
    Po=Po(2:length(Po));
end

% Comprobación de errores en última pitch mark

while m(length(m))+Po(length(Po))>length(x) 
    m=m(1:length(m)-1);
    Po=Po(1:length(Po)-1);
end


Lout=length(x);  % Tamaño señal de salida
y=zeros(1,Lout); % Señal de salida
tk = Po(1)+1;     % Marca de tiempo

while round(tk)<Lout
    
    %% Selección del segmento de análisis
    
    [~,pos]=min(abs(m-tk) );
    
    % Periodo de pitch de análisis (Pa)
    Pa=Po(pos);
    
    % Periodo de pitch de síntesis (Ps)
    Ps=floor(Pa/beta(pos));
    
    % Extracción del segmento de análisis mediante una ventana de hanning
    % centrada en la pitch mark de análisis
    
    segmento_A=x(m(pos)-Pa:m(pos)+Pa).*hanning(2*Pa+1);
    
    %% Obtención del segmento de síntesis
    
    segmento_S=interp1(-Pa:1:Pa,segmento_A,-Ps*beta(pos):beta(pos):Pa);    

    % Posiciones en las que se coloca el segmento de sintesis
    iniS=round(tk)-Ps;
    finS=round(tk)+Ps;
    
    % Corrección de la posición en caso de errores 
    
    if iniS<=0
        iniS=1;
        finS=length(segmento_S);
    elseif length(segmento_S)~=length(iniS:finS)
        check_limits(iniS,finS,segmento_S);
    end
    
    if finS>Lout, break; end

    %% OVERLAP AND ADD
    y(iniS:finS)=y(iniS:finS)+segmento_S; 

    %% Actualización de la marca de tiempo para seleccionar el siguiente 
    % segmento de análisis
    
    tk=tk+Pa/beta(pos);
end 


end


%% FUNCIONES SECUNDARIAS

% Función que asocia el periodo de pitch y el factor beta a cada pitch mark

function [Po,beta]=periodo_y_factor(m,idx,fo,Fs,beta_in)
%
% INPUTS:
% m: Vector de pitch marks
% idx: Vector que contiene los indices de cada trama
% fo: Vector de frecuencias de pitch
% Fs: Frecuencia de muestreo
% beta_in: Vector de factores de pitch shifting
%
% OUTPUTS:
% Po: Vector de periodos de pitch para cada pitch mark
% beta: Vector de factores de pitch shifting para cada pitch mark

beta=[];
Po=zeros(1,length(fo));

for i=1:length(m)
    dif=abs(idx-m(i));
    [~,pos]=min(dif);
    beta(i)=beta_in(pos);
    
    if ~isnan(fo(pos))
        Po(i)=round(Fs/fo(pos));
    elseif isnan(fo(pos)) && i~=length(m)
        Po(i)=m(i+1)-m(i);
    elseif isnan(fo(pos)) && i==length(m)
        Po(i)=m(i)-m(i-1);
    end
    
end



end

% Función que resuelve problemas con las posiciones en las que se situan
% los segmentos de síntesis
function [iniS,finS]=check_limits(iniS,finS,segmento_S)
%
% INPUTS:
% iniS: Muestra inicial del segmento de sintesis
% finS: Muestra final del segmento sintesis
% segmento_S: Segmento de sintesis
%
% OUTPUTS;
% iniS: Muestra inicial corregida
% finS: Muestra final corregida
if length(segmento_S)>length(iniS:finS)
    mayor=1;
else
    mayor=0;
end

while length(iniS:finS)~=length(segmento_S)
    
    if mayor
        iniS=iniS-1;
        if iniS<0;break;end
    else
        iniS=iniS+1;
        if iniS>=finS;break;end
    end
end

end
