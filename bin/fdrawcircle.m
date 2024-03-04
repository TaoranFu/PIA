%--------------- fdrawcircle ------------------
function [well] = fdrawcircle(I,p_x,p_y,radius,e) % I should be the full path

I2 = char(strcat(string(I))); % Read image name
x=imread(I2); % read image

[length,wide,rgb]=size(x);
% e = 1.1; % Ellipse eccentricity

well = [];
well=x; % To show the circle area

    for c = 1:96 
        ii=round(p_x(c));
        jj=round(p_y(c));

        % Draw central point
        well(ii,jj,1)=255;
        well(ii,jj,2)=0;
        well(ii,jj,3)=0;
        
        % Draw circle
        for aplha=0:pi/40:2*pi
            r=radius;
            xr=round(r*cos(aplha));
            yr=round(e*r*sin(aplha));
            if ii+xr<=0
                ii=0;
                xr=1;
            end
            if jj+yr<=0
                jj=0;
                yr=1;
            end
            well(ii+xr,jj+yr,1)=255;
            well(ii+xr,jj+yr,2)=0;
            well(ii+xr,jj+yr,3)=0;
        end
    end
    imshow(well) % show image
    
end
