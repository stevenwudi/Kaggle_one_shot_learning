function [X]=denoise_depth_movie(M)
	numFrames=length(M);    
    se = strel('disk', 5);
    se2=se;
   % se2 = strel(ones(5,5));
    X=struct('cdata',{});
warning off all
for k = 1 : numFrames
                level=graythresh(M(k).cdata);%Initial level for im2bw=0.6;
                BW=im2bw(M(k).cdata,level);
                BW(:,1:5)=1; % Get rid of the left most 5 column noise
                I=BW;    
                Ie = imerode(I, se);
                Iobr = imreconstruct(Ie, I);
                Iobrd = imdilate(Iobr, se);
                Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
                Iobrcbr = imcomplement(Iobrcbr);
                fgm = imregionalmax(Iobrcbr);
                fgm2 = imclose(fgm, se2);
                fgm3 = imerode(fgm2, se2);
                fgm4 = bwareaopen(fgm3, 100);
                for i=1:3
                    temp(:,:,i)=fgm4;
                    img(:,:,i) = medfilt2(M(k).cdata(:,:,1), [5 5]);
                end
                X(k).cdata=img.*uint8(~temp);
end   
warning on all
end

