
## Phenobooth Image Analysis PIA 2.0
This is a pipeline based on Matlab to analyze and extract the colony data from Phenobooth+ images.

## Matlab add-ons to set up in advance
- Image Processing Toolbox # image processing package
- Active Figure Zoom for Selection Points # to zoom and pick points for `segment`

## Documentation

To look at the documentation for each function in more details please use `help` in Matlab, e.g.:
```matlab
help background
```

### Background correction
use syntax `background` to correct the background brighness bias
```matlab
background("B","../imcomplement_model.png","InDir", "../example/00_raw images","OutDir", "../example/01_background correction")
```

### Select focus area manually
```matlab
focus("Image","../example/01_background correction/bgcorrection_Run-1-Plate-001 - Original.png","OutDir","../example/02_crop and filter")
```

### Crop and filter
```matlab
piafilter("Mode","pick","FocusDir","../example/02_crop and filter/",...
          "InDir","../example/01_background correction","OutDir","../example/02_crop and filter",...
          "Rescue", "no","RescueValue", 0.75,...
          "FilterValue",104)
```

### Edge light correction
```matlab
edgelight("InDir","../example/02_crop and filter", "OutDir","../example/03_edge light correction",...
          "Thichness", 17, "Radius", 10, "Ellipticity", 1.1, "Height", 50) 
```

### Segmentation
```matlab
segment("Mode","manual",
        "InDir", "../example/03_edge light correction",...
        "OutDir","../example/04_segmentation",...
        "Coord", "../example/02_crop and filter")
```

### Calculation and analysis
```matlab
calculate("Thickness", 0.4, ...
          "InDir","../example/04_segmentation",...
          "OutDir","../example/05_calculation",...
          "Coord", "../example/02_crop and filter",...
          "Radius", 16, "Ellipticity", 1.1)

```

### Visualization
TODO

