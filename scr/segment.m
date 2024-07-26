function segment(varargin)
%SEGMENT To segment colonies especially when they overlap with each other
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     segment("Mode","manual",
%             "InDir", "../example/03_edge light correction",
%             "OutDir","../example/04_segmentation"，
%             "Coord", "../example/02_crop and filter")
% 
% Mode      manual      Press anykey to process or "esc" to ckip; 
%                       hold click and drag to zoom in; 
%                       click to draw lines between clicks; 
%                       shift+click to save and exit this image
%           auto        WARNING TODO not working yet, segment as a 96 well plate
% InDir     Directory with images to process 
% OutDIr    Directory to save result
% Coord     Directory with the .txt file with coordinates of the colony centers
% Force     Override
%
%
% Author:
%     Taoran Fu @2021
%
% References:
%     Fu, T. (n.d.). PIA. GitHub. from https://github.com/TaoranFu/PIA
%

% ---------- sort out parameters ------------------
% Create an inputParser instance
p = inputParser;

% Define default values for the named parameters
defaultMode = "manual";
defaultInDir = "../example/03_edge light correction";
defaultOutDir = "../example/04_segmentation";
defaultCoord = "../example/02_crop and filter";

% Add named parameters and their default values
addParameter(p, "Mode", defaultMode, @isstring);
addParameter(p, "InDir", defaultInDir, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);
addParameter(p,"Coord", defaultCoord, @isstring);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
Mode = p.Results.Mode;
InDir = p.Results.InDir;
OutDir = p.Results.OutDir;
Coord=p.Results.Coord;

% Display the results or further processing
fprintf("Segment mode: %s\n", Mode);
fprintf("Segment running for images from directory: %s\n", InDir);
fprintf("Segment running saved to directory: %s\n", OutDir);
fprintf("Coordinates read from directory: %s\n", Coord);

% ----------- parameters sorted out --------------

mkdir(OutDir)

% Add the file name to the below command
namelistdelline = dir(fullfile(InDir,"*.png"));
filed = {namelistdelline.name};

% Load circle centers data
load(fullfile(Coord,'cropped_focus_area_y.txt'));
load(fullfile(Coord,'cropped_focus_area_x.txt'));

if Mode == "manual"
% Press 'esc' key to complete the process for one image
% Press any letter key to start zoom in and select a gap to segment 2
% overlap colonies
for file0 = filed
    fdeletepoint(fullfile(InDir, file0),cropped_focus_area_x,cropped_focus_area_y,16,1.1, OutDir);
    disp(file0)
end
end
end

% ---------- function: fdeletpoint----------
function [X_1] = fdeletepoint(I,p_x,p_y,radius,e, OutDir) % I is the full address
% global xn xn1 xn2 yn yn1 yn2 

scnsize = get(0,'ScreenSize'); %get screen size.

% I='Raw\Run-1-Plate-001 - Original - Processed.png';
% ncircle = 3;
close all;
X=imread(I);
X_1 = X; % Create a copy of the picture to record black lines and output
X_2 = fdrawcircle(I,p_x,p_y,radius,e); % X_2 is the picture with circles to display

imshow(X_2);
set(gcf,'position',[1,80,scnsize(3),scnsize(4)-160]);

[size1 size2 size3]=size(X_1);
key = 1;

% % Delete by manualy selecting lines
while 1
%     get(gcf,'CurrentCharacter')
    imshow(X_2);
    set(gcf,'position',[1,80,scnsize(3),scnsize(4)-160]);
    pause; % Press any letter key for continue; ESC for quit loop
    if  get(gcf,'CurrentCharacter')==char(27) % ESC quit loop
        break;
    end

    % show image and select lines
%     key = isletter(get(gcf,'currentcharacter'))
    [x,y] = getline_zoom(X_2,'plot'); % Zoom in to look and select in detail
%     x1=x;
%     y1=y;

    % Draw the line
    n=0;
    [a , ~]=size(x);
    for x1 = 1:a-1
        n = n+1;
        xx1 = x(n);
        yy1 = y(n);
        xx2 = x(n+1);
        yy2 = y(n+1);
        % set the point on the left as the (x0,y0)
       if  xx2 < xx1
           xx22 = xx2;
           xx2 = xx1;
           xx1 = xx22;
           yy22 = yy2;
           yy2 = yy1;
           yy1 = yy22;                  
       end
    lengthl = sqrt((xx1-xx2)^2+(yy1-yy2)^2);
    alpha = asin((yy2-yy1)/lengthl);
        for line = 0:0.3:(lengthl+1)
                xn=round(xx1+(line*cos(alpha)));
                yn=round(yy1+(line*sin(alpha)));
                xn1=floor(xx1+(line*cos(alpha)));
                yn1=floor(yy1+(line*sin(alpha)));
                xn2=ceil(xx1+(line*cos(alpha)));
                yn2=ceil(yy1+(line*sin(alpha)));
                if yn<=size1 && xn<=size2 && yn>0 && xn>0
                    X_1(yn,xn,:)=0; % (Row#/y, Col#/x, RGB#)
                    X_2(yn,xn,1)=155;
                end
                if yn1<=size1 && xn1<=size2 && yn1>0 && xn1>0
                    X_1(yn1,xn1,:)=0;
                    X_2(yn1,xn1,1)=155;
                end
                if yn2<=size1 && xn2<=size2 && yn2>0 && xn2>0
                    X_1(yn2,xn2,:)=0;
                    X_2(yn2,xn2,1)=155; 
                end
        end
    end
    close all;
    

end

% save result
I2 = char(I)
[temp, filename] = fileparts(I);
imwrite(X_1, fullfile(OutDir, strcat("segment_",filename, ".png")));
close all;

end




