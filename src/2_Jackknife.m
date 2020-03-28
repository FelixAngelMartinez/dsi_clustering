close all, clear, clc   % cerrrar  ventanas gr�ficas
% borrar memoria y  consola

X = readtable('data/pca_pc1pc2.csv'); % cargar datos despu�s de aplicar PCA
X = X(:,2:3); % Eliminamos la primera columna, la cual posee en número de empresa a analizar.
N=size(X,1);     % n�mero de observaciones
K=4;             % n�mero de clusters
X=table2array(X); % convertimos de tabla a matriz
X=abs(X);
for i=1:N
    X_sin_i=[X(1:(i-1),:);X((i+1):N,:)]; % eliminacion de la
    % observaci�n i
    [cidx, ctrs,sumd,D] = kmeans(X_sin_i, K,'Replicates',10);
    SSE(i)=sum(sumd);   % sumamos  de todas las distancias
    % al cuadrado intraclusters obteniedo SSE
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% D e t e c c i � n   v i s u a l
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(SSE)
xlabel('Dato i','fontsize',18)
ylabel('SSE eliminando el dato i','fontsize',18)
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% D e t e c c i � n   a n a l � t i c a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma=std(SSE);    % desviaci�n t�pica
mu=mean(SSE);      % media
umbral=3;          % umbral =2 para distribuciones normales
% umbral =3 para cualquier ditribuci�n
outliers=[];       % inicializaci�n del vector de outliers
for i=1:N
    if abs(SSE(i)-mu)>umbral*sigma
        outliers=[outliers,i];
    end
end
outliers            % impresi�n por pantalla de los outliers
writematrix(outliers,'data/outliers.csv')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C � l c u l o   d e l   B I C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sirve para detectar el valor óptimo a la hora de de realizar grupos en
% k-means
Kmax=20;    % n�mero m�ximo de cluster a analizar
for K=2:Kmax
    [cidx] = kmeans(X, K,'Replicates',10);
    [Bic_K,xi]=BIC(K,cidx,X);
    BICK(K)=Bic_K;
end
figure(2)
plot(2:K',BICK(2:K)','s-','MarkerSize',6,...
    'MarkerEdgeColor','r', 'MarkerFaceColor','r')
xlabel('K','fontsize',18)      % etiquetado del eje-x
ylabel('BIC(K)','fontsize',18) % etiquetado del eje-y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D e t e c c i � n   d e   o b s e r v a c i o n e s
% i n f l u y e  n t e s :  M � t o d o  d e  J A C K N I  F E
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
