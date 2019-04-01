![image](.github/CIVMBanner.png)

# U24 DICOM tool
### Matt Holbrook and Dr. Cristian Badea
### Center for In Vivo Microscopy, Duke University
This is a MATLAB-based tool for converting 3D image volumes from NifTi format to DICOMs. This repository contains a GUI which can be used to assign values to common DICOM fields. It also contains functions which can be used in your own code to streamline workflows.

## Dependencies
##### MATLAB
The GUI for this application is build using MATLAB's appDesigner. To run we recommend using **MATLAB 2017b** or later.
##### Libraries
We use both the [NifTi toolbox](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) and [Json Lab](https://github.com/fangq/jsonlab). These packages allow consistent handling of NifTi files across all our software and make JSON files easier to edit.