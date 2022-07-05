% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function m = PitchMarks(x,Fs,fo,WinLength,OverlapLength)
%
% INPUTS:
% x: Señal de entrada
% Fs: Frecuencia de muestreo 
% fo: Vector que contiene la frecuencia de pitch de cada trama en la que se
% ha segmentado la señal de entrada x.
% WinLength: Duración de la trama en muestras
% OverlapLength: Duración del solapado en muestras 
%
% OUTPUTS:
% m: Vector que contiene las posiciones de las pitch marks


m = 0;             % Posiciones de las pitch marks
Po=[];             % Vector de periodos de pitch
last_m = 1;        % Última pitch mark encontrado
delta=3;           % Factor de tolerancia [1,6]
kt=3;              % Número de iteraciones del análisis extendido              
delta_s=0.5;       % Factor de tamaño de la subregión [0,1]

% Vector que contiene 1 si la trama es sonora y 0 si es sorda/silenciosa
sonido=ones(1,length(fo));      
sonido(isnan(fo))=0;

for i=1:length(fo)
    % Se inicializa vector en el que se almacenan las pitch marks de la
    % trama
    trama_m=[];
    
    % Si la trama es sorda se coloca el valor de fo de la trama anterior
    if (i==1 && isnan(fo(i)) )
        fo(i)=120; 
    elseif isnan(fo(i))
        fo(i)=fo(i-1);
    end
    
    % Periodo de pitch
    Po(i)=round(Fs/fo(i));
    % trama de señal que se está procesando
    trama = (1:WinLength) + (i-1)*OverlapLength;
    
    %% TRAMA SONORA
    
    if sonido(i)
        
        % POSICIONAMIENTO DE LA PRIMERA PITCH MARK DE LA TRAMA
        k=1;
        
        if i==1 % Primera trama de la señal
            lim_inf=1;
            lim_sup=Po(i);
            trama_m(k)=Po(i);
        else
            if sonido(i-1) 
                lim_inf=lim_sup+1;
                lim_sup=lim_sup+Po(i);

                centro_energia=calcula_centro_energia(x,lim_inf,lim_sup);
                m_est=last_m+Po(i);
                trama_m(k)=refinar_pos_m(centro_energia,m_est,delta);
                
            else % Transitorio detectado
                
                % Cálculo de nueva región de análisis con análisis
                % extendido
                [lim_inf,lim_sup]=analisis_extendido(x,lim_sup,Po(i),delta_s,kt);
                
                % Ahora se procede de forma normal sobre los nuevos limites
                centro_energia=calcula_centro_energia(x,lim_inf,lim_sup);
                m_est=last_m+Po(i);
                trama_m(k)=refinar_pos_m(centro_energia,m_est,delta);
            end 
        end
        % FIN DEL POSICIONAMIENTO DE LA PRIMERA PITCH MARK DE LA TRAMA
        % POSICIONAMIENTO DEL RESTO DE PITCH MARKS DE LA TRAMA
        last_m=trama_m(1);
        k=2;
        while (lim_sup+Po(i))<=trama(end)
           lim_inf=lim_sup+1;
           lim_sup=lim_sup+Po(i);
            
           centro_energia=calcula_centro_energia(x,lim_inf,lim_sup);
           m_est=last_m+Po(i);
           trama_m(k)=refinar_pos_m(centro_energia,m_est,delta);
            
           last_m=trama_m(k);
           k=k+1;
        end
        % FIN DEL POSICIONAMIENTO DEL RESTO DE PITCH MARKS
        m=[m trama_m];
    
    %% TRAMA SORDA O SILENCIOSA fo=nan 
    else
        % POSICIONAMIENTO DE LA PRIMERA PITCH MARK EN LA TRAMA
        k=1;
        
        if i==1
            lim_sup=Po(i);
            trama_m(k)=Po(i);
        else
            lim_sup=lim_sup+Po(i);
            trama_m(k)=last_m+Po(i);
        end
        % FIN DEL POSICIONAMIENTO DE LA PRIMERA PITCH MARK EN LA TRAMA
        % POSICIONAMIENTO DEL RESTO DE PITCH MARKS DE LA TRAMA
        last_m=trama_m(1);
        k=2;
        while (lim_sup+Po(i))<trama(end)
            lim_sup=lim_sup+Po(i);
            trama_m(k)=last_m+Po(i);
            
            last_m=trama_m(k);
            k=k+1;
        end
        % FIN DEL POSICIONAMIENTO DEL RESTO DE PITCH MARKS
        m=[m trama_m];
    end
end

m = sort(m);        % Ordena de forma ascendente
m = unique(m);      % Elimina repetidos
m = m(2:end);       % Elimina valor inicial que es cero

end

%% FUNCIONES SECUNDARIAS

% Función que calcula el centro de energía de la región de análisis dada
% por lim_inf y lim_sup.
function centro_energia=calcula_centro_energia(x,lim_inf,lim_sup)
%
% INPUTS:
% x: Señal de entrada
% lim_inf: Límite inferior de la región de análisis
% lim_sup: Límite superior de la región de análisis
% 
% OUTPUTS:
% centro_energia: Centro de energía de la región de análisis
Ex=0;
num=0;

for n=lim_inf:lim_sup
    Ex=Ex+x(n)^2;
    num=num+(x(n)^2)*n;
end
centro_energia=round(num/Ex);

end


% Función que refina la posición de la pitch mark con factor de tolerancia
% delta.
function m_refinado=refinar_pos_m(centro_energia,m_est,delta)
%
% INPUTS: 
% centro_energia: Centro de energía de la región de análisis
% m_est: Estimación m(i)=m(i-1)+Po(i)
% delta: Factor de tolerancia
%
% OUTPUTS
% m_refinado: Posición de la pitch mark

if abs(m_est-centro_energia)<=delta
    m_refinado=centro_energia;
elseif m_est< (centro_energia-delta)
    m_refinado=m_est+delta;
else
    m_refinado=m_est-delta;
end

end

% Función que implementa el análisis extendido para mejorar el algoritmo en
% las zonas transitorias de la señal.
function [lim_inf_new,lim_sup_new]=analisis_extendido(x,lim_sup,Po,delta_s,kt)
%
% INPUTS:
% x: Señal de entrada
% lim_sup: límite superior de la región de análisis
% Po: Periodo de pitch de la trama
% delta_s: Factor de tamaño de la subregión
% kt: Número de iteraciones
%
% OUTPUS:
% lim_inf_new: Límite inferior de la región óptima
% lim_sup_new: Límite superior de la región óptima

delta_t=round ((1-delta_s)*(Po/2));     % truncamiento de la región de 
                                        % análisis
ht=round(Po/kt);                        % Número de muestras que se desplaza
                                        % la región de análisis

% Vectores donde se almacenan los límites de las regiones de análisis
% desplazadas

lim_inf_v=[];
lim_sup_v=[];

lim_inf_v(1)=lim_sup+1;
lim_sup_v(1)=lim_sup+Po;

% Límites de la subregión
lim_inf_sub(1)=lim_inf_v(1)+delta_t;
lim_sup_sub(1)=lim_sup_v(1)-delta_t;

% Vector donde se almacenan las energías de cada subregión
Ex=[];
Ex(1)=calcula_Ex(x,lim_inf_sub(1),lim_sup_sub(1));

for tr=2:kt+1
  lim_inf_v(tr)=lim_inf_v(tr-1)-ht;
  lim_sup_v(tr)=lim_sup_v(tr-1)-ht;
  lim_inf_sub(tr)=lim_inf_v(tr)+delta_t;
  lim_sup_sub(tr)=lim_sup_v(tr)-delta_t;
  Ex(tr)=calcula_Ex(x,lim_inf_sub(tr),lim_sup_sub(tr));
end
[~,pos]=max(Ex);
lim_inf_new=lim_inf_v(pos);
lim_sup_new=lim_sup_v(pos);


end

% Función que calcula la energía de una región de análisis
function Ex=calcula_Ex(x,lim_inf,lim_sup)
%
% INPUTS:
% x: Señal de entrada
% lim_inf: Límite inferior de la región de análisis
% lim_sup: Límite superior de la región de análisis
%
% OUTPUTS: 
% Ex: Energía de la región de análisis

Ex=0;

for n=lim_inf:lim_sup
    Ex=Ex+x(n)^2;
end

end