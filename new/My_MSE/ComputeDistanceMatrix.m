function [W] = ComputeDistanceMatrix(data, metric)

% data=numXdim 

[N,dim] = size(data);

W = zeros(N,N);
for i = 1 : N-1,
    for j = i+1 : N,
        W(i,j) = norm(data(i,:)-data(j,:), metric);
        W(j,i) = W(i,j);
    end
end