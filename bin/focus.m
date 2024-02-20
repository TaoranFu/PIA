function focus(varargin)
%FOCUS Pick the actual working area using interactive window
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     focus("Image","../example/01_background correction/bgcorrection_Run-1-Plate-001 - Original.png","OutDir","../example/02_crop and filter")
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
defaultImage = "../example/01_background correction/bgcorrection_Run-1-Plate-001 - Original.png";
defaultOutDir = "../example/02_crop and filter";

% Add named parameters and their default values
addParameter(p, "Image", defaultImage, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
Image = p.Results.Image;
OutDir = p.Results.OutDir;

% Display the results or further processing
fprintf("Pick focus area from image: %s\n", Image);
fprintf("Focus area recorded directory: %s\n", OutDir);
% ----------- parameters sorted out --------------

% Add picture to select 3 points
K = imread(Image);
imshow(K);
multicenters0 = ginput(4); % Select the center of A1, A12, H1 and H12 in order

% write focus area into a new file: 
writematrix(multicenters0, fullfile(OutDir,'focus_area_corners.txt'),'Delimiter','\t');

% Debug for same x or y of the picked points
if (multicenters0(1,2)-multicenters0(2,2)) ==0
    multicenters0(1,2) = multicenters0(1,2)+ 0.0001
end
if (multicenters0(2,1)-multicenters0(4,1)) ==0
    multicenters0(2,1) = multicenters0(2,1)+ 0.0001
end
if (multicenters0(1,1)-multicenters0(3,1)) ==0
    multicenters0(1,1) = multicenters0(1,1)+ 0.0001
end
if (multicenters0(3,2)-multicenters0(4,2)) ==0
    multicenters0(3,2) = multicenters0(4,2)+ 0.0001
end

% writetable for all the circle centers
p_y0=round(multicenters0(1,1)+... % X2
    repmat(0:1/7:1,1,12).*repmat((multicenters0(4,1)-multicenters0(2,1))/7*fix((0:95)/12),1,1)+... % x1
    repmat(1:-1/7:0,1,12).*repmat((multicenters0(3,1)-multicenters0(1,1))/7*fix((0:95)/12),1,1)+... % x1
    repmat(0:(multicenters0(4,1)-multicenters0(3,1))/11:(multicenters0(4,1)-multicenters0(3,1)),1,8)); % value of x axis for each centrial point
p_x0=round(multicenters0(1,2)+...
    repmat(0:1/11:1,1,8).*repmat(0:(multicenters0(4,2)-multicenters0(3,2))/11:(multicenters0(4,2)-multicenters0(3,2)),1,8)+...
    repmat(1:-1/11:0,1,8).*repmat(0:(multicenters0(2,2)-multicenters0(1,2))/11:(multicenters0(2,2)-multicenters0(1,2)),1,8)+...
    repelem(0:(multicenters0(4,2)-multicenters0(2,2))/7:(multicenters0(4,2)-multicenters0(2,2)),12));
writematrix(p_y0, fullfile(OutDir,'focus_area_y0.txt'),'Delimiter','\t');
writematrix(p_x0, fullfile(OutDir,'focus_area_x0.txt'),'Delimiter','\t');
end
