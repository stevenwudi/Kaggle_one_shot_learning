function [Img,Img_inv] = mhi_silhouet(cuboids)
Height = size(cuboids(1).cdata,1);
Width = size(cuboids(1).cdata,2);
nFrames = length(cuboids);


Diff = zeros(Height,Width,nFrames-1);
Diff_inv = zeros(Height,Width,nFrames-1);

average=zeros(1,nFrames);
for index = 1 : nFrames
average(index) = mean(mean(mean(double(cuboids(index).cdata),3)));
end
m=mean(average);

v=zeros(1,nFrames);
for index = 1 :nFrames
    v(index) = sum(sum((mean(double(cuboids(index).cdata),3) - m).*(mean(double(cuboids(index).cdata),3) - m)));
end
threshold = sqrt(sum(v)/(Height*Width*nFrames));

for index = 1 : nFrames - 1
        Diff(:,:,index) =(abs((mean(double(cuboids(index+1).cdata),3)-mean(double(cuboids(index).cdata),3)))>threshold);
        Diff_inv(:,:,index) =(abs((mean(double(cuboids(nFrames-index).cdata),3)-mean(double(cuboids(nFrames-index+1).cdata),3)))>threshold);
end

Img = zeros(Height*Width,nFrames-1);
Img_inv = zeros(Height*Width,nFrames-1);

for index = 1 : nFrames - 1
    idx= (Diff(:,:,index) == 1);
    Img(idx,index)=nFrames - 1;    
    idx_zeros=find(Diff(:,:,index) == 0);
    if index == 1
        Img(idx_zeros,index)=0;
    elseif index > 1
        Img(idx_zeros,index)= max(0, Img(idx_zeros,index-1) - 1);
    end   
    
    clear idx idx_zeros;
    idx= ((Diff_inv(:,:,index) == 1));
    Img_inv(idx,index)=nFrames - 1;    
    idx_zeros=find(Diff_inv(:,:,index) == 0);
    if index == 1
        Img_inv(idx_zeros,index)=0;
    elseif index > 1
        Img_inv(idx_zeros,index)= max(0, Img_inv(idx_zeros,index-1) - 1);
    end
end
Img = reshape(Img(:,index),Height,Width);
Img_inv = reshape(Img_inv(:,index),Height,Width);
end