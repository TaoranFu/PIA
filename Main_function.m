% clc
% clear
% close all
namelist = dir('Input/*.png');

file = {namelist.name};
platen = 1 % plate start from
load('p_x.txt')
load('p_y.txt')
resulttable = table();
for file0 = file
    X=char(file0)
    platen
    [result data1] = fmultiselect(X,platen,...
       p_x,p_y,16,1.1);
    platen = platen+1;
    resulttable = [resulttable;data1];
end
resulttable. Properties. VariableNames = ["Run","Plate","Row.Label","Col","Size","Brightness","Avg.Red","Avg.Blue","Avg.Green"];
writetable(resulttable,'Output/Result.txt','Delimiter','\t')
