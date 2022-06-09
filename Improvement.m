K = imread('imcomplement_model.png');
filelist = dir('Raw0/*.png');
list = {filelist.name};

for i =list
Rproceed = ...
    imlincomb(1/2,rgb2gray(imread(strcat("Raw0/",string(i)))),...
    1/2,K);
% Radjust = imadjust(Rproceed);
Radjust = Rproceed;
Rrgb(:,:,1) = Radjust;
Rrgb(:,:,2) = Radjust;
Rrgb(:,:,3) = Radjust;
imwrite( Rrgb,...
    strcat('Raw/',string(i)))
end

