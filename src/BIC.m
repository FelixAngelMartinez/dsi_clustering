function [Bic_K,xi]=BIC(K,cidx,X)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Bic_k     valor BIC
%%  xi        vector conteniendo los valores xi(k)
%%  K         n�mero de clusters
%%  cidx      vector que contiene los grupos de los datos,
%%            esto es, cidx(i) grupo del dato i
%%  X         matriz de datos N X P; 
%%            N numero de individuos y P n�mero de atributos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xi=zeros(1,K);    % vector xi
P=size(X,2);      % n�mero de variables
N=size(X,1);      % n�mero de datos
% c�lculo del sum_xi(k) en la f�rmula
for k=1:K
    suma=0;
    grupo_k=find(cidx==k);              % individuos grupo k
    for j=1:P
        sigma(j)=std(X(:,j))^2;         % varianza del atributo j
                                        % en la muestra
        sigma_j(k,j)=std(X(grupo_k,j))^2; % varianza del atributo j
                                        % dentro del cluster k
        suma=suma+ 0.5*log(sigma(j)+sigma_j(k,j));
    end
    xi(k)= -length(grupo_k)*suma;
end
Bic_K= -2*sum(xi)+2*K*P*log(N);         % f�rmula del BIC
end