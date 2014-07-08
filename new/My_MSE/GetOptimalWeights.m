function [WEIGHT] = GetOptimalWeights(CellL, X, bell)

N = size(CellL,2);
WEIGHT = zeros(1,N);
TR = zeros(1,N);

for i=1:N
    TR(i) = trace(X'*CellL{i}*X);
end

avg_tr = mean(TR);

for i=1:N
    WEIGHT(i) = 1.0/N + (avg_tr-TR(i))/(2*bell);
end