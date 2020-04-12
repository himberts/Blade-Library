% Welcome to the newest version of the Blade library. This library allows
% you to reduce and analyze X-ray data taken with the Biological large
% angle diffraction experiment (Blade) at McMaster.
% This Demo script highlights the most important functions of the library.
% 
% The library can be installed on your computer by copying the @Blade
% folder to your Matlab main directory. Whatever you do, never change any
% files in the Dropbox folder!!

% Don't hesitate to contact Sebastian (himberts@mcmaster.ca) in case you
% have any questions. 

% Copyright & Questions: Laboratory of membrane and protein dynamics, McMaster University,
% Sebastian Himbert (himberts@mcmaster.ca)

clear
close all


filename = '1RNA_2DMPC_07162018_panorama';

% The Blade object can be created by calling the Blade command:
b = Blade;  
%There are multiple options to read the RAW data. If you have taken a
%panorama you can load and merge the files by calling:
Data = b.merge('p',filename,3);
%%
% You can visualize your data by calling:
b.Plot2Ddata('a');  %Display in Angular space. Other options are: 'm' for metric space, 'q' for q space and 'p' for pixel space. 
% caxis([-1 10]);

r = 28.48;
phi = 0:2:120;
x = r.*cosd(phi);
y = r.*sind(phi);
% You can change the figure as usual and add additional plots to it:
hold on;
plot(x,y,'r*');
hold off;

b.Plot2Ddata; % Dispay in q space (default). 

%%

% The single images are stored in independend Blade object for further
% analysis
Data(1).Plot2Ddata()
caxis([-1 6]);
Data(2).Plot2Ddata()
caxis([-1 6]);
Data(3).Plot2Ddata()
caxis([-1 6]);

%%

% The most important function for Data reduction is obj.Integration2D. It
% integrates your data in various ways.

close all;
qmax = 1.6;
qmin = 3;
minAngle = 5;
maxAngle = 40;

% For a inplane reduction you need to choose the 'i' Option. The additional
% parameters depend on the used flag.
b.Integration2D('i',qmin,qmax,minAngle,maxAngle);

% Is this done? Great! You just reduced your data. It is really that easy!!

%%

close all;
qmin = 0.01;
qmax = 2;
width = 20;

% The 'lr' options calculates a Reflectivity curve
b.Integration2D('lr',qmin,qmax,width);

%%

close all;
qmin = 0.01;
qmax = 2;
minAngle = 80;

% The 'cr' option calculates a Reflectivity curve by using a circular
% integration path
b.Integration2D('cr',qmin,qmax,minAngle);

%%

close all;
qmax = 0.1165;
qmin = 0.1165;
minAngle = 10;
maxAngle = 90;

% The 'h' option calculates a Intensity file a long a circular integration
% path used to calculate Hermans Orientation function. However, advanced
% options will be discussed below

b.Integration2D('h',qmin,qmax,minAngle,maxAngle);


%%
close all;

% The reduced data can be re-ploted by using the PlotDdata function with
% the afore mentioned options
b.Plot1Ddata('lr');

% The Blade object includes all information about your measurement and the
% reduction. It also includes all reduced curves and used parameters. You
% can save it
save('MyData.mat','b','Data');

% By re-loading the file, you have all data handy right away. You don't
% need to run any of the afore described functions again!
%%

% Instead of merging the data as panorama, you can also merge them as long
% time exposure file ('lte'). You can use the same reduction and analysing
% functions.

close all
clear
filename = 'POPC_97RH_03272018';

b = Blade;
Data = b.merge('lte',filename,5);

b.Plot2Ddata
%%


% Let's take a look in the analysis. We load a X-ray scan of a Hybrid
% Membrane and calculate a linear reflectivity. Make sure that you loaded
% the spec1D library. 

clear;
close all;

b = Blade;
% Btw: You can load also a single image by using the load_img function:
b.load_img('Hybrid_R-P_1-4_88RH_highres_pos2_0001.img');
b.Plot2Ddata
caxis([0 6]);
qmax = 0.01;
qmin = 1;
width = 20;
b.Integration2D('lr',qmin,qmax,width);

%%
% Now the first thing you want to probably do is to find the peak
% positions. Just call ob.SetPeakPos. The program opens a figure where you
% need to select the left and right edge of each peak. Press ENTER when you
% are done. The program should automatically find the peak position. The
% function obj.PlotBragg plots the peak position vs the expected Bragg
% order and fits the data linearly. Missed peaks will be detected. The
% d-spacing is calculated.

close all;
b.SetPeakPos()
b.PlotBragg

%%

% Now you can calculate the orientation of your membrane stack. Just call
% obj.CalculateHerman. It performs a 2D Integration and fits a gaussian.
% The orientation is calculated by using Hermans Orientation function.

b.CalculateHerman();

%%

% Wanna see your electron density profile? Just call the following functions: 
% The number of phases and parameters may need to be adjusted for your
% dataset. One phase per peak.

b.phases = [-1 -1 1 -1 1]; 
b.ElectronDensity;
fitp=[1 1 1 1 0]; 
init=[1 1 1 8 0]; 
b.T_func(0,init,fitp);

%%

% Wow I am proud of you!  You managed to analyze X-ray data. But what
% happens if your data are tilted because of a missalignment? Well just run
% obj.CorrectOrientation . It opens a 2D plot. You just need to click on
% the first three orders of bragg peaks (avoid more). The orientation will be
% corrected. 
clear 
close all

b = Blade;
b.load_img('Hybrid_R-D_4-1_88RH_highres_0001.img');
b.Plot2Ddata
b.CorrectOrientation;
b.Plot2Ddata

%%
% Did your scanned range was too large? Well just crop your data :). Note
% that the resultion does not increase!!

clear 
close all;

b = Blade;
b.load_img('Hybrid_R-P_1-4_88RH_highres_pos2_0001.img');
b.Plot2Ddata
qparmin = -.1;
qparmax = 0.5;
qzmin = 0;
qzmax = 0.5;
bcrop = b.crop([qparmin qparmax qzmin qzmax]);

bcrop.Plot2Ddata;