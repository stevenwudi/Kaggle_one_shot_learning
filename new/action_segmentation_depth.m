%---------------use rgb search for the most similar frame to last & first frame-----------------------%
function [begin_frame, ending_frame,K]=action_segmentation_depth(data,estimated_NN, win_size)
%    if strcmp(model.movie_type, 'K')
        % Use the depth image only
        K=denoise_depth_movie(data.current_movie.K);
  % elseif strcmp(model.movie_type, 'M')
        % Use the RGB image only
      %   K=data.current_movie.M; % Focus on the depth image only
   % end % Focus on the depth image only
   L=length(K);            % Compute the length of the movie
 % window size for HOG-image will be segmentation into 8*8 patches
   hog_2D=zeros(L,win_size*win_size*9);
    x_axis=size(K(1,1).cdata,1);
    y_axis=size(K(1,1).cdata,2);
    gray_movie=zeros(x_axis,y_axis,L);
   for i=1:L
      current_frame=K(1,i).cdata;
      gray_current_frame=rgb2gray(current_frame);
      gray_movie(:,:,i)=gray_current_frame;
      hog_2D(i,:)=HOG(gray_current_frame,win_size); % Compute the 2D HOG descriptor for every frame of the reconstructed movie
   end 
  [D, N] = size(hog_2D(1:end-1,:)');
   estimated_NN=min(estimated_NN,N-1);
    [Class,KnnClass_end] = cvKnn(hog_2D(1:end-1,:)',hog_2D(end,:)',2:size(hog_2D,1),estimated_NN);
    [Class,KnnClass_begin] = cvKnn(hog_2D(2:end,:)',hog_2D(1,:)',2:size(hog_2D,1),estimated_NN);
    similar=unique([KnnClass_end,KnnClass_begin]);
    sort_idx=sort(similar);
    N=0;
    begin_frame=[];
    ending_frame=[];
    for i=1:length(sort_idx)-1
        if sort_idx(i+1)-sort_idx(i)>8
            N=N+1;
            begin_frame(N)=sort_idx(i);
            ending_frame(N)=sort_idx(i+1);
            for inc=1:3
                if ending_frame(N)-begin_frame(N)<13
                    ending_frame(N)=ending_frame(N)+1;
                    begin_frame(N)=begin_frame(N)-1;
                end
            end
        end
    end
    if N==0
        N=N+1;
        begin_frame(N)=5;
        ending_frame(N)=L-5;
        for inc=1:3
            if ending_frame(N)-begin_frame(N)<13
                ending_frame(N)=ending_frame(N)+1;
                begin_frame(N)=begin_frame(N)-1;
            end
        end
    end
    if(begin_frame(1))<1
        begin_frame(1)=1;
    end
    if(ending_frame(end))>length(K)
        ending_frame(end)=length(K);
    end
    %---if algorithm test more than 5 instances, combine the shortest
    %segmentation
    while(length(begin_frame)>5)
        [B,index] = sort(ending_frame-begin_frame);
        IX=index(1);
        if ((IX-1)>0) && ~((IX+1)>length(begin_frame))
        if (ending_frame(IX-1)-begin_frame(IX-1))<(ending_frame(IX+1)-begin_frame(IX+1))
            ending_frame(IX-1)=[];
            begin_frame(IX)=[];
        else
            ending_frame(IX)=[];
            begin_frame(IX+1)=[];
        end
        elseif (IX-1)==0
            ending_frame(1)=[];
            begin_frame(2)=[];
        elseif (IX+1)>length(begin_frame)
            begin_frame(end)=[];
            ending_frame(end-1)=[];
        end
    end
end
%----------------visual exam-----------------------------%
%    for i=1:size(gray_movie,3)
%        imagesc(gray_movie(:,:,i));colormap(gray);
%        t=['frame is ', num2str(i)];
%        title(t);
%        pause(0.3);
%    end