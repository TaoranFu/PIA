% Have a look of the 1st image
I = imread("Raw/Run-1-Plate-001 - Original.png");
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
disp('112')
BW = Igray >= 112; % which is equal for the Sample 6 plate 1

% Output the mask of the first plate
%     writematrix(BW,'BW.txt','Delimiter','\t');

% Do the batch
namelistraw = dir('Raw/*.png');
fileraw = {namelistraw.name};
for file = fileraw (1:end)
    % Initialize output masked image based on input image.
    % file
    I = imread(strcat('Raw/',string(file)));

    % Crop image
    Icropped = imcrop(I,[a b c d]);

    % grow the background
%     disp('start')
    Igray = im2gray(Icropped);
%     [Tbackground BckSum] = regiongrowing(im2double(Icropped),4,4);
%     disp('done')

    % Create mask
    maskedRGBImage = Icropped;
    % threshold and find the mean of the background
    BWadd = [];
    BWmin = Igray <= 123.70+4.3+5;
%     BWmax = Igray >= 132.56;
%     BWadd = max(BWmin,BWmax);

    % calculate biased by exp plate
    Maskedadd= im2gray(Icropped);
%     Maskedadd(repmat(BWadd,[1 1 1])) = 0;
    Maskedadd(repmat(BWmin,[1 1 1])) = 0;
    calmean = Maskedadd;
    calmean(Maskedadd==0)=nan;
    mean0 = mean(nonzeros(calmean),'all');

    add = mean0-128.13;

    disp([128 + add 128+sqrt(add)*3.7]);
    BW = Igray >= 128+sqrt(add)*3.7;

    % Set background pixels where BW is false to zero.
    maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

    % Output cropped images
    fname = char(file);
%     imwrite(maskedRGBImage, strcat('Cropped/',string(fname(1:15)),'.png'));

    % Rescue features with a high contrast edge
    % https://uk.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html?searchHighlight=cell%20edge&s_tid=srchtitle_cell%20edge_2
        % using LES58 plate 3 for determining method

        % detect the edge
        [~,threshold] = edge(Igray,'sobel');
%         threshold = 1;
        fudgeFactor = 0.75;
        BWs = edge(Igray,'sobel',threshold * fudgeFactor);
        imshow(BWs)

        se90 = strel('line',3,90);
        se0 = strel('line',3,0);

        BWsdil = imdilate(BWs,[se90 se0]);
        imshow(BWsdil)

        % fill the holes
        BWdfill = imfill(BWsdil,'holes');
        imshow(BWdfill)

        % clean the border
        BWnobord = imclearborder(BWdfill,1);
%         imshow(BWnobord)

        % smooth the object
        seD = strel('diamond',1);
        BWfinal = imerode(BWnobord,seD);
        BWfinal = imerode(BWfinal,seD);
%         imshow(BWfinal)

        Rescueedge = Igray;
        Rescueedge(repmat(~BWfinal,[1 1 1])) = 0;
        BWmax = max(BW,BWfinal);
        Ifinal = Icropped;
        Ifinal(repmat(~BWmax,[1 1 3])) = 0;
        imshow(Ifinal)

        % overlap with old crop
        oldthre = load(strcat('Raw0/threshold_',fname,'.txt'));
        Ifinal(repmat(~oldthre,[1 1 3])) = 0;
        imwrite(Ifinal, strcat('Cropped/',string(fname(1:15)),'.png'));

end
