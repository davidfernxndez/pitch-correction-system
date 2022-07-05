% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function fo=segunda_correccion(fo,fo_posibles,flag)
%
% INPUTS:
% fo: Vector que contiene frecuencias de pitch
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
% flag: Vector que contiene 0 si el sonido es silencioso, 2 si el sonido es
% sordo y 1 si el sonido es sonoro 
%
% OUTPUTS:
% fo: Vector de frecuencias de entrada tras ser corregido

for i=2:length(fo)-1
    
    if ~isnan(fo(i))
        
        if isnan(fo(i-1)) && isnan(fo(i+1))
            fo(i)=nan;
        elseif isnan(fo(i-1)) && ~isnan(fo(i+1))
            % TRAMA TIPO I
            fo(i)=trama_tipo_I(i,fo,flag(i),fo_posibles);
        elseif ~isnan(fo(i-1)) && isnan(fo(i+1))
            % TRAMA TIPO II
            fo(i)=trama_tipo_II(i,fo,flag(i),fo_posibles);
        elseif ~isnan(fo(i-1)) && ~isnan(fo(i+1))
            dif=abs(fo(i)-fo(i-1))/fo(i);
            
            if dif>0.109097
                % TRAMA TIPO III
                fo(i)=trama_tipo_III(i,fo,fo_posibles,flag(i));
            end
        end
    end
end

end


%% FUNCIONES SECUNDARIAS

% Función que detecta valores atípicos en tramas de tipo I
function valor_fo=trama_tipo_I(pos,fo,flag,fo_posibles)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
% flag: Valor en el vector flag de la trama
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
%
% OUTPUTS:
% valor_fo: Valor de frecuencia de pitch decidido.

m=8;

if pos+m>length(fo)
    seg=fo(pos+1:end);
else
    seg=fo(pos+1:pos+m);
end

seg=seg(~isnan(seg));
valor_medio=mean(seg);
dif=abs(fo(pos)-valor_medio)/fo(pos);

if dif>0.109096
    if flag==2
        valor_fo=nan;
    elseif flag==1
        posibles=fo_posibles(pos).fo_posibles;
        mas_cercano=abs(valor_medio-posibles);
        [~,pos_min]=min(mas_cercano);
        valor_fo=posibles(pos_min);
        
        if (abs(valor_medio-valor_fo)/valor_medio )>0.159101
            valor_fo=nan;
        end
    end
else
    valor_fo=fo(pos);
end

end

% Función que detecta valores atípicos en tramas de tipo II
function valor_fo=trama_tipo_II(pos,fo,flag,fo_posibles)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
% flag: Valor en el vector flag de la trama
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
%
% OUTPUTS:
% valor_fo: Valor de frecuencia de pitch decidido.

m=8;

if pos-m<=0
    seg=fo(1:pos-1);
else
    seg=fo(pos-m:pos-1);
end

seg=seg(~isnan(seg));
valor_medio=mean(seg);
dif=abs(fo(pos)-valor_medio)/fo(pos);

if dif>0.159101
    if flag==2
        valor_fo=nan;
    elseif flag==1
        posibles=fo_posibles(pos).fo_posibles;
        mas_cercano=abs(valor_medio-posibles);
        [~,pos_min]=min(mas_cercano);
        valor_fo=posibles(pos_min);
        
        if (abs(valor_medio-valor_fo)/valor_medio )>0.159101
            valor_fo=nan;
        end
    end
else
    valor_fo=fo(pos);
end

end

% Función que detecta valores atípicos en tramas de tipo III
function valor_fo=trama_tipo_III(pos,fo,fo_posibles,flag)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
% flag: Valor en el vector flag de la trama
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
%
% OUTPUTS:
% valor_fo: Valor de frecuencia de pitch decidido.


seg_posterior=hasta_fin_curva(pos,fo);
valor_medio=mean(seg_posterior);

posibles=[fo(pos-1) fo(pos)];
mas_cercano=abs(valor_medio-posibles);
[~,pos_min]=min(mas_cercano);

if pos_min==1
    valor_fo=reemplaza_valor(pos,fo,fo_posibles,flag);
else
    
    if length(seg_posterior)<10
    
        seg_anterior=hasta_inicio_curva(pos,fo);
 
        valor_medio_ant=mean(seg_anterior);
        dif=abs(fo(pos)-valor_medio_ant)/fo(pos);

        if dif>0.250845
            valor_fo=reemplaza_valor(pos,fo,fo_posibles,flag);
        else
            valor_fo=fo(pos);
        end
    else
        valor_fo=fo(pos);
    end
end

end

% Función que reemplaza valores atípicos en función de los vectores flag y
% fo_posibles
function valor_sustituido=reemplaza_valor(pos,fo,fo_posibles,flag)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
% flag: Valor en el vector flag de la trama
% fo_posibles: Struct que contiene el vector frecuencias posibles para cada
% trama
%
% OUTPUTS:
% valor_sustituido: Valor de frecuencia de pitch reemplazado.

    if flag==2
        valor_sustituido=nan;
    elseif flag==1
        posibles=fo_posibles(pos).fo_posibles;
        mas_cercano=abs(fo(pos-1)-posibles);
        [~,pos_min]=min(mas_cercano);
        valor_sustituido=posibles(pos_min);
        
        if (abs(fo(pos-1)-valor_sustituido)/fo(pos-1) )>0.206229
            valor_sustituido=fo(pos-1);
        end
            
    end
end

% Función que devuelve todos los valores del vector fo hasta el final de la
% curva de pitch actual
function seg=hasta_fin_curva(pos,fo)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
%
% seg: Segmento que contiene los valores del vector fo desde pos hasta la
% última muestra de la curva de pitch antes de un valor nan.

encontrado=1;
k=pos+1;

while encontrado
    if k>length(fo)
        fin=length(fo);
        encontrado=0;
    elseif isnan(fo(k))
        fin=k-1;
        encontrado=0;
    end
    k=k+1;
end
seg=fo(pos+1:fin);

end

% Función que devuelve todos los valores del vector fo hasta el inicio de
% la curva de pitch actual
function seg=hasta_inicio_curva(pos,fo)
%
% INPUTS:
% pos: indice de la trama
% fo: Vector de frecuencias de pitch
%
% seg: Segmento que contiene los valores del vector fo desde el inicio de la
% curva de pitch hasta pos.

encontrado=1;
k=pos-1;

while encontrado
    if k<=0
        inicio=1;
        encontrado=0;
    elseif isnan(fo(k))
        inicio=k+1;
        encontrado=0;
    end
    k=k-1;
end
seg=fo(inicio:pos-1);

end