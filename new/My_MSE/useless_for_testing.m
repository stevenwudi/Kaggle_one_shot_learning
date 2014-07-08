clear;clc;
data{1}=rand(300,40);data{2}=10*rand(300,20);data{3}=100*rand(300,50);
options.Y_dim=10;
[OBJ, Y,WEIGHT] = MSE(data,options);
