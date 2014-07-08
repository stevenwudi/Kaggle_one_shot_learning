function [ eigenvectors, eigenvalues] = Rayleigh(L, NE)

opts.tol = 1e-9;
opts.issym=1; 
opts.disp = 0; 
[ eigenvectors, eigenvalues] = eigs(L,NE,'sm',opts);

[i,j] = sort(diag( eigenvalues)); 
 eigenvalues = diag(i);
 eigenvectors =  eigenvectors(:,j);

