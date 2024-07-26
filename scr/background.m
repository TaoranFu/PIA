function background(varargin)
%BACKGROUND Correct the background bias of images using a
%template image
% 
% Phenobooth Image Analysis Tool @version 2.0
% 
% Syntax:
%     background("B","../imcomplement_model.png","InDir", "../example/00_raw images","OutDir", "../example/01_background correction")
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
defaultB = "../imcomplement_model.png";
defaultInDir = "../example/00_raw images";
defaultOutDir = "../example/01_background correction";

% Add named parameters and their default values
addParameter(p, "B", defaultB, @isstring);
addParameter(p, "InDir", defaultInDir, @isstring);
addParameter(p, "OutDir", defaultOutDir, @isstring);

% Parse the inputs
parse(p, varargin{:});

% Extract the variable values
B = p.Results.B;
InDir = p.Results.InDir;
OutDir = p.Results.OutDir;

% Display the results or further processing
fprintf("Background image: %s\n", B);
fprintf("Input directory: %s\n", InDir);
fprintf("Output directory: %s\n", OutDir);

% ----------- parameters sorted out --------------

    K = imread(B);
    filelist = dir(fullfile(InDir, "*.png"));

    for i =1:length(filelist)
    Rproceed = ...
        imlincomb(1/2,rgb2gray(imread(fullfile(InDir,filelist(i).name))),...
        1/2,K);
    % Radjust = imadjust(Rproceed);
    Radjust = Rproceed;
    Rrgb(:,:,1) = Radjust;
    Rrgb(:,:,2) = Radjust;
    Rrgb(:,:,3) = Radjust;
    imwrite( Rrgb,...
        fullfile(OutDir,strcat("bgcorrection_",filelist(i).name)))
    end


