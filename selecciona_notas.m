% AUTOR: David Fernández Martínez
% Universidad de Granada
% Grado en Ingenieria de Tecnologías de Telecomunicación
%
% Trabajo Fin de Grado. Sistema de corrección de pitch: Desarrollo e
% implementación de un algoritmo de cambio selectivo de la frecuencia
% fundamental en señales de audio enfocado a la afinación de voces e
% instrumentos monofónicos.

function notas=selecciona_notas(personalizado,marcados,key,scale)
%
% INPUTS:
% personalizado: Variable que indica si la escala va a ser personalizada.
% marcados: Variable que contiene las notas de la escala personalizada en
% caso de que personalizado=1.
% key: Variable que indica la nota en la que se afina.
% scale: Variable que indica la escala en la que se afina.


% Notas musicales en un piano ideal de 88 teclas en escala temperada.
notas=zeros(88,1);

notas(1)=27.5;
const=2^(1/12);
for i=2:length(notas)
    notas(i)=notas(i-1)*const;
end


if personalizado
    notas=escala_personalizada(notas,marcados);
else
    notas=escala(notas,key,scale);
end

end



%% FUNCIONES SECUNDARIAS

% Función para seleccionar las notas de la escala personalizada
function notas_new=escala_personalizada(notas,marcados)
[m,n]=size(notas);
notas_new=zeros(m,n);

if marcados(1)==1 % DO
    notas_new(4)=notas(4);notas_new(16)=notas(16);notas_new(28)=notas(28);
    notas_new(40)=notas(40);notas_new(52)=notas(52);notas_new(64)=notas(64);
    notas_new(76)=notas(76);notas_new(88)=notas(88);
end

if marcados(2)==1 % DO SOSTENIDO/RE BEMOL
    notas_new(5)=notas(5);notas_new(17)=notas(17);notas_new(29)=notas(29);
    notas_new(41)=notas(41);notas_new(53)=notas(53);notas_new(65)=notas(65);
    notas_new(77)=notas(77);
end

if marcados(3)==1 % RE
   notas_new(6)=notas(6);notas_new(18)=notas(18);notas_new(30)=notas(30);
   notas_new(42)=notas(42);notas_new(54)=notas(54);notas_new(66)=notas(66);
   notas_new(78)=notas(78);
end

if marcados(4)==1 % RE SOSTENIDO/MI BEMOL
   notas_new(7)=notas(7);notas_new(19)=notas(19);notas_new(31)=notas(31);
   notas_new(43)=notas(43);notas_new(55)=notas(55);notas_new(67)=notas(67);
   notas_new(79)=notas(79);
end

if marcados(5)==1 % MI
   notas_new(8)=notas(8);notas_new(20)=notas(20);notas_new(32)=notas(32);
   notas_new(44)=notas(44);notas_new(56)=notas(56);notas_new(68)=notas(68);
   notas_new(80)=notas(80);
end

if marcados(6)==1 % FA
   notas_new(9)=notas(9);notas_new(21)=notas(21);notas_new(33)=notas(33);
   notas_new(45)=notas(45);notas_new(57)=notas(57);notas_new(69)=notas(69);
   notas_new(81)=notas(81);
end


if marcados(7)==1 % FA SOSTENIDO/SOL BEMOL
   notas_new(10)=notas(10);notas_new(22)=notas(22);notas_new(34)=notas(34);
   notas_new(46)=notas(46);notas_new(58)=notas(58);notas_new(70)=notas(70);
   notas_new(82)=notas(82);
end

if marcados(8)==1 % SOL
   notas_new(11)=notas(11);notas_new(23)=notas(23);notas_new(35)=notas(35);
   notas_new(47)=notas(47);notas_new(59)=notas(59);notas_new(71)=notas(71);
   notas_new(83)=notas(83);
end

if marcados(9)==1 % SOL SOSTENIDO/LA BEMOL
   notas_new(12)=notas(12);notas_new(24)=notas(24);notas_new(36)=notas(36);
   notas_new(48)=notas(48);notas_new(60)=notas(60);notas_new(72)=notas(72);
   notas_new(84)=notas(84);
end

if marcados(10)==1 % LA
   notas_new(13)=notas(13);notas_new(25)=notas(25);notas_new(37)=notas(37);
   notas_new(49)=notas(49);notas_new(61)=notas(61);notas_new(73)=notas(73);
   notas_new(85)=notas(85);notas_new(1)=notas(1);
end

if marcados(11)==1 % LA SOSTENIDO/SI BEMOL
   notas_new(14)=notas(14);notas_new(26)=notas(26);notas_new(38)=notas(38);
   notas_new(50)=notas(50);notas_new(62)=notas(62);notas_new(74)=notas(74);
   notas_new(86)=notas(86);notas_new(2)=notas(2);
end

if marcados(12)==1 % SI
   notas_new(15)=notas(15);notas_new(27)=notas(27);notas_new(39)=notas(39);
   notas_new(51)=notas(51);notas_new(63)=notas(63);notas_new(75)=notas(75);
   notas_new(87)=notas(87);notas_new(3)=notas(3);
end


end

% Función para seleccionar las notas de una de las escalas mayores, menores
% o cromáticas
function notas=escala(notas,key,scale)
if scale==1

elseif scale==2
    switch key
        case 1 % DO MAYOR
            for i=4:12:length(notas)-12
               notas(i+1)=0;notas(i+3)=0;notas(i+6)=0;
               notas(i+8)=0;notas(i+10)=0;
            end
        case 2 % RE BEMOL MAYOR
            for i=4:12:length(notas)-12
                notas(i+2)=0;notas(i+4)=0;notas(i+7)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
        case 3 % RE MAYOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+3)=0;notas(i+5)=0;
                notas(i+8)=0;notas(i+10)=0;
            end
            notas(2)=0;notas(88)=0;
        case 4 % MI BEMOL MAYOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+4)=0;notas(i+7)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
            notas(1)=0;notas(3)=0;
        case 5 % MI MAYOR
            for i=4:12:length(notas)-12
                notas(i+5)=0;notas(i+7)=0;notas(i+10)=0;
                notas(i)=0;notas(i+2)=0;
            end
            notas(2)=0;notas(88)=0;
        case 6 % FA MAYOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+6)=0;
                notas(i+8)=0;notas(i+11)=0;
            end
            notas(3)=0;
        case 7 % FA SOSTENIDO MAYOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+4)=0;
                notas(i+9)=0;
            end
            notas(1)=0;notas(88)=0;
        case 8 % SOL MAYOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+5)=0;
                notas(i+8)=0;notas(i+10)=0;
            end
        case 9 % LA BEMOL MAYOR
            for i=4:12:length(notas)-12
                notas(i+2)=0;notas(i+4)=0;notas(i+6)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
            notas(1)=0;notas(3)=0;
        case 10 % LA MAYOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+5)=0;
                notas(i+7)=0;notas(i+9)=0;
            end
            notas(1)=0;notas(2)=0;notas(88)=0;
        case 11 % SI BEMOL MAYOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+4)=0;notas(i+6)=0;
                notas(i+8)=0;notas(i+11)=0;
            end
            notas(3)=0;
        case 12 % SI MAYOR
             for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+5)=0;
                notas(i+7)=0;notas(i+9)=0;
             end
             notas(1)=0;notas(2)=0;notas(88)=0;
    end
elseif scale==3
    switch key
        case 1 % DO MENOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+6)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
            notas(1)=0;notas(3)=0;
        case 2 % DO SOSTENIDO MENOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+5)=0;
                notas(i+7)=0;notas(i+10)=0;
            end
            notas(88)=0;notas(2)=0;
        case 3 % RE MENOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+6)=0;
                notas(i+8)=0;notas(i+11)=0;
            end
            notas(3)=0;
        case 4 % MI BEMOL MENOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+4)=0;
                notas(i+7)=0;notas(i+9)=0;
            end
            notas(88)=0;notas(1)=0;
        case 5 % MI MENOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+5)=0;
                notas(i+8)=0;notas(i+10)=0;
            end
            notas(2)=0;
        case 6 % FA MENOR
            for i=4:12:length(notas)-12
                notas(i+2)=0;notas(i+4)=0;notas(i+6)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
            notas(1)=0;notas(3)=0;
        case 7 % FA SOSTENIDO MENOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+3)=0;notas(i+5)=0;
                notas(i+7)=0;notas(i+10)=0;
            end
            notas(88)=0;notas(2)=0;
        case 8 % SOL MENOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+4)=0;notas(i+6)=0;
                notas(i+8)=0;notas(i+11)=0;
            end
            notas(3)=0;
        case 9 % SOL SOSTENIDO MENOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+2)=0;notas(i+5)=0;
                notas(i+7)=0;notas(i+9)=0;
            end
            notas(88)=0;notas(1)=0;notas(2)=0;
        case 10 % LA MENOR
            for i=4:12:length(notas)-12
                notas(i+1)=0;notas(i+3)=0;notas(i+6)=0;
                notas(i+8)=0;notas(i+10)=0;
            end
            notas(2)=0;
        case 11 % SI BEMOL MENOR
            for i=4:12:length(notas)-12
                notas(i+2)=0;notas(i+5)=0;notas(i+7)=0;
                notas(i+9)=0;notas(i+11)=0;
            end
            notas(1)=0;notas(3)=0;
        case 12 % SI MENOR
            for i=4:12:length(notas)-12
                notas(i)=0;notas(i+3)=0;notas(i+5)=0;
                notas(i+8)=0;notas(i+10)=0;
            end
            notas(88)=0;notas(2)=0;
    end
            
end

end

