%Change : segmentation using denoise depth image
%     se = strel('disk', 5);
%     se2=se;
%  

    

clc;clear;
close all

resu_file   = 'H:\KaggleKinect\xiaozhuwudi\Results';
data_dir='H:\KaggleKinect\devel01-40\devel01-40';
prepare_final_resu(data_dir, resu_file)




increment=40;

% for i=2:8
%     data_dir = ['I:\DATASET\KaggleKinect\devel', num2str(161+(i-1)*increment),'-', num2str(160+(i)*increment),'\devel'...
%          num2str(161+(i-1)*increment),'-', num2str(160+(i)*increment)];
%     num=161+(i-1)*increment:160+(i)*increment;
%     Extract_MHI(data_dir, resu_file,num);
% end
%     



    data_dir='H:\KaggleKinect\devel01-40\devel01-40';
    num=1:40;
    Extract_MHI(data_dir, resu_file,num);

    
    data_dir='I:\DATASET\KaggleKinect\devel41-80\devel41-80';
    num=41:80;
    Extract_MHI(data_dir, resu_file,num);
    
    
    data_dir='I:\DATASET\KaggleKinect\devel81-120\devel81-120';
    num=81:120;
    Extract_MHI(data_dir, resu_file,num);
    
    
