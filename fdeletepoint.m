% % !!ATTENTION!! NEED 'Active Figure Zoom for Selecting Points'

function [X_1] = fdeletepoint(I,p_x,p_y,radius,e) % I is the full address
% global xn xn1 xn2 yn yn1 yn2 

scnsize = get(0,'ScreenSize'); %get screen size.

% I='Raw\Run-1-Plate-001 - Original - Processed.png';
% ncircle = 3;
close all;
X=imread(I);
X_1 = X; % Create a copy of the picture to record black lines and output
X_2 = fdrawcircle(I,p_x,p_y,radius,e); % X_2 is the picture with circles to display

imshow(X_2)
set(gcf,'position',[1,80,scnsize(3),scnsize(4)-160])

[size1 size2 size3]=size(X_1)
key = 1

% % Delete by manualy selecting lines
while 1
%     get(gcf,'CurrentCharacter')
    imshow(X_2)
    set(gcf,'position',[1,80,scnsize(3),scnsize(4)-160])
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
%     imshow(X_2)
%     imshow(rgb2gray(X_2))
%     pause
%     [x,y] = getline_zoom(X_2,'plot') 
%     pause
    close all;
    

end
% imshow(X_1);
I2 = char(I)
imwrite(X_1, strcat('Input/',string(I2(12:26)),'.png'));
% disp(strcat('write',string(I2(5:19))))
close all;

end

