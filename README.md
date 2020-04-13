# Blade Library
This MATLAB(R) library is designed to read and store 2D X-ray data from a RIGAKU X-ray diffractometer.
The library is specifically designed to read scattering data measured by a HyPix-3000 detector stored in the RIGAKU .img format. When loading data, the origin is detected and all geometric distortions and corrections are automatically applied and the x and y axis are stored in metric, angular and q-space.

The provided functions allow to open a single scan or to merge multiple scans into one either as panorama or superposed image.
The 2D data can be reduced in multiple ways: linear integration along the q_z or q_parralel axis or circular integration. The library provides additional functions to calculate the d-spacing, electron density, and orientation of a lamellar sample (e.g. solid supported lipid bilayers)

# Installation
This library is written for Matlab and has been tested with versions > 2012a. Copy the folder @Blade into your directory (most common: <User-Directory>/Documents/MATLAB). That's it. You may try the library with the demo folder.

Questions: Laboratory of membrane and protein dynamics, McMaster University,
Sebastian Himbert (himberts@mcmaster.ca)
