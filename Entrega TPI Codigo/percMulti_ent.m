function [errorMonitoreo, emin,PesosCapasMejor,DeltaCapa,epoca,SalidaCapa,tiempo] = percMulti_ent(A,epocasN,TdA,tol,capas,b,momento,it)
tic;
%ENTRADAS:
%A=datos de entrada
%epocasN: limite de epocas para entrenar
%tol: Error Aceptado
%TdA: Taza de Aprendizaje
%capas: Vector de N elementos donde N son las capas, el valor es la cantidad de
%       Neuronas de esa capa
%b: parametro de la funcion sigmoidea

[M,N]=size(A); % M Numero de filas de A, columnas N
A = [-1* ones(M,1) A]; %Agrega x0=-1 como primer columna de A
epoca = 1; %Contador de epocas
e = 0; %Taza de error del perceptron
entradas = N; %Numero de entradas de la capa 1, N porque Contiene el vector de
%clase, y al haber agregado x0, A tiene N+1 columnas, Pero las N primeras son las entradas
ncapas = length(capas); %Numero de capas
PesosCapas = cell(1,ncapas);%es un puntero a los pesos de cada capa
SalidaCapa = cell(1,ncapas);%es un puntero a las salidas de cada capa
DeltaCapa = cell(1,ncapas);%es un puntero de delta de cada neurona
deltaPesos = cell(1,ncapas);%inicializo el vector gradiente de error local instantaneo
error=0;
Monitoreo = A(round(M*0.9)+1:end,:);
[M1,N1]=size(Monitoreo);
Datos = A(1:round(M*0.9),:);
[M,N]=size(Datos);
emin=1000;
eMonitoreo = 100;
contadorMonitoreo = 0;

%PesosCapas es un arreglo de una fila y tantas columnas como capas haya
%Cada columna contiene la matriz de pesos de la capa correspondiente


%---genero matrices de pesos fijos aleatorios
PesosCapas{1,1} = rand(capas(1),N-1)-0.5;
for i=2:ncapas
    PesosCapas{1,i} =  rand(capas(i),capas(i-1)+1)-0.5;
end


while epoca<=epocasN
    c = 0; %Contador de distintos
    
    %---Calcula las salidas de la capa 1
    d=A(:,end);
    for i=1:M %Recorre todas las filas de A
        for k=1:ncapas
            W = (cell2mat(PesosCapas(1,k)));
            %aux1 es un auxiliar para cargar las entradas a las capas
            if(k==1)
                aux1=Datos(i,1:entradas);
            else
                aux1=cell2mat(SalidaCapa(1,k-1));
                aux1=[-1 aux1];
            end
            SalidaCapa{:,k} = sigmoidea(aux1*W',b,k);%calculo las salidas utilizacion la sigmoidea
            aux1=0;
        end
        
        %neuronas de la ultima capa
        y=SalidaCapa{:,ncapas};%es la salida de la capa
        Delta=( d(i) - y)*1/2.*(1+y).*(1- y);%calculo el gradiente de error local instantaneo
        DeltaCapa{ncapas}=Delta;%guardo el delta de la ultiam capa
        
        for j=ncapas-1:-1:1 %voy calculando los delta de las capas de adelante hacia atras
            Delta=0;
            y=SalidaCapa{:,j};
            pesos=PesosCapas{j+1};
            Delta=DeltaCapa{j+1}*pesos(:,2:end)*1/2.*(1 + y).*(1- y);
            DeltaCapa{j}=Delta;%guardo los delta capa a capa
        end
        % actualizacion de pesos
        for k=1:ncapas
            %aux2 representa las entradas de la capa actual
            if(k==1)
                aux2=Datos(i,1:entradas);
            else
                aux2=cell2mat(SalidaCapa(1,k-1));
                aux2=[-1 aux2];
            end
            if(momento==1) %si la bandera de momento esta on, cambio el calculo
                if(epoca==1)%como no hay epoca anterior, no puedo sumar algo de los pesos anteriores
                    deltaPesos{1,k}=(TdA*(DeltaCapa{k}' * aux2)+(1/2)* zeros(size(PesosCapas{1,k})));
                else
                    deltaPesos{1,k}=(TdA*(DeltaCapa{k}' * aux2)+((1/2)*deltaPesos{1,k}));
                end
                PesosCapas{1,k}=deltaPesos{1,k} + PesosCapas{1,k};
            else
                PesosCapas{1,k}=TdA*(DeltaCapa{k}'*aux2)+PesosCapas{1,k};%actualizo los pesos
            end
            aux2=0;
        end
    end
    [TEM,vpm,vnm,fpm,fnm] = percMulti_tst(Monitoreo(:,2:end),PesosCapas,capas,b);
    errorMonitoreo(epoca) = TEM;
    
    
    
    %para la epoca actual grafico la clasificacion
    %de errores, verdaderos positivos y falsos positivos
    for i=1:M %Recorre todas las filas de A
        for k=1:ncapas
            W = (cell2mat(PesosCapas(1,k)));
            if(k==1)
                aux1=A(i,1:entradas);
            else
                aux1=cell2mat(SalidaCapa(1,k-1));
                aux1=[-1 aux1];
            end
            SalidaCapa{:,k} = sigmoidea(aux1*W',b,k);
        end
        if(d(i)~=sign(SalidaCapa{:,ncapas}))
            e=e+1;
        end
    end
    
    
    error(epoca)=e/M;
    if(error(epoca)<emin)
        emin=error(epoca);
    end
    if (errorMonitoreo(epoca)<= eMonitoreo  && epoca>10)
        eMonitoreo = errorMonitoreo(epoca);
        contadorMonitoreo = 0;
        PesosCapasMejor = PesosCapas;
    else
        contadorMonitoreo =contadorMonitoreo+ 1;
    end
    %GRAFICO
    cadaCuanto=100;%cada cuantas epocas largo un grafico
    
    %
    
    if( (error(epoca)<tol || contadorMonitoreo >= 150 || epoca==epocasN) && epoca>50)
        tiempo=toc;
        figure(it);
        hold on
        if(mod(it,2)~=0)
            title(['Entrenamiento y monitoreo sin Historico ',num2str(it)])
        else
            title(['Entrenamiento con Historico',num2str(it/2)])
        end
        xlabel('X');
        ylabel('Y');
        plot(error)
        plot(errorMonitoreo);
        hold off
        break;
    end
    e=0;
    
    epoca=epoca+1%actualizo el numero de epoca
    tiempo=toc;
end
end