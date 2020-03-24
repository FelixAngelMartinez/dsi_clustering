%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C á l c u l o   d e l   B I C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kmax=20;    % número máximo de cluster a analizar
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
% D e t e c c i ó n   d e   o b s e r v a c i o n e s  
% i n f l u y e  n t e s :  M é t o d o  d e  J A C K N I  F E
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all, clear, clc   % cerrrar  ventanas gráficas 
                        % borrar memoria y  consola
                        
X = readtable('data/pca_pc1pc2.csv'); % cargar datos después de aplicar PCA
N=size(X,1);     % número de observaciones
K=7;             % número de clusters
X=table2array(X); % convertimos de tabla a matriz
X=abs(X);
for i=1:N
    X_sin_i=[X(1:(i-1),:);X((i+1):N,:)]; % eliminacion de la 
                                         % observación i
    [cidx, ctrs,sumd,D] = kmeans(X_sin_i, K,'Replicates',10);
    SSE(i)=sum(sumd);   % sumamos  de todas las distancias 
                        % al cuadrado intraclusters obteniedo SSE                      
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% D e t e c c i ó n   v i s u a l
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(SSE)
xlabel('Dato i','fontsize',18)
ylabel('SSE eliminando el dato i','fontsize',18)
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% D e t e c c i ó n   a n a l í t i c a 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma=std(SSE);    % desviación típica
mu=mean(SSE);      % media 
umbral=3;          % umbral =2 para distribuciones normales
                   % umbral =3 para cualquier ditribución
outliers=[];       % inicialización del vector de outliers
for i=1:N
    if abs(SSE(i)-mu)>umbral*sigma
        outliers=[outliers,i];
    end
end
outliers            % impresión por pantalla de los outliers 
writematrix(outliers,'data/outliers.csv')
