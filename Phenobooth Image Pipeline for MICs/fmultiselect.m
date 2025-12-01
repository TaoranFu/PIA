function [result,data1] = fmultiselect(I,platen,p_x,p_y,radius,e) % I is not the full address; I2 is char
%FMULTISELECT 此处显示有关此函数的摘要
%   此处显示详细说明
% function [result] = Copy_of_multiselect(I,platen,multicenters,radius)
% ,par can be add as threshold
% clc
% clear
I2 = char(strcat('Input/',string(I)));
% To output raw0 image in the result.png for good compare
I0 = imread(char(strcat('Raw0/',string(I(1:(end-4))),' - Original.png')));
load('multicenters0.txt');
load('p_x0.txt');
load('p_y0.txt');
x=imread(I2); %parameters initialization
% x=imread('Run-1-Plate-002.Processed.png');
par= 0.5; % 0.5 then more than 4 mins for one plate
% platen =1;
[length,wide,rgb]=size(x);
% e = 1.1; % Ellipse eccentricity
% radius = 16

% Crop the raw0 image
yedge = 40;
xedge = 30;
a = p_y0(1,1)-yedge;
b = p_x0(1,1)-xedge;
c = p_y0(1,96)-p_y0(1,1)+2*yedge;
d = p_x0(1,96)-p_x0(1,1)+2*xedge;
I0cropped = imcrop(I0,[a b c d]);

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
for c = 1:96
    a = fix((c-1)/12)+1;
    i=p_x(c);
    j=p_y(c) ;

%         % Draw central point

%         well(i,j,1)=255;
%         well(i,j,2)=0;
%         well(i,j,3)=0;
%
%         % Draw circle
%         for aplha=0:pi/40:2*pi
%             r=radius;
%             xr=round(r*cos(aplha));
%             yr=round(e*r*sin(aplha));
%             well(i+xr,j+yr,1)=255;
%             well(i+xr,j+yr,2)=0;
%             well(i+xr,j+yr,3)=0;
%         end
        [well] = fdrawcircle(I2,p_x,p_y,radius,e);

        well_read_new = zeros(length,wide);
        % Read circle
        for a1 = (i-35:1:i+35)
            for b1 = (j-35:1:j+35)
                if ((a1-i)^2+(b1-j)^2/(e)^2) < (radius^2)
%                 if norm([a1,b1]-[i,j])<radius
                    well_read(a1,b1,1) = x(a1,b1,1);
                    well_read(a1,b1,2) = x(a1,b1,2);
                    well_read(a1,b1,3) = x(a1,b1,3);
                    well_read_new(a1,b1,1) = x(a1,b1,1);
                    well_read_new(a1,b1,2) = x(a1,b1,2);
                    well_read_new(a1,b1,3) = x(a1,b1,3);
                end
            end
        end
%         disp('well_read done')
        % Read circle (old)
%         for r=1:0.2:radius
%             for aplha=0:pi/40:2*pi
%                 xr=round(r*cos(aplha));
%                 yr=round(r*sin(aplha));
%                 well_read(i+xr,j+yr,1) = x(i+xr,j+yr,1);
%                 well_read(i+xr,j+yr,2) = x(i+xr,j+yr,2);
%                 well_read(i+xr,j+yr,3) = x(i+xr,j+yr,3);
%                 well_read_new(i+xr,j+yr,1) = x(i+xr,j+yr,1);
%                 well_read_new(i+xr,j+yr,2) = x(i+xr,j+yr,2);
%                 well_read_new(i+xr,j+yr,3) = x(i+xr,j+yr,3);
%             end
%         end
        % Determine if null
        well_null(c) = nnz(well_read_new);

        % Growth
        well_growth_new = zeros(length,wide);
        if well_null(c) > 0
            % old circle
%             well_read_new

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
    %             well(i+xr,j+yr,1)=255;
                if well_growth_new(i+xr,j+yr) == 0 && x(i+xr,j+yr) >100
                    well_growth_new = max(well_growth_new,regiongrowing(im2double(x),i+xr,j+yr));
%                   imshow(well_growth);
%                 pause
                end
                well_growth = max(well_growth,well_growth_new);
            end
%         disp('growth done')
        end
        % Record the data of this well
        well_growthresult = well_growth_new.*well_x; % Get the growth data
        well_final = max(well_read_new,well_growthresult); % Get all the data
        Rowc(c) = rown(a);
        Colc(c) = rem(c-1+12,12)+1;
        Sizec(c) = sum(round(rgb2gray(well_final)),'all');
        well_final(find(well_final==0))=nan;
        Brightnessc(c) = mean(well_final(:,:,:),'all','omitnan'); % Do brigthness by mean
        Avg.Redc(c) = round(mean(well_final(:,:,1),'all','omitnan'));
        Avg.Bluec(c) = round(mean(well_final(:,:,2),'all','omitnan') );
        Avg.Greenc(c) = round(mean(well_final(:,:,3),'all','omitnan') );
    end
%     end

well_growthresult = well_growth.*well_x;
well_final = max(well_read,well_growthresult);
% well_final = well_filter.*well_x;
% aplha=0:pi/40:2*pi;
% r=10;
% xr=round(r*cos(aplha));
% yr=round(r*sin(aplha));
% figure(2)
% plot(xr,yr,'.');
% axis equal


% figure(1)
% imshow(well)
%
% figure(2)
% imshow(well_read)
%
% figure(3)
% imshow(well_growth_new)
%
% figure(4)
% imshow(well_final/256)

% Output table
% data1 = {}
data1 = table(ones(96,1),ones(96,1)*platen,Rowc',Colc', Sizec',Brightnessc',Avg. Redc',Avg. Bluec',Avg. Greenc');
result = data1;
result. Properties. VariableNames = ["Run","Plate","Row.Label","Col","Size","Brightness","Avg.Red","Avg.Blue","Avg.Green"];
% R = cell2table(result);
% dlmwrite('myfile.txt', result, 'delimiter', '\t');
% figure(5)
% imshow(im2unit8(well_final))
% imwrite(well_final,N);
imwrite(well,strcat('Output/grouthseed_',I));
imwrite([I0cropped,uint8(well_final)],strcat('Output/result_',I));
writetable(result,strcat('Output/Result_',string(I(1:(strlength(I)-4))),'.txt'),'Delimiter','\t');
% end






end
