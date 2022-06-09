Real raw phenobooth+ images: 'Raw0'
Real output folder: 'Output'
	- Result.txt for all the data
	- Visualization.pdf for a rough visualisation of data

Step	Function	Action&explanation	Input&Output folder
Step 0.0	'Improvement.m' for creating gray images adjusted with biased light. 	'Raw0/'-->'Raw/'
Step 0.1	Pick the focus area.	Run 'pickpoint.m' to select the colony centers at 4 corners.	Images of plate 1, 2 and 3-->'multicentes0.txt','p_x0.txt','p_y0.txt'
Step 1	Crop and do threshold.	Run 'cropnthr_old.m',then'cropnthr.m',use template 'for batch' OR 'for selecting A1'.	'Raw/'-->'Cropped/'
Step 2	Pre-processing images.	Run 'deleteline.m' to delete the strong light noise at the top and bottom part on the images; and run 'deletepoint.m' to do the segmentation by adding black lines to avoid growth toward overlapping colonies.	'Cropped/'-->'Input/'
Step 3	Sum the colonies size.	Run 'Main_function.m' to read circle areas and do seeded region growth.	'Input/'-->'Output/'
Step 4	Check output files in 'Output/'

Step 5	Run Scr.R in Visualization.Rproj