%% Set up thre value
thre = 104;

% Have a look of the 1st image
I = imread("Raw0/Run-1-Plate-001 - Original.png");
imshow(I)

% Load colony centers
load('multicenters0.txt')
load('p_x0.txt');
load('p_y0.txt');

% Crop the image
yedge = 40;
xedge = 30;
a = p_y0(1,1)-yedge
b = p_x0(1,1)-xedge
c = p_y0(1,96)-p_y0(1,1)+2*yedge
d = p_x0(1,96)-p_x0(1,1)+2*xedge
Icropped = imcrop(I,[a b c d]);
% imshow(Icropped)

% Save circle centers for cropping images
multicenters(:,1) = multicenters0(:,1) - multicenters0(1,1)+yedge;
multicenters(:,2) = multicenters0(:,2) - multicenters0(1,2)+xedge;
p_y = p_y0-p_y0(1,1)+yedge;
p_x = p_x0-p_x0(1,1)+xedge;
writematrix(multicenters,'multicenters.txt','Delimiter','\t');
writematrix(p_y,'p_y.txt','Delimiter','\t');
writematrix(p_x,'p_x.txt','Delimiter','\t');

% Convert to gray images
Igray = rgb2gray(Icropped);

% Threshold
[T,EM] = graythresh(Igray);

% Create mask
level = graythresh(Igray); % which is 0.3804 for the Sample 6 plate 1
% BW = imbinarize(Icropped,level);
BW = Igray >= level*255*1.15; % Compared *1.1(Bright noise for light) and *1.2(lossing pixels within colony) 
BW = Igray >= 112; % which is equal for the Sample 6 plate 1

% Output the mask of the first plate
%     writematrix(BW,'BW.txt','Delimiter','\t');

% Do the batch
namelistraw = dir('Raw0/*.png');
fileraw = {namelistraw.name};

for file = fileraw (1:end)
    % Initialize output masked image based on input image.
    % file
    I = imread(strcat('Raw0/',string(file)));

    % Crop image
    Icropped = imcrop(I,[a b c d]);
    
    % Create mask
    maskedRGBImage = Icropped;
    Igray = rgb2gray(Icropped);
    BW = Igray >= thre;

    % Set background pixels where BW is false to zero.
    maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
    maskedRGBImage(repmat(BW,[1 1 3])) = 1;
    
    % Output cropped images
    fname = char(file);
    writematrix(maskedRGBImage(:,:,1),strcat('Raw0/threshold_',string(file),'.txt'));
%     imwrite(maskedRGBImage, strcat('Cropped/',string(fname(1:15)),'.png'));

end

