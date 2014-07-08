function [Obj, X] = GetOptimalXr(CellL, Y_dim, r, WEIGHT)

N = size(CellL,2);

%------------------Fusion-------------------------------------
FinalL = zeros(size(CellL{1}));
for i=1:N
    FinalL = FinalL + CellL{i}*(WEIGHT(i)^r);
%     FinalL = FinalL + CellL{i}*WEIGHT(i);
end

%--------------Laplacian Eigenmap----------------------------
[eigenvectors,eigenvalues] = Rayleigh(FinalL, Y_dim+1);
clear FinalL;
eigenvalues = diag(eigenvalues);
Obj = sum(eigenvalues(2:Y_dim+1));
X = eigenvectors(:,2:Y_dim+1);
