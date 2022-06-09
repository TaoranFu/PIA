clc
clear all

% Add the file name to the below command
namelistdelline = dir('Deleteline/*.png');
filed = {namelistdelline.name};

% Load circle centers data
load('p_x.txt');
load('p_y.txt');

% Press 'esc' key to complete the process for one image
% Press any letter key to start zoom in and select a gap to segment 2
% overlap colonies
for file0 = filed
    fdeletepoint(strcat('Deleteline/',string(file0)),p_x,p_y,16,1.1);
    disp(file0)
end




