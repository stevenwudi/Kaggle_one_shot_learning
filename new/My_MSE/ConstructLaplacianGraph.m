function [L] = ConstructLaplacianGraph(D, sigma, laplacian_type, connect_type, weight_type)
% laplacian_type: 1=unnormalized; 2=normalized
% connect_type: 0=full connected; >0=KNN
% weight_type: 1=unweighted; 2=weighted
% D=distance matrix; 
% sigma=scaling factor in Gaussian kernel

N = size(D,1);

%----------------weight type-----------------------------------
if(weight_type==1)%unweighted
     W = ones(N,N);
end
if(weight_type==2)%weighted, using Gaussian kernel
    W = (D./sigma);
    W = exp(-W);
end

%-----------connect type---------------------------
if(connect_type==0) % full connected
    C = ones(N,N);
end
if(connect_type>0) % KNN
    C = zeros(N,N);
    K = connect_type;
    [Z,I] = sort(D,2);
    for i=1:N
        for j=1:K+1
            C(i,I(i,j)) = 1;
            C(I(i,j),i) = 1;          
        end
    end
    clear Z;
    clear I;
end

%-----------affinity matrix------------------------------------
A = W.*C;
clear W;
clear C;

%---------------- laplacian type-------------------------------
if(laplacian_type==1) % unnormalized
    L = diag(sum(A,2))-A;
end
if(laplacian_type==2) % normalized
    D2 = diag(1./sqrt(sum(A,2)));
    L = eye(N) - D2*A*D2;   
end









