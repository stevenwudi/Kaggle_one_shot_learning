function prepare_final_resu(data_dir, resu_dir)

% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
%                               SAMPLE CODE FOR THE
%                    ONE-SHOT-LEARNING CHALEARN GESTURE CHALLENGE
%    
%               Isabelle Guyon -- isabelle@clopinet.com -- October 2011
%               Modified by Wudi & Zhufan  --  stevenwudi@gmail.com -- March  2012
%                                   
% -o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-
%
% DISCLAIMER: ALL INFORMATION, SOFTWARE, DOCUMENTATION, AND DATA ARE PROVIDED "AS-IS" 
% ISABELLE GUYON AND/OR OTHER CONTRIBUTORS DISCLAIM ANY EXPRESSED OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
% FOR ANY PARTICULAR PURPOSE, AND THE WARRANTY OF NON-INFRIGEMENT OF ANY THIRD PARTY'S 
% INTELLECTUAL PROPERTY RIGHTS. IN NO EVENT SHALL ISABELLE GUYON AND/OR OTHER CONTRIBUTORS 
% BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
% ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF SOFTWARE, DOCUMENTS, 
% MATERIALS, PUBLICATIONS, OR INFORMATION MADE AVAILABLE FOR THE CHALLENGE. 

%% Initialization
this_dir=pwd;
my_name     = 'xiaozhuwudi';     % Your name or nickname
my_root     = this_dir(1:end-12);   % Change that to the directory of your project
code_dir    = [my_root '\xiaozhuwudi'];      
truth_dir=[];
debug=0;

% 2) Choose your data batches

%type ={'final'};
type ={'devel'};
%type ={'valid'};
%type ={'devel','valid','final'};
num=1:20;
% Set the path and defaults properly; create directories; enable debug mode
% -------------------------------------------------------------------------
warning off all; 
addpath(genpath([code_dir '\mfunc'])); 
addpath(genpath([code_dir '\mmread']));
addpath(genpath([code_dir '\mhi']));
addpath(genpath([code_dir '\new']));
warning on all;

makedir(resu_dir);
my_name(my_name==' ')='';

% Advanced: recognizer options
% There are 3 options for movie_type: 'K' (depth image) and 'M' (RGB
% image)and 'BOTH' .
recog_options={'test_on_training_data=1', 'movie_type=''BOTH'''};
% If test_on_training_data=0, the training examples are not tested with the
% model and the prediction values for training examples are the truth
% values of the labels.

%% Train/Test
% LOOP OVER BATCHES 
% =================
starting_time=datestr(now, 'yyyy_mm_dd_HH_MM');
fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n');
fprintf('\n-o-|-o-|-o-|     EXPERIMENT  %s      |-o-|-o-|-o-\n', starting_time);
fprintf('\n-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-|-o-\n\n');

fprintf('== Legend ==\n');
fprintf('TrLev and TeLev --\t Training and test scores\n\t\t\t (sum Levenshtein distances / true number of gestures).\n');
fprintf('TrLen and TeLen--\t Ave. error made on the number of gestures.\n');
fprintf('Time--\t\t\t Time to train a model and test it on the batch.\n');
fprintf('Average--\t\t Weighted average of scores of the batch,\n\t\t\t weighted by the number of gestures in the set.\n');
for k=1:length(type)
    fprintf('\n==========================================\n');
    fprintf('============    %s DATA    ============\n', upper(type{k}));
    fprintf('==========================================\n');
        
    have_truth=(strcmp(type{k}, 'devel') || ~isempty(truth_dir));   
    if have_truth
% fprintf('SetName\tTrLev%%\tTrLen%%\tDirect%%\t');
% fprintf('Corr%%\tMSE%%\tMSECOR%%\tTeLength%%\n'); 
fprintf('SetName\tTrLev%%\t');
fprintf('TeLevCOR%%\tTeLength%%\tTime\n');
    else
        fprintf('SetName\tTrLev%%\tTrLen%%\tTrainingTime(s)\n');
    end
    
    N=length(num);                  % Number of batches
    TrLevenScore=zeros(N, 1);       % Training score (sum Levenshtein distances / true number of gestures)
    TrLengthScore=zeros(N, 1);      % Average error made in estimating the number of gestures (for training examples)
    TrLabelNum=zeros(N, 1);         % Number of training gestures
    TeLevenScore=zeros(N, 1);       % Test score (sum Levenshtein distances / true number of gestures)
    TeLengthScore=zeros(N, 1);      % Average error made in estimating the number of gestures (for test examples)
    TeLabelNum=zeros(N, 1);         % Number of test gestures
    Time=zeros(N, 1);               % Time to train and test the batch
    Time_train=zeros(N, 1);         % Time to train the batch
    Time_test=zeros(N, 1);          % Time to test the batch

%% Batch start
    for i=1:N
        set_name=sprintf('%s%02d', type{k}, num(i));
        fprintf('%s\t', set_name);
        % Load training and test data
        dt=sprintf('%s/%s', data_dir, set_name);
        if ~exist(dt,'file'),fprintf('No data for %s\n', set_name);  end
        D=databatch(dt, truth_dir);        
        % Split the data into training and test set
        Dtr=subset(D, 1:D.vocabulary_size);
        Dte=subset(D, D.vocabulary_size+1:length(D));
        TrLabelNum(i)=labelnum(Dtr);
        TeLabelNum(i)=labelnum(Dte);
%% Training a  model
        tic
       [tr_resu, mymodel]=train_mhi_extended(recog_template(recog_options), Dtr);               
        TrLevenScore=zeros(N, 1);       % Test score (sum Levenshtein distances / true number of gestures)
        TrLengthScore=zeros(N, 1);      % Average error made in estimating the number of gestures (for test examples)
        TrLevenScore(i)=leven_score(tr_resu);
        TrLengthScore(i)=length_score(tr_resu);
        fprintf('%5.2f\t', 100*TrLevenScore(i));
        Time_train(i)=toc; 
%% Test the model
        tic
        [te_resu]= test_MSE_LDA_two_stage(mymodel, Dte);
        Time_test(i)=toc; 
        Time(i)=Time_train(i)+Time_test(i);
        
%% Print the output
        if have_truth % We know the test labels 
            TeLevenScore(i)=leven_score(te_resu);
            fprintf('%5.2f\t', 100*TeLevenScore(i));
                       
            TeLengthScore(i)=length_score(te_resu);
            fprintf('%5.2f\t',100*TeLengthScore(i));
            
            
             fprintf('%5.2f\t\n', Time(i));
        else %for validation dataset and final dataset
             fprintf('%5.2f\t\n', Time(i));
            
        end
        
            save(tr_resu, [resu_dir '/' set_name '_predict.csv'], [set_name '_'], 'w');
            save(te_resu, [resu_dir '/' set_name '_predict.csv'], [set_name '_'], 'a');
      %  end
    end    
    
    % Summary of results (we need to do a weighted average to get the same
    % result as what we get when we concatenate all the result files)
    if ~isempty(TeLevenScore)
        fprintf('Average\t%5.2f\t',   100*average(TrLevenScore, TrLabelNum));                                 
        if have_truth
            fprintf('%5.2f\t%5.2f\t', 100*average(TeLevenScore, TeLabelNum), ...
                                      100*average(TeLengthScore, TeLabelNum));
        end                        
        fprintf('%5.2f\t%5.2f\n', mean(Time));      
    end
    fprintf('\n');
end

%% Paper for submission
% Prepare the submission by concatenating the results
prepare4submit([my_name '_' starting_time '_predict.csv'], resu_dir);

% Score the overall results
if ~isempty(truth_dir)
    [test_valid_score, test_final_score, train_valid_score, train_final_score] = ...
        compare_files([truth_dir '/truth.csv'], ...
        [resu_dir '/' my_name '_' starting_time '_predict.csv']);
    fprintf('\n\n== Summary of results ==\n');
    fprintf('\nOverall validation error (0 is best): Train=%5.2f%% Test=%5.2f%%\n', 100*train_valid_score, 100*test_valid_score);
    fprintf('Overall final evaluation error (0 is best): Train=%5.2f%% Test=%5.2f%%\n', 100*train_final_score, 100*test_final_score);
end
end

