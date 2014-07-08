function [resu]= test_MSE_LDA_two_stage(model, data)

resu=result(data);
% Loop over the samples (we also test the training samples)
Nte=length(data);

     win_size=16; % window size for HOG   
     
     model_hog_agi_depth=zeros(length(model.T_depth),win_size*win_size*9);
     model_hog_mhi_depth=zeros(length(model.T_depth),win_size*win_size*9);
     model_hog_inv_depth=zeros(length(model.T_depth),win_size*win_size*9);
     model_hog_agi_rgb=zeros(length(model.T_depth),win_size*win_size*9);
     model_hog_mhi_rgb=zeros(length(model.T_depth),win_size*win_size*9);
     model_hog_inv_rgb=zeros(length(model.T_depth),win_size*win_size*9);
    
     training_template1=zeros(length(model.T_depth),win_size*win_size*9*3);
     training_template2=zeros(length(model.T_depth),win_size*win_size*9*3);

     training_template=zeros(length(model.T_depth),win_size*win_size*9*3*2);
       
    for j=1:length(model.T_depth)
        % Use bith Depth and RGB images
        model_hog_agi_depth(j,:)=HOG(model.T_depth{j},win_size);
        model_hog_mhi_depth(j,:)=HOG(model.T_mhi_depth{j},win_size);
        model_hog_inv_depth(j,:)=HOG(model.H_inv_depth{j},win_size);
        model_hog_agi_rgb(j,:)=HOG(model.T_rgb{j},win_size);
        model_hog_mhi_rgb(j,:)=HOG(model.T_mhi_rgb{j},win_size);
        model_hog_inv_rgb(j,:)=HOG(model.H_inv_rgb{j},win_size);
        training_template1(j,:)=cat(2,model_hog_agi_depth(j,:), model_hog_mhi_depth(j,:),model_hog_inv_depth(j,:));
        training_template2(j,:)=cat(2,model_hog_agi_rgb(j,:), model_hog_mhi_rgb(j,:),model_hog_inv_rgb(j,:));
        training_template(j,:)=cat(2,training_template1(j,:),training_template2(j,:));
    end
trainVector=training_template;
gnd=1:length(model.T_depth);

%---LDA-------%
%addpath(genpath('C:\DATASET\IXMAS\3D\all'));
options.Fisherface = 1; %%??
[eigvector1] = LDA(gnd, options,training_template1);
training_template1=training_template1*eigvector1;
[eigvector2] = LDA(gnd, options,training_template2);
training_template2=training_template2*eigvector2;
[eigvector] = LDA(gnd, options,trainVector);
trainVector=trainVector*eigvector;

VIEW1=training_template1;
VIEW2=training_template2;

testing_action_number=zeros(1,Nte);
%---------------testing--------%  
for k=1:Nte   
    clear Y;
    goto(data, k);    
 %------------If movie length is smaller then 10,then error occurs for
    %dataet, (using RGB video for the judegment)----------------%
    K=data.current_movie.K; % Focus on the depth image only
    L=length(K);            % Compute the length of the movie
 if L>10 % which means that the video has NOT been corrupted
%------------For training data, NO need to compute 2d hog---------
  if data.test_the_train 
        y=get_Y(data);
   %--------------correlation coefficient----------%
        for m=1:size(trainVector,1)
            c=corrcoef(trainVector(k,:), trainVector(m,:));
            S(m)=c(1,2);
        end
        [dummy,Classcor]=max(S);
        Y=y{Classcor};
    else 
   %---------------use rgb search for the most similar frame to last &
        %first frame-----------------------%
    N=min(max(1, round(L/model.len)), 5); % Number of estimated gestures
    estimated_NN=(N+1)*8;
    [begin_frame, ending_frame,K]=action_segmentation_depth(data,estimated_NN, win_size);
    N=length(begin_frame);
    testing_action_number(k)=N; % For grouping    
    
    for i=1:N    
        % Use bith Depth and RGB images        
        
        [X_depth]=average_movie(K(begin_frame(i):ending_frame(i)));
        [X_mhi_depth,X_inv_depth] = mhi_silhouet(K(begin_frame(i):ending_frame(i)));
        
        [X_rgb]=average_movie(data.current_movie.M(begin_frame(i):ending_frame(i)));
        [X_mhi_rgb,X_inv_rgb] = mhi_silhouet(data.current_movie.M(begin_frame(i):ending_frame(i)));
         temp_data_agi=HOG(X_depth,win_size);
         temp_data_mhi=HOG(X_mhi_depth,win_size);
         temp_data_inv=HOG(X_inv_depth,win_size);
         testing_template_depth=cat(1,temp_data_agi,temp_data_mhi,temp_data_inv);
         
         temp_data_agi=HOG(X_rgb,win_size);
         temp_data_mhi=HOG(X_mhi_rgb,win_size);
         temp_data_inv=HOG(X_inv_rgb,win_size);
         testing_template_rgb=cat(1,temp_data_agi,temp_data_mhi,temp_data_inv);
         
         testing_template=cat(1,testing_template_depth,testing_template_rgb);
         
         testVector=testing_template';
        
         testVector=testVector*eigvector;
         testing_template_depth=(testing_template_depth'*eigvector1)';
         testing_template_rgb=(testing_template_rgb'*eigvector2)';
        
         VIEW1(end+1,:)=testing_template_depth;
         VIEW2(end+1,:)=testing_template_rgb;

       %--------------correlation coefficient----------%
        for m=1:size(trainVector,1)
            c=corrcoef(testVector, trainVector(m,:));
            S(m)=c(1,2);
        end
        [dummy,Classcor]=max(S);
        Y(i)=Classcor;
     end
   end
%-------------------------------------------------------------%
set_X(resu, k, Y);
 else %if the video has been corrupted, then we choose one training example 
           % for substitution
      fprintf('Video %d has been corrupted   ',(k+size(training_template1,1)));
      VIEW1(end+1,:)=training_template1(1,:);
      VIEW2(end+1,:)=training_template2(1,:);
      testing_action_number(k)=1; % For grouping   
 end
     
end

 if ~data.test_the_train  % For testing data
%--------------------MSE depth and rgb combined in one set 2 stages-----------%
    clear Y_vector Y;
    vector{1}=VIEW1;
    vector{2}=VIEW2;
warning off all
    options.Y_dim=length(gnd)-1;
    options.iteration_times=30;
    options.r=1.5; % Correlation matter
    options.sigma=10;
    options.laplacian_type=2;
    [OBJ,Y_vector,weight]=MSE(vector,options);
warning on all
TrainVector=Y_vector(1:length(gnd),:);
beginNo=length(gnd)+1;
for k=1:Nte  
    clear Y;
  for i=1:testing_action_number(k)
      TestVector=Y_vector(beginNo,:);
      beginNo=beginNo+1;
      %----- Correlation Coefficient for MSE------------------%
        for m=1:size(TrainVector,1)
            c=corrcoef(TestVector, TrainVector(m,:));
            S(m)=c(1,2);
        end
        [dummy,Classcor_mse]=max(S);
        Y(i)=Classcor_mse;
  end
% if  strcmp( data.dataname,'valid11')
%     Y((Y==2))=4;
%     Y((Y==5))=10;
% end
set_X(resu, k, Y);
end
end    