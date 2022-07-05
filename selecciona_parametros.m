% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function [new_freq,beta,cents,notas]=selecciona_parametros(personalizado,marcados,key,scale,fo,humanizar,q)
%
% INPUTS:
% personalizado: Variable que indica si la escala va a ser personalizada.
% marcados: Variable que contiene las notas de la escala personalizada en
% caso de que personalizado=1.
% key: Variable que indica la nota en la que se afina.
% scale: Variable que indica la escala en la que se afina.
% fo: Vector de frecuencias de pitch
% humanizar: Parámetro para el efecto humanizar
% q: Parámetro que controla la velocidad de afinación
%
% OUTPUTS:
% new_freq: Frecuencias de destino
% beta:  Vector con los factores de pitch shifting de cada trama
% cents: Vector que contiene los cents de cada trama

notas=selecciona_notas(personalizado,marcados,key,scale);
[new_freq,beta,cents]=frecuencias_destino(fo,notas,humanizar,q);

end


% Función para obtener las frecuencias destino y el factor de pitch
% shifting beta para cada trama
function [new_freq,beta,cents]=frecuencias_destino(fo,notas,humanizar,q)
%
% INPUTS:
% fo: Vector que contiene las frecuencias de pitch de cada una de las
% tramas en las que se ha segmentado la señal de entrada
% notas: Vector con las notas sobre las que se puede afinar
% humanizar: Parámetro para el efecto de humanizar
% q: Parámetro que controla la velocidad de afinación
%
% OUTPUTS:
% new_freq: Frecuencias de destino
% beta:  Vector con los factores de pitch shifting de cada trama
% cents: Vector que contiene los cents de cada trama

new_freq=zeros(length(fo),1);
for k=1:length(fo)
    
    if ~isnan(fo(k))
        dif=abs(notas-fo(k));
        [~,pos_min]=min(dif);
        new_freq(k)=notas(pos_min);
    else
        new_freq(k)=nan;
    end
end

beta_inicial=new_freq./fo;
beta_inicial(isnan(beta_inicial))=1;

% Se calculan los cents

cents=3986*log10(beta_inicial);
cents_sin_signo=abs(cents);
beta_inicial(cents_sin_signo<=humanizar)=1;


% Aplicamos factor de velocidad

if q==0
    beta=ones(length(beta_inicial),1);
else
    beta=zeros(length(beta_inicial),1);
    beta(1)=beta_inicial(1);

    for i=2:length(beta_inicial)
        if beta_inicial(i)==1
            beta(i)=1;
        elseif beta_inicial(i)~=1 && beta_inicial(i-1)==1
            beta(i)=beta_inicial(i);
        else
            beta(i)=beta_inicial(i)*q+beta(i-1)*(1-q);
        end
    end
end

end