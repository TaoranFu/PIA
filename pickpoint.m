clc;
clear;
close all;

% Add picture to select 3 points
pictureadd
multicenters0 = ginput(4); % Select the center of A1, A12, H1 and H12 in order

% writetable(multicenters,'multicenters.txt','Delimiter','\t');
writematrix(multicenters0,'multicenters0.txt','Delimiter','\t');

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
writematrix(p_y0,'p_y0.txt','Delimiter','\t');
writematrix(p_x0,'p_x0.txt','Delimiter','\t');

