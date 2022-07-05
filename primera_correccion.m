% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function [fo,flag]=primera_correccion(fo,fo_posibles,flag)
%
% INPUTS:
% fo: Vector que contiene frecuencias de pitch
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
% flag: Vector que contiene 0 si el sonido es silencioso, 2 si el sonido es
% sordo y 1 si el sonido es sonoro 
%
% OUTPUTS:
% fo: Vector de frecuencias de entrada tras ser correjido
% flag: Vector flag de entrada actualizado

%% PASO 1: Calculo del vector fo_estimado con filloutliers

fo_estimado=filloutliers(fo,'nearest','median');



for i=1:length(fo)
    
    if ~isnan(fo(i)) && fo(i)~=fo_estimado(i)
        
        %% PASO 2: Diferencia entre valor original y valor estimado
        
        dif=abs(fo_estimado(i)-fo(i));
        if dif>=85
            
            %% PASO 3: Criterio para reemplazar los valores atípicos
        
            if flag(i)==1
                posibles=fo_posibles(i).fo_posibles;
                
                mas_cercano=abs(fo_estimado(i)-posibles);
                [min_dif,pos_min]=min(mas_cercano);
    
                if min_dif<85
                    fo(i)=posibles(pos_min);
                else
                    fo(i)=fo_estimado(i);
                end
            elseif flag(i)==2
                flag(i)=0;
                fo(i)=nan;
            end
            
        end
    end
    
    % SE COMPRUEBA QUE NO SE HA COLADO UN VALOR DISTINTO DE NAN ENTRE DOS
    % SILENCIOS
    
    if  ~isnan(fo(i)) && i~=1 && i~=length(fo) && isnan(fo(i-1)) && isnan(fo(i+1)) 
        fo(i)=nan;
    end
    
    
end

end




