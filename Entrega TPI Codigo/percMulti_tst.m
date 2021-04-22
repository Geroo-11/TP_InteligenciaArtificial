function [TE,vp,vn,fp,fn] = percMulti_tst(A,PesosCapas,capas,b)
[M,N]=size(A); % M Numero de filas de A, columnas N
A = [-1* ones(M,1) A]; %Agrega x0=-1 como primer columna de A
e = 0; %Taza de error del perceptron
ncapas = length(capas);%cantidad de capas
SalidaCapa = cell(1,ncapas);%creo el "indice" de matrices de salida
d=A(:,end);
E=[];

vp = 0;
vn = 0;
fp = 0;
fn = 0;
for i=1:M %Recorre todas las filas de A
    for k=1:ncapas
        W = (cell2mat(PesosCapas(1,k)));
        if(k==1)
            aux1=A(i,1:N);
        else
            aux1=cell2mat(SalidaCapa(1,k-1));
            aux1=[-1 aux1];
        end
        SalidaCapa{:,k} = sigmoidea(aux1*W',b,k);
    end
  
    if(d(i)~=sign(SalidaCapa{:,ncapas}))
        e=e+1;
        E=[E A(i,:)];
    end
    if(sign(SalidaCapa{:,ncapas}) == d(i) )
        if( d(i) == 1)
            vp =vp+ 1;
        else
            vn =vn + 1;
        end
    else
        if(d(i) == 1)
            fn =fn + 1;
        else
            fp =fp + 1;
        end
    end
end


TE=e/M;

end