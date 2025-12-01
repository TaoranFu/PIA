clc
clear all

namelistcrop = dir('Cropped/*.png');
filer = {namelistcrop.name};

load('p_x.txt');
load('p_y.txt');

thickness = 17; % thickness of noise line to delete
radius = 10; % radius for circle reads
e = 1.1; % e for circle reads
h=50;  % height of picture for delete noise
        
for file0 = filer(1:end)
    I = imread(strcat('Cropped/',string(file0)));
    % I = imread('Cropped/Run-1-Plate-001.png');
    imshow(I)
    I2 = I; % Create an image for output
    
    % d = drawline;
    % pos = d.Position;
    % diffPos = diff(pos);
    % diameter = hypot(diffPos(1),diffPos(2)) % which is 8.0449
    
    % To gray
    Igray = rgb2gray(I);

    % then do a delete line thiner than 10 pxs
    [a b] = size(Igray);
    im{1} = imcrop(Igray,[0,0,b,h]);
    im{2} = imcrop(Igray,[0,a-h,b,a]);
    
    % Do delete noise lines
    for i = 1:2
        for c = 1:size(im{i},2) % for each column of the image
            r = 0;
            
            % for bottom part if it is a bright starting pixel
            % find the first dark point
            while i ==2 && im{i}(r+1,c)>0 && r < h
                r = r+1;
            end
 
            while r < h
                r = r+1;
                valuer = im{i}(r,c);
                    if valuer > 0 % if bright
                        rend = r; %int
                        valuerend = im{i}(rend,c); %int
                        % Try to find the end of it    
                        while rend < h
                                rend = rend +1;
                                valuerend = im{i}(rend,c); %int
                                % when the bright line stops or 
                                % it is finished at bottom
                                if valuerend == 0 || (rend == h && valuerend>0 && i==2)
                                    rlength = rend-r; 
                                    if rlength <= thickness && rlength > 0
%                                         disp(c)
                                        for rn = r:rend
                                            im{i}(rn,c)=0;
                                            I2((i-1)*(a-h-1)+rn,c,:)=0; % Do with a copy of the rgb image to save output
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
    i=p_x(cy);
    j=p_y(cy) ;

    [well] = fdrawcircle(strcat('Cropped/',string(file0)),p_x,p_y,radius,e);

    % we need the first row to bit slightly lower to avoid inlcuding noise
    
    if cy <= 12 
        i = i+2;
    end
    
    for a1 = (i-20:1:i+20)   
            for b1 = (j-20:1:j+20)
                if ((a1-i)^2+(b1-j)^2/(e)^2) < (radius^2)
                    I2(a1,b1,1) = I(a1,b1,1);
                    I2(a1,b1,2) = I(a1,b1,2);
                    I2(a1,b1,3) = I(a1,b1,3);
                end
            end
    end
    end
        
    
%     figure(2)
%     imshow(im{1})
%     figure(3)
%     imshow(I2)
    namex = char(file0)
    imwrite(I2,strcat('Deleteline/',string(namex(1:15)),'.png'))
end
