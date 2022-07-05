
clear all
clc


%% SELECCIÓN DEL AUDIO
tic
[x,Fs]=audioread('./audios/c_tangana.wav');

if size(x,2)==2
    x=x(:,1)/2+x(:,2)/2;
end

%% SELECCION DEL TIPO DE SEÑAL DE ENTRADA

% Default---> input_type=1
% Soprano---> input_type=2
% Tenor ----> input_type=3
% Instrument---> input_type=4

input_type=1;

if input_type==1
    FoMin=80;
    FoMax=1300;
elseif input_type==2
    FoMin=200;
    FoMax=1300;
elseif input_type==3
    FoMin=80;
    FoMax=500;
elseif input_type==4
    FoMin=20;
    FoMax=4200;
end

[fo,idx,x]=deteccion_pitch(x,Fs,FoMin,FoMax);
tfo=idx/Fs;

%% SELECCIONA LA ESCALA

% 1---> Chromatic
% 2---> Mayor
% 3---> Menor

scale=1;

%% SELECCIONA LA NOTA

% NOTAS ESCALA MAYOR

% 1---> DO      (C)
% 2---> Re Bemol(Db)
% 3---> RE      (D)
% 4---> Mi Bemol(Eb)
% 5---> Mi      (E)
% 6---> FA      (F)
% 7---> Fa Sostenido (F#)
% 8---> SOL     (G)
% 9---> La bemol(Ab)
% 10---> LA      (A)
% 11---> Si Bemol(Bb)
% 12---> Si     (B)

% NOTAS ESCALA MENOR

% 1---> DO      (C)
% 2---> DO Sostenido(C#)
% 3---> RE      (D)
% 4---> Mi Bemol(Eb)
% 5---> Mi      (E)
% 6---> FA      (F)
% 7---> Fa Sostenido (F#)
% 8---> SOL     (G)
% 9---> SOL Sostenido(G#)
% 10---> LA      (A)
% 11---> Si Bemol(Bb)
% 12---> Si     (B)


key=1;

%% SELECCIONA SI QUIERES PERSONALIZAR LA ESCALA

% 1---> Se puede personalizar, debes marcar las notas
% 0---> No se puede personalizar

personalizado=0;

if personalizado
    do=1;
    do_sostenido=1;
    re=1;
    re_Sostenido=1;
    mi=1;
    fa=1;
    fa_sostenido=1;
    sol=1;
    sol_sostenido=1;
    la=1;
    la_sostenido=1;
    si=1;
    marcados=[do do_sostenido re re_Sostenido mi fa fa_sostenido sol sol_sostenido la la_sostenido si];
else
    marcados=0;
end

%% PARÁMETROS DE LA CORRECCION

% NATURALIZACIÓN [0,100]cents
% VELOCIDAD [0,1]
naturalizar=0;
velocidad=1;

[new_freq,beta,cents,notas]=selecciona_parametros(personalizado,marcados,key,scale,fo,naturalizar,velocidad);

%% PITCH SHIFTING

y=pitchShift(x,Fs,fo,idx,beta);

audiowrite('salida.wav',y,Fs);

%sound(y,Fs);


%% REPRESENTACION DE RESULTADOS

t=[0:length(x)-1]/Fs;
figure(1)
plot(t,x,'b')
xlabel('tiempo(s)')
ylabel('Amplitud')
grid on
title('Señal en el dominio del tiempo')

figure(2)
plot_key_anglosajon(tfo,fo)
xlabel('tiempo (s)')
ylabel('Notas')
grid on
title('Curva de pitch de la señal de entrada x(n)')

figure(3)
plot_key_anglosajon(tfo,fo)
yline(notas)
xlabel('tiempo (s)')
ylabel('Notas')
grid on
title('Notas permitidas sobre la escal seleccionada')
legend('Curva de pitch x(n)','Notas permitidas')

[fo_y,idx,y]=deteccion_pitch(y,Fs,FoMin,FoMax);
tfo_y=idx/Fs;

figure(4)
plot_key_anglosajon(tfo_y,fo_Y)
xlabel('tiempo (s)')
ylabel('Notas')
grid on
title('Curva de pitch de la señal de salida y(n)')

figure(5)
plot_key_anglosajon(tfo_y,fo_y)
yline(notas)
xlabel('tiempo (s)')
ylabel('Notas')
grid on
title('Resultado sobre las notas permitidas')
legend('Curva de pitch x(n)','Notas permitidas')