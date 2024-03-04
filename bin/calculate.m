function calculate(varargin)
%CALCULATE Calculate the colony area and interesting paramters from images
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     calculate("Thickness", 0.4, 
%               "InDir","../example/04_segmentation",
%               "OutDir","../example/05_calculation",
%               "Coord", "../example/02_crop and filter",
%               "Radius", 16, "Ellipticity", 1.1)
% 
% Thickness     The thickness of the agar if you want to calculate the
%               volume of under the detected are, e.g. Brightness*pixel^2*cm
% Coord         Directory with the .txt file with coordinates of the colony centers
% Radius        Colony area to start growing seed
% Ellipticity   Colony area to start growing seed
% 
% Author:
%     Taoran Fu @2021
%
% References:
%     Fu, T. (n.d.). PIA. GitHub. from https://github.com/TaoranFu/PIA
%     Dirk-Jan Kroon (2024). Region Growing (https://www.mathworks.com/matlabcentral/fileexchange/19084-region-growing), 
%           MATLAB Central File Exchange. Retrieved February 19, 2024.

% ---------- sort out parameters ------------------
% Create an inputParser instance
p = inputParser;

% Define default values for the named parameters
defaultThickness = 0.4;
defaultInDir = "../example/04_segmentation";
defaultOutDir = "../example/05_calculation";
defaultCoord = "../example/02_crop and filter";
defaultRadius=16;
defaultEllipticity=1.1;

% Add named parameters and their default values
addParameter(p, "Thickness", defaultThickness, @isnumeric);
addParameter(p, "InDir", defaultInDir, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);
addParameter(p,"Coord", defaultCoord, @isstring);
addParameter(p, "Radius", defaultRadius, @isnumeric);
addParameter(p, "Ellipticity", defaultEllipticity, @isnumeric);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
Thickness = p.Results.Thickness;
InDir = p.Results.InDir;
OutDir = p.Results.OutDir;
Coord=p.Results.Coord;
Radius= p.Results.Radius;
Ellipticity= p.Results.Ellipticity;

% Display the results or further processing
fprintf("Thickness to calculate volume: %s\n", Thickness);
fprintf("Input directory: %s\n", InDir);
fprintf("Output directory: %s\n", OutDir);
fprintf("Coordinates read from directory: %s\n", Coord);
fprintf("Colony area radius: %0.0f\n", Radius);
fprintf("Colony area ellipticity: %f\n", Ellipticity);
% ----------- parameters sorted out --------------

namelist = dir(fullfile(InDir,"*.png"));
file = {namelist.name};

% Load circle centers data
load(fullfile(Coord,'cropped_focus_area_y.txt'));
load(fullfile(Coord,'cropped_focus_area_x.txt'));

platen = 1; % plate start from
resulttable = table();

for file0 = file
    X=char(file0);
    [result data1] = fmultiselect(InDir, file0, platen,...
       cropped_focus_area_x,cropped_focus_area_y,Radius,Ellipticity, Thickness, OutDir);
    platen = platen+1;
    resulttable = [resulttable;data1];
end
resulttable. Properties. VariableNames = ["Run","Plate","Row.Label","Col","Size","Brightness","TotalBrightness","TotalVolume","Avg.Red","Avg.Blue","Avg.Green"];
writetable(resulttable,strcat(OutDir,'/Result.txt'),'Delimiter','\t');
end

% -------------- function: fmultiselect --------------
function [result,data1] = fmultiselect(InDir, file0,platen,p_x,p_y,radius,e, Thickness, OutDir) % I is not the full address; I2 is char
I = fullfile(InDir, file0)
fprintf("Processing %s\n", I);
I2 = char(fullfile(InDir, file0));

x=imread(I2); %parameters initialization
par= 0.5; % 0.5 then more than 4 mins for one plate????
[length,wide,rgb]=size(x);

A = table(); % Output merged table
well = [];
well=x; % To show the circle area
well_x = double(x); % Double format of the original picture
c=0 ;% Count
well_read = zeros(size(x)); % read the area into the circle
well_growth_new = zeros(length,wide);% Growth output by one well
well_growth = zeros(length,wide); % Growth result
rown = ['A','B','C','D','E','F','G','H'];
a =0 ; % count for row value
for c = 1:96 % process per well
    a = fix((c-1)/12)+1;
    i=p_x(c);
    j=p_y(c) ;

        [well] = fdrawcircle(I2,p_x,p_y,radius,e);

        well_read_new = zeros(length,wide);
        % Read circle area with ~35 pixels radius
        for a1 = round((i-35:1:i+35)) % process resolution = 35?
            for b1 = round((j-35:1:j+35))
                if ((a1-i)^2+(b1-j)^2/(e)^2) < (radius^2)
                    a1 = max(1,a1);
                    b1 = max(1,b1);
                    a1 = min(a1,size(well_read,1));
                    b1 = min(b1,size(well_read,2));
                    well_read(a1,b1,1) = x(a1,b1,1);
                    well_read(a1,b1,2) = x(a1,b1,2);
                    well_read(a1,b1,3) = x(a1,b1,3);
                    well_read_new(a1,b1,1) = x(a1,b1,1);
                    well_read_new(a1,b1,2) = x(a1,b1,2);
                    well_read_new(a1,b1,3) = x(a1,b1,3);
                end
            end
        end

        % Determine if null
        well_null(c) = nnz(well_read_new);

        % Growth
        well_growth_new = zeros(length,wide);
        if well_null(c) > 0


            % Growth
            % !!To be faster: minus the well_read to avoid growth being repeating the
            % contents inside the circle!!
            for aplha=0:pi/40:2*pi
                r=radius;
                xr=round(r*cos(aplha));
                yr=round(e*r*sin(aplha));
                if mod(xr,2)==1
                    continue
                end
                if mod(yr,2)==1
                    continue
                end
                if well_growth_new(min(max(round(i+xr),1),size(well_growth_new,1)),min(max(round(j+yr),1),size(well_growth_new,2))) == 0 &&...
                        x(min(max(round(i+xr),1),size(x,1)),min(max(round(j+yr),1),size(x,1))) >100
                    well_growth_new = max(well_growth_new,regiongrowing(im2double(x),round(i+xr),round(j+yr)));
                end
                well_growth = max(well_growth,well_growth_new);
            end
        end
        % Record the data of this well
        well_growthresult = well_growth_new.*well_x; % Get the growth data
        well_final = max(well_read_new,well_growthresult); % Get all the data
        Rowc(c) = rown(a);
        Colc(c) = rem(c-1+12,12)+1;
        Sizec(c) = sum(round(rgb2gray(well_final)),'all');
        well_final(find(well_final==0))=nan;
        Brightnessc(c) = mean(well_final(:,:,:),'all','omitnan'); % Do brigthness by mean
        TotalBrightnessc(c) = sum(well_final(:,:,:),'all','omitnan'); 
        TotalVolumec(c) = TotalBrightnessc(c) * Thickness;
        Avg.Redc(c) = round(mean(well_final(:,:,1),'all','omitnan'));
        Avg.Bluec(c) = round(mean(well_final(:,:,2),'all','omitnan') );
        Avg.Greenc(c) = round(mean(well_final(:,:,3),'all','omitnan') );
end

well_growthresult = well_growth.*well_x;
well_final = max(well_read,well_growthresult);


data1 = table(ones(96,1),ones(96,1)*platen,Rowc',Colc', Sizec',Brightnessc',TotalBrightnessc',TotalVolumec',Avg. Redc',Avg. Bluec',Avg. Greenc');
result = data1;
result. Properties. VariableNames = ["Run","Plate","Row.Label","Col","Size","Brightness","TotalBrightness","TotalVolume","Avg.Red","Avg.Blue","Avg.Green"];

[originpath, filename]= fileparts(I);
imwrite(well,strcat(OutDir,"/calculate_",filename,".png"));
writetable(result,strcat(OutDir,"/",filename,'.txt'),'Delimiter','\t');

end

function [J Sum]=regiongrowing(I,x,y,reg_maxdist)
% This function performs "region growing" in an image from a specified
% seedpoint (x,y)
%
% J = regiongrowing(I,x,y,t) 
% 
% I : input image 
% J : logical output image of region
% x,y : the position of the seedpoint (if not given uses function getpts)
% t : maximum intensity distance (defaults to 0.2)
%
% The region is iteratively grown by comparing all unallocated neighbouring pixels to the region. 
% The difference between a pixel's intensity value and the region's mean, 
% is used as a measure of similarity. The pixel with the smallest difference 
% measured this way is allocated to the respective region. 
% This process stops when the intensity difference between region mean and
% new pixel become larger than a certain treshold (t)
%
% Example:
%
% I = im2double(imread('medtest.png'));
% x=198; y=359;
% J = regiongrowing(I,x,y,0.2); 
% figure, imshow(I+J);
%
% Author: D. Kroon, University of Twente

if(exist('reg_maxdist','var')==0), reg_maxdist=0.2; end
if(exist('y','var')==0), figure, imshow(I,[]); [y,x]=getpts; y=round(y(1)); x=round(x(1)); end

J = zeros(size(I)); % Output 
Isizes = size(I); % Dimensions of input image

reg_mean = I(x,y); % The mean of the segmented region
reg_size = 1; % Number of pixels in region

% Free memory to store neighbours of the (segmented) region
neg_free = 10000; neg_pos=0;
neg_list = zeros(neg_free,3); 

pixdist=0; % Distance of the region newest pixel to the regio mean

% Neighbor locations (footprint)
neigb=[-1 0; 1 0; 0 -1;0 1];

% Start regiogrowing until distance between regio and posible new pixels become
% higher than a certain treshold
while(pixdist<reg_maxdist&&reg_size<numel(I))

    % Add new neighbors pixels
    for j=1:4,
        % Calculate the neighbour coordinate
        xn = x +neigb(j,1); yn = y +neigb(j,2);
        
        % Check if neighbour is inside or outside the image
        ins=(xn>=1)&&(yn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2));
        
        % Add neighbor if inside and not already part of the segmented area
        if(ins&&(J(xn,yn)==0)) 
                neg_pos = neg_pos+1;
                neg_list(neg_pos,:) = [xn yn I(xn,yn)]; J(xn,yn)=1;
        end
    end

    % Add a new block of free memory
    if(neg_pos+10>neg_free), neg_free=neg_free+10000; neg_list((neg_pos+1):neg_free,:)=0; end
    
    % Add pixel with intensity nearest to the mean of the region, to the region
    dist = abs(neg_list(1:neg_pos,3)-reg_mean);
    [pixdist, index] = min(dist);
    J(x,y)=2; reg_size=reg_size+1;
    
    % Calculate the new mean of the region
    reg_mean= (reg_mean*reg_size + neg_list(index,3))/(reg_size+1);
    
    % Save the x and y coordinates of the pixel (for the neighbour add proccess)
    x = neg_list(index,1); y = neg_list(index,2);
    
    % Remove the pixel from the neighbour (check) list
    neg_list(index,:)=neg_list(neg_pos,:); neg_pos=neg_pos-1;
end

% Return the segmented area as logical matrix
J=J>1;
Sum = neg_pos;
end

