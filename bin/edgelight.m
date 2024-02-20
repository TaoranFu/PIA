function edgelight(varargin)
%EDGELIGHT
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     edgelight("InDir",""../example/02_crop and filter", "OutDir",""../example/03_edge light correction",
%               "Thichness", 17, "Radius", 10, "Ellipticity", 1.1, "Height", 50)
% 
% "Thichness"       Light thickness to correct
% "Height"            The maximum distance from the upper and lower edges of a bright light
% "Radius"            Colony area to rescue from strong light correction
% "Ellipticity"         Colony area to rescue from strong light correction
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
defaultInDir = "../example/02_crop and filter";
defaultOutDir = "../example/03_edge light correction";
defaultThickness = 17;
defaultRadius=10;
defaultEllipticity=1.1;
defaultHeight=50;

% Define default values for the named parameters
addParameter(p, "InDir", defaultInDir, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);
addParameter(p, "Thickness", defaultThickness , @isnumeric);
addParameter(p, "Radius", defaultRadius, @isnumeric);
addParameter(p, "Ellipticity", defaultEllipticity, @isnumeric);
addParameter(p, "Height", defaultHeight, @isnumeric);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
InDir= p.Results.InDir;
OutDir= p.Results.OutDir;
Thickness= p.Results.Thickness;
Radius= p.Results.Radius;
Ellipticity= p.Results.Ellipticity;
Height= p.Results.Height;

% Display the results or further processing
fprintf("Input directory: %s\n", InDir);
fprintf("Output directory: %s\n", OutDir);
fprintf("Light maximum thickness: %0.0f\n", Thickness);
fprintf("Light maximum detecting at top and bottom edge: %0.0f\n", Height);
fprintf("Rescue colony area radius: %0.0f\n", Radius);
fprintf("Rescue colony area ellipticity: %f\n", Ellipticity);

% ----------- parameters sorted out --------------

filelist = dir(fullfile(InDir,'*.png'));

load(fullfile(InDir,'cropped_focus_area_y.txt'));
load(fullfile(InDir,'cropped_focus_area_x.txt'));

        
for f = 1:length(filelist)
    I = imread(fullfile(InDir,filelist(f).name));
    %imshow(I)
    I2 = I; % Create an image for output
    
    % To gray
    Igray = rgb2gray(I);

    % then do a delete line thiner than 10 pxs
    [a b] = size(Igray);
    im{1} = imcrop(Igray,[0,0,b,Height]);
    im{2} = imcrop(Igray,[0,a-Height,b,a]);
    
    % Do correct noise lines
    for i = 1:2
        for c = 1:size(im{i},2) % for each column of the image
            r = 0;
            
            % for bottom part if it is a bright starting pixel
            % find the first dark point
            while i ==2 && im{i}(r+1,c)>0 && r < Height
                r = r+1;
            end
 
            while r < Height
                r = r+1;
                valuer = im{i}(r,c);
                    if valuer > 0 % if bright
                        rend = r; %int
                        valuerend = im{i}(rend,c); %int
                        % Try to find the end of it    
                        while rend < Height
                                rend = rend +1;
                                valuerend = im{i}(rend,c); %int
                                % when the bright line stops or 
                                % it is finished at bottom
                                if valuerend == 0 || (rend == Height && valuerend>0 && i==2)
                                    rlength = rend-r; 
                                    if rlength <= Thickness && rlength > 0
%                                         disp(c)
                                        for rn = r:rend
                                            im{i}(rn,c)=0;
                                            I2((i-1)*(a-Height-1)+rn,c,:)=0; % Do with a copy of the rgb image to save output
                                        end
                                    end 
                                r = rend;
                                break   
                                end
                            end
                    end
            end
    
        end

    end

    % Read circle
    for cy = 1:96 
    a = fix((cy-1)/12)+1;
    i=cropped_focus_area_x(cy);
    j=cropped_focus_area_y(cy) ;

    [well] = fdrawcircle(fullfile(InDir,filelist(f).name),cropped_focus_area_x,cropped_focus_area_y,Radius,Ellipticity);

    % we need the first row to bit slightly lower to avoid inlcuding noise
    
    if cy <= 12 
        i = i+2;
    end
    
    for a1 = round((i-20:1:i+20) )
            for b1 = round((j-20:1:j+20))
                if ((a1-i)^2+(b1-j)^2/(Ellipticity)^2) < (Radius^2)
                    I2(a1,b1,1) = I(a1,b1,1);
                    I2(a1,b1,2) = I(a1,b1,2);
                    I2(a1,b1,3) = I(a1,b1,3);
                end
            end
    end
    end
        
    imwrite(I2,fullfile(OutDir, strcat("edgelight",filelist(f).name)));
end

% function end
end



