% This MSE is a alternation of multi-spectral-embedding changed by WuDi
% in order to be more easily implemented
%* by Di Wu (stevenwudi@gmail.com ) 2011-10-26
% Please refers to the paper " Multiview Spectral Embedding"
% Tian Xia, Dacheng Tao, Tao Mei, Yongdong Zhang
%IEEE transactions on system, man and cybernetics
%* License: GPLv2
%* Version: 1.0
function [OBJ, Y,WEIGHT] = MSE(Data_cell,options)
% attribute_No: #of attribute
%-------------------------------------------
%Input: Data_cell:#of Data cell should be the #of attributes, data=num*dim 
%options:
%       .Y_dim: dimension of final feature vector
%       .r   r for the index of weights
%       .metric: 1=L1; 2=L2
%       .sigma: scaling factor in Gaussian kernel
%       .laplacian_type: 1=unnormalized; 2=normalized
%       .connect_type: 0=full connected; >0=KNN
%       .weight_type: 1=unweighted; 2=weighted
%       .iteration_times: EM like iteration in determining a and Y
%       .verbose: for displaying. 1 for display, 0 otherwise
% -------output----------
% OBJ = sum of eigenvalues 
% Y = the final MSE data (I don't know what's it's used for)
% WEIGHT = weights for different views
if ~exist('options','var')
    error('Settings settings should be included');
else
    if isfield(options,'Y_dim'); Y_dim=options.Y_dim;
        else Y_dim=30;end %default final dimension is 30;
    if isfield(options,'r'); r=options.r;
        else r=5;end % r is 5 in default;
    if isfield(options,'metric'); metric=options.metric;
        else metric=2;end % L1 norm
    if isfield(options,'sigma'); sigma=options.sigma; 
        else sigma=30;end  % Better manual set this sigma
    if isfield(options,'laplacian_type'); laplacian_type=options.laplacian_type;
        else laplacian_type=2;end % normalized Laplacian type
    if isfield(options,'connect_type') ;connect_type=options.connect_type;
        else connect_type=0;end % Full connected
    if isfield(options,'weight_type'); weight_type=options.weighted_type;
        else weight_type=2; end % weighted
    if isfield(options,'iteration_times');iteration_times=options.iteration_times;
        else iteration_times=5;end % 5 iteration
        if isfield(options,'verbose'); verbose=options.verbose;
        else verbose=0;end % Default for not displaying
end

num_view=length(Data_cell);
GraphLaplacian=cell(num_view);
D=cell(num_view);

for i=1:num_view
    % Construct Distance Matrix
    D{i}= ComputeDistanceMatrix(Data_cell{i},metric);
    % Construct Graph Laplacian
    GraphLaplacian{i} = ConstructLaplacianGraph(D{i}, sigma, ...
                        laplacian_type, connect_type, weight_type);
end

if(verbose);display('Fusing...');end
% %%%%%%%%%%%%%%% r Order Solution %%%%%%%%%%%%%%%%%%%%%%%%
if(verbose);display(['--------Y-dim=', num2str(Y_dim),...
         ' r=', num2str(r), '------------']);end
 %---------------Generate Initial Weights: average weight------------------------
WEIGHT = (1/num_view)*ones(1,num_view);
%--------------EM like Optimization--------------------------------------
for i=1:iteration_times
    [OBJ, X] = GetOptimalXr(GraphLaplacian, Y_dim, r, WEIGHT);
     WEIGHT = GetOptimalWeightsr(GraphLaplacian, X, r);
    if(verbose); display([num2str(i), ' iteration: ', 'OBJ=', num2str(OBJ)]);end
end

%%%%%%%%%%%%%%%% Linear Weights Solution: average %%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Linear Solution %%%%%%%%%%%%%%%%%%%%%%
% display(['--------Y-dim=', num2str(Y_dim), ' bell=', num2str(bell), '------------']);
% %---------------Generate Initial Weights: average weight------------------------
% WEIGHT = (1/num_view)*ones(1,num_view);
% iteration_times = 10;
% for i=1:iteration_times
%     [OBJ, X] = GetOptimalX(GraphLaplacian, Y_dim, WEIGHT);
%     WEIGHT = GetOptimalWeights(GraphLaplacian, X, r);
%     display([num2str(i), ' iteration: ', 'OBJ=', num2str(OBJ)]);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = zeros(size(GraphLaplacian{1}));
for i=1:num_view
    L = L + WEIGHT(i)*GraphLaplacian{i};
end
[ eigenvectors, eigenvalues] = Rayleigh(L, Y_dim+1);
 eigenvalues = diag( eigenvalues);
OBJ = sum( eigenvalues(2:Y_dim+1));
Y =  eigenvectors(:,2:Y_dim+1);

