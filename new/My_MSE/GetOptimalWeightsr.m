function [WEIGHT] = GetOptimalWeightsr(CellL, X, r)

N = size(CellL,2);
WEIGHT = zeros(1,N);
TR = zeros(1,N);
TMP = zeros(1,N);

for i=1:N
    TR(i) = trace(X'*CellL{i}*X);
end
for i=1:N
    TMP(i) = (1/TR(i))^(1/(r-1));
end
Sum_Tmp = sum(TMP);
for i=1:N
    WEIGHT(i) = TMP(i)/Sum_Tmp;
end