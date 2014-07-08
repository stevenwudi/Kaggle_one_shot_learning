function Extract_MHI(data_dir, resu_dir,num)

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

%% Training a  model

      train_mhi_extended(recog_template(recog_options), Dtr,resu_dir);               


    end    

end

end

