function [well] = fdrawcircle(I,p_x,p_y,radius,e) % I should be the full address

I2 = char(strcat(string(I))); % Read image name
x=imread(I2); % read image

[length,wide,rgb]=size(x);
% e = 1.1; % Ellipse eccentricity

well = [];
well=x; % To show the circle area

    for c = 1:96 
        i=p_x(c);
        j=p_y(c);

        % Draw central point
        well(i,j,1)=255;
        well(i,j,2)=0;
        well(i,j,3)=0;
        
        % Draw circle
        for aplha=0:pi/40:2*pi
            r=radius;
            xr=round(r*cos(aplha));
            yr=round(e*r*sin(aplha));
            well(i+xr,j+yr,1)=255;
            well(i+xr,j+yr,2)=0;
            well(i+xr,j+yr,3)=0;
        end
    end
    imshow(well) % show image
    
end
