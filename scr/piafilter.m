function piafilter(varargin)
%PIAFILTER Crop out the focus area and filter out the background
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     piafilter("Mode","pick","FocusDir","../example/02_crop and filter/",
%             "InDir","../example/01_background correction","OutDir","../example/02_crop and filter",
%             "Rescue", "no","RescueValue", 0.75,
%             "FilterValue",104)
% 
% "Mode":
%     "pick"        pick 8 reference points-6 background points and 2 colony
%                   points from an interactive window for each image
%     "auto"        use edge detection to filter out the background - not
%                   available yet - TODO
%     "simple"      quantify a brightness value to filter out the background
%                   using the "FilterValue" flag
%
% "Rescue":
%     Only accept "yes" or "no" as input
%     "RescueValue" defines the fudgeFactor value in edge detection for rescuing dark, hight contract colonies,
%     with a default value as 0.75
% 
% Author:
%     Taoran Fu @2021
%
% References:
%     Fu, T. (n.d.). PIA. GitHub. from https://github.com/TaoranFu/PIA
%     https://uk.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html
%

% ---------- sort out parameters ------------------
% Create an inputParser instance
p = inputParser;

% Define default values for the named parameters
defaultMode = "simple";
defaultFocusDir = "../example/02_crop and filter/";
defaultInDir = "../example/01_background correction";
defaultOutDir = "../example/02_crop and filter";
defaultRescue = "no";
defaultFilterValue = 105;
defaultRescueValue = 0.75;

% Add named parameters and their default values
addParameter(p, "Mode", defaultMode, @isstring);
addParameter(p, "FocusDir", defaultFocusDir, @isstring);
addParameter(p, "InDir", defaultInDir, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);
addParameter(p, "Rescue", defaultRescue, @isstring);
addParameter(p, "FilterValue", defaultFilterValue, @isnumeric);
addParameter(p, "RescueValue", defaultRescueValue, @isnumeric);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
Mode = p.Results.Mode;
FocusDir = p.Results.FocusDir;
InDir = p.Results.InDir;
OutDir = p.Results.OutDir;
Rescue = p.Results.Rescue;
FilterValue = p.Results.FilterValue;
RescueValue = p.Results.RescueValue;

% Display the results or further processing
fprintf("Filter mode: %s\n", Mode);
fprintf("Focus area recored in: %s\n", FocusDir);
fprintf("Input directory: %s\n", InDir);
fprintf("Output directory: %s\n", OutDir);
fprintf("Rescue? %s\n", Rescue);
if Mode == "simple"
    fprintf("Filter value: %0.0f\n", FilterValue);
end
% ----------- parameters sorted out --------------

% Load colony centers
load(fullfile(FocusDir,'focus_area_corners.txt'));
load(fullfile(FocusDir,'focus_area_y0.txt'));
load(fullfile(FocusDir,'focus_area_x0.txt'));

% Crop parameters set up
yedge = (max(focus_area_corners(1:4,1)) - min(focus_area_corners(1:4,1)))/12/2;
xedge = (max(focus_area_corners(1:4,2)) - min(focus_area_corners(1:4,2)))/8/2;
a = focus_area_y0(1,1)-yedge;
b = focus_area_x0(1,1)-xedge;
c = focus_area_y0(1,96)-focus_area_y0(1,1)+2*yedge;
d = focus_area_x0(1,96)-focus_area_x0(1,1)+2*xedge;

% Save circle centers for cropping images
focus_area_corners1(:,1) = focus_area_corners(:,1) - focus_area_corners(1,1)+yedge;
focus_area_corners1(:,2) = focus_area_corners(:,2) - focus_area_corners(1,2)+xedge;
p_y = focus_area_y0-focus_area_y0(1,1)+yedge;
p_x = focus_area_x0-focus_area_x0(1,1)+xedge;
writematrix(focus_area_corners1,fullfile(OutDir,'cropped_focus_area_corners.txt'),'Delimiter','\t');
writematrix(p_y,fullfile(OutDir,'cropped_focus_area_y.txt'),'Delimiter','\t');
writematrix(p_x,fullfile(OutDir,'cropped_focus_area_x.txt'),'Delimiter','\t');

% Do the batch
filelist = dir(fullfile(InDir, "*.png"));


for i = 1:length(filelist)
        I = imread(fullfile(InDir,filelist(i).name));
        
        
        % ----------- Manually picked --------------
        if Mode == "pick"
            % Pick reference points
            imshow(I) % open image
            refpts = ginput(8) % pick 8 reference points: 6 brightest background points and 2 darkest colony points
            brt = [0 0 0 0 0 0 0 0]
            for n = (1:8) % save the brightness of selected points
                brt(n) = I(round(refpts(n,2)),round(refpts(n,1)));
            end

            % Crop image
            Icropped = imcrop(I,[a b c d]);

            % grow the background
            Igray = im2gray(Icropped);

            % Create mask
            maskedRGBImage = Icropped;
            % threshold based on picked points

            % if the background is darker than colonies, set thr to max brt(1:6)
            if max(brt(1:6)) < min(brt(7:8))  
                threvalues = max(brt(1:6))+1;
            end
            % if background is brighter than dark colonies, set thr to mean(brt)
            if max(brt(1:6)) >= min(brt(7:8)) 
                threvalues = mean(max(brt(1:6))+min(brt(7:8))); 
            end
            BW = Igray >= threvalues;
        end
        % --------- Manually picked end ------------


        % ----------- Simple mode --------------
        if Mode == "simple"
            % Crop image
            Icropped = imcrop(I,[a b c d]);

            % Create mask
            maskedRGBImage = Icropped;
            Igray = rgb2gray(Icropped);
            BW = Igray >= FilterValue;

        end
        % --------- Simple mode end ------------

        % --------- Rescue ------------
        if Rescue == "yes"
        % Rescue features with a high contrast edge
        % https://uk.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html
        % default LES58 plate 3 for determining method

        % detect the edge
        [~,threshold] = edge(Igray,'sobel');
        fudgeFactor = RescueValue;
        BWs = edge(Igray,'sobel', threshold * fudgeFactor);
        imshow(BWs)

        se90 = strel('line',3,90);
        se0 = strel('line',3,0);

        BWsdil = imdilate(BWs,[se90 se0]);
        imshow(BWsdil)

        % fill the holes
        BWdfill = imfill(BWsdil,'holes');
        imshow(BWdfill)

        % clean the border - ignore - this doesn't work properly
        % BWnobord = imclearborder(BWdfill,1); 
        BWnobord = BWdfill;

        % smooth the object
        seD = strel('diamond',1);
        BWfinal = imerode(BWnobord,seD);
        BWfinal = imerode(BWfinal,seD);

        Rescueedge = Igray;
        Rescueedge(repmat(~BWfinal,[1 1 1])) = 0;
        BWmax = max(BW,BWfinal);
        
        else % if Rescur == "no"
        BWmax = BW;
        end

        % ----------- Save results-- ------------
        % Set background pixels where BW is false to zero.
        maskedRGBImage(repmat(~BWmax,[1 1 3])) = 0;

        % Output cropped images
        imwrite(maskedRGBImage, fullfile(OutDir,strcat("filtered_",filelist(i).name)));
end

% function end
end
