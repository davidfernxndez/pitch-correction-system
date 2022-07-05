% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
% Trabajo Fin de Grado: Implementación de un corrector de pitch en señales
% de voz e instrumentos monofónicos

function flag=detector_sonido(x,WinLength,OverlapLength)
% INPUTS:
% x: Señal de entrada
% WinLength: Duración de la trama en muestras
% OverlapLength: Duración del solapado en muestras
%
% OUTPUTS:
% flag: Vector que contiene 0 si el sonido es silencioso, 2 si el sonido es
% sordo y 1 si el sonido es sonoro

n=length(x);
ntramas=floor(n/WinLength)*floor(WinLength/OverlapLength)-1;

epsilon=1e-5;     
media_zcr=0;
contador=0;

for i =1:ntramas
    trama=x(1+(i-1)*OverlapLength:(i-1)*OverlapLength+WinLength);
    
    % Energia de la trama
    E(i)=10*log(epsilon+(1/WinLength)*sum(trama.^2));
    
    % Tasa de cruce por cero
    if E(i)>-100
        trama1=trama(2:WinLength);
        trama1(WinLength)=0;
        signs=(trama.*trama1)<0;
        zcr(i)=sum(sum(signs~=0))/(WinLength-1);
        
        % Computo para la media
        media_zcr=media_zcr+zcr(i);
        contador=contador+1;
    else
        zcr(i)=nan;
    end
end
media_zcr=media_zcr/contador;

flag=ones(ntramas,1);
flag(E<-100)=0;
flag(zcr>media_zcr)=2;

end