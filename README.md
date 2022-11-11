## Wellcome_MIC data extraction method

Real raw phenobooth+ images: 'Raw0'
Real output folder: 'Output'
- Result.txt for all the data
- Visualization.pdf for a rough visualisation of data

## Matlab add-ons to set up in advance
- MACOPEN # to open matlab in macos terminal
- Image Processing Toolbox # image processing package
- Active Figure Zoom for Selection Points # to zoom and pick points in deletepoint.m

## Workflow (using macOS terminal with matlab R2022a and R)
# all '-' are for seperating steps, do not copy/paste onto terminal
# replace XXXX with your sample folder name
# image names have to be the default output format from phenobooth
# () is to define options, make sure copy/paste only the content within
# if your are working based on a cloud storage (e.g. Dropbox), make sure you have all resources working offline otherwise might cause empty scripts running
- cd ~/Dropbox\ \\(The\ University\ of\ Manchester\\)/WT-Evolution\ of\ antibiotic\ resistance/results/phenotypic\ assays/Data/MICs/ # go to MIC home directory
- mkdir XXXX/Raw0 # replace XXXX with the sample name, while space has to be '\ ', same to the following rows
- mv XXXX/*.png XXXX/Raw0 # replace XXXX with the sample name, -R for copying all the content in the folder
- cp -R QC/Template/ XXXX  # copy all files and folders in Template to the sample folder
- cd XXXX # go to sample folder to run Matlab scripts
- /Applications/MATLAB_R2022a.app/bin/matlab -nodesktop # launch Matlab within Terminal but can open editor by calling 'edit script.m'
- Improvement # run improvement to overlap blank plate image with sample images
- (pickpoint) # optionally choose the focus area by clicking on the 4 colony centers at the corner(topleft->topright->bottomleft->bottomright)
- cropnthr_old # run old crop with one value as threshold; parameter - thre,default is 104
- cropnthr # run2 other methods of threshold and crop the image, return images are saved in ./Cropped
- (press ctr+z) # pause the job
- open Cropped/*.png # check cropped and threshold images
- fg %1 # continue the work in the foreground
- (edit cropnthr_old.m # edit cropnthr_old.m and cropnthr.m and change values if images in ./Cropped are too dark)
- deleteline # erase the bright light noise at the top and bottom of the images, then check the saved images in ./Deleteline
- (edit deleteline.m # edit deleteline.m, change values of radius/h  if images in ./Deleteline still have light lines)
- (# type and run deletepoint.m but this script need the matlab desktop, alternatively, press ctr+z and run (cp -R Deleteline/ Input) to copy images to /Input folder to skip this step)
- fg %1
- Main_function # run the main function on extracting the size of the colony area
- quit # quit Matlab
- Rscript Scr.R # run r script to visualize the MIC data
- open Output/result_*.png # check input and output images if colony are well detected by matlab
- open Output/Visualization.pdf # then check the pdf in the ./Output folder for final check, see if abnormal in extremely high MIC strains
- cd .. # return back to the MICs directory
- open mic_add.r # open R script
- \# in row #14 change the sample name to the current runned one and press ctrl+s to save it
- quit # type in r to quit r
- rscript mic_add.r # run the mic process note
- open mic_checklist.csv # check if the current sample name is at the bottom
