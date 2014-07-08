function [resu, model]=train_mhi_extended(model, data,resu_dir)
%[data, model]=train(model, data)
% Template recognizer training method.
% Inputs:
% model     -- A recognizer object.
% data      -- A structure created by databatch.
%
% Returns:
% model     -- The trained model.
% resu      -- A new data structure containing the results.

% Original Isabelle Guyon -- isabelle@clopinet.com -- October 2011
% The original Code is AGI (average gait image)
% Now I extended to MHI  
% Di Wu : stevenwudi@gmail.com ---Jan 2012
 

% For all the training examples, create templates (simple average of the
% depth image

Ntr=length(data);
L=zeros(Ntr, 1);
        T_depth=cell(Ntr, 1);                   % List of templates from training data
        T_mhi_depth=cell(Ntr, 1);               % Di Wu's mhi templates 
        H_inv_depth=cell(Ntr, 1);          
        T_rgb=cell(Ntr, 1);
        T_mhi_rgb=cell(Ntr, 1);               % Di Wu's mhi templates 
        H_inv_rgb=cell(Ntr, 1);  
        
for k=1:Ntr
    goto(data, k);
        [T_depth{k}, L(k)]=average_movie(denoise_depth_movie(data.current_movie.K));
        [T_mhi_depth{k},H_inv_depth{k}] = mhi_silhouet(denoise_depth_movie(data.current_movie.K));
        [T_rgb{k}, L(k)]=average_movie(data.current_movie.M);
        [T_mhi_rgb{k},H_inv_rgb{k}] = mhi_silhouet(data.current_movie.M);
end
y=get_Y(data);
[s, idx]=sort([y{:}]);


        model.T_depth=T_depth(idx);            
        model.T_mhi_depth=T_mhi_depth(idx);         
        model.H_inv_depth=H_inv_depth(idx);
        
        model.T_rgb=T_rgb(idx);
        model.T_mhi_rgb=T_mhi_rgb(idx);
        model.H_inv_rgb=H_inv_rgb(idx);
        % Set the average gesture length
        model.len=mean(L);    
        
        % Eventually  test the model
if model.test_on_training_data
    resu=test_MSE_LDA_two_stage(model, data);
else
    resu=result(data); % Just make a copy
end
 
    %    save(sprintf('%s/%s.mat',resu_dir, data.dataname),'model');
        

end

%if model.verbosity>0, fprintf('\n==TR> Done training %s for movie type %s...\n', class(model), model.movie_type); end


