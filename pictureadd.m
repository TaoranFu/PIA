% X1 = imread('Run-1-Plate-001 - Original - Processed.png');
X2 = imread('Raw/Run-1-Plate-001 - Original.png');
X3 = imread('Raw/Run-1-Plate-002 - Original.png');
K = imlincomb(1/2,X2,1/2,X3);
% subplot(1,4,1),subimage(X1);
% title('原始图像1');
% subplot(1,4,2),subimage(X2);
% title('原始图像2');
% subplot(1,4,3),subimage(X3);
% title('原始图像3');
% subplot(1,4,4),
imshow(K);
% title('0.5X图像1+0.5X图像2');
