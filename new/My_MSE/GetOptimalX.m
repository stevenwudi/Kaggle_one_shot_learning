function [Obj, X] = GetOptimalX(CellL, Y_dim, WEIGHT)

N = size(CellL,2);
if sum(WEIGHT)~= 1
    disp('sum of weight does not equal 1!');
end

%------------------Fusion-------------------------------------
FinalL = zeros(size(CellL{1}));
for i=1:N
    FinalL = FinalL + CellL{i}*WEIGHT(i);
end

%--------------Laplacian Eigenmap----------------------------
[E,V] = Rayleigh(FinalL, Y_dim+1);
clear FinalL;
V = diag(V);
Obj = sum(V(2:Y_dim+1));
X = E(:,2:Y_dim+1);
