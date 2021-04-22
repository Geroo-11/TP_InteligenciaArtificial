% clear;
close all
clear all
clc
grafico=1;
DatosTorneo=csvread('DatosEsea.csv');%leo el archivo
DatosHistoricos=csvread('DatosHistoricos.csv');%leo el archivo
b=0.5;
pruebas=5;
for i=1:pruebas
    V(i,:)=(1:153);
    V(i,:)=randperm(length(V));
end

errorH=1000;
error=1000;

errorMonitoreoSH=cell(1,pruebas);
errorMonitoreoH=cell(1,pruebas);

for i=1:pruebas
    
    Entrenamiento=123;
    Test=20;
    InicioT=Entrenamiento+1;
    
    DatosEntrenamiento = DatosTorneo(V(i,(1:Entrenamiento)),:);
    DatosTest = DatosTorneo(V(i,InicioT:end),:);
    
    [Datos,Test,DatosH,TestH] = CalculoPorcentajes(DatosEntrenamiento, DatosTest, DatosHistoricos);
    [m,n]=size(Datos);
    
    capas=[n-1 13 1];%capas para el perceptron multicapa
    
    [errorMonitoreo, eminSH(i),PesosCapasSH,DeltaCapaSH,epocaSH,SalidaCapaSH,tiempoSH] = percMulti_ent(Datos,1000,0.2,10^-3,capas,b,0,grafico);
    [TESH,vpSH,vnSH,fpSH,fnSH] = percMulti_tst(Test,PesosCapasSH,capas,b);%test
    TESH
    grafico=grafico+1;
    errorMonitoreoSH{1,i}=errorMonitoreo;
    clear errorMonitoreo;
    
    [errorMonitoreo, eminH(i),PesosCapasH,DeltaCapaH,epocaH,SalidaCapaH,tiempoH] = percMulti_ent(DatosH,1000,0.2,10^-3,capas,b,0,grafico);
    [TEH,vpH,vnH,fpH,fnH] = percMulti_tst(TestH,PesosCapasH,capas,b);%test
    TEH
    grafico=grafico+1;
    errorMonitoreoH{1,i}=errorMonitoreo;
    clear errorMonitoreo;
    
    % Guardo datos de Accuracy Sensibilidad y Especificidad
    
    
    accuracyHistorico(i) = 1 - TEH;
    vp(i) = vpH;%predice gana equipo 1 y gana equipo 1
    vn(i) = vnH;%predice gana equipo 2 y gana equipo 2
    fp(i) = fpH;%predice gana equipo 2 y gana equipo 1
    fn(i) = fnH;%predice gana equipo 1 y gana equipo 2
    if(accuracyHistorico(i) > 1 - errorH)
        PesosMejor1=PesosCapasH;
        errorH= 1 - accuracyHistorico(i);
        DatosTest1=Datos;
    end
    
    accuracySinHistorico(i) = 1 - TESH;
    vpS(i) = vpSH;
    vnS(i) = vnSH;
    fpS(i) = fpSH;
    fnS(i) = fnSH;
    if(accuracySinHistorico(i) > 1 - error)
        PesosMejor2=PesosCapasSH;
        error= 1 - accuracySinHistorico(i);
        DatosTest2=Datos;
    end
    clear TESH;
    clear TEH;
end




% Calculo de Accuracy Sensibilidad y Especificidad
AccuracyH=accuracyHistorico
SensibilidadH = vp/(vp+fn);
EspecificidadH = vn/(vn+fp);

AccuracySH=accuracySinHistorico
Sensibilidad = vpS/(vpS+fnS);
Especificidad = vnS/(vnS+fpS);

VarianzaConHistorico = std(AccuracyH)
VarianzasinHistorico = std(AccuracySH)
PorcentajeConH=sum(AccuracyH)/pruebas
PorcentajeSinH=sum(AccuracySH)/pruebas


