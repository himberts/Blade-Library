function load_img(obj,filename)
% This function loads 2D X-ray data and store the data in a Blade object 
% Parameters are:
% filename : Filename of the 2D Data
%
% The function returns:
%  ---
%
% Copyright & Questions: Laboratory of membrane and protein dynamics, McMaster University,
% Sebastian Himbert (himberts@mcmaster.ca)

    
obj.filename = {filename};
fid = fopen(fullfile(pwd,filename));
fgetl(fid);
temp        = fgetl(fid);
HeaderBytes = str2double(temp(strfind(temp,'=')+1:end-1));  %Read Size of the Header
fgetl(fid);
fgetl(fid);
temp        = fgetl(fid);
SizeY       = str2double(temp(strfind(temp,'=')+1:end-1));  %Read Size of the Image in y direction
obj.SizeY   = SizeY;
temp        = fgetl(fid);
SizeX       = str2double(temp(strfind(temp,'=')+1:end-1));  %Read Size of the Image in x direction
obj.SizeX   = SizeX;

for k = 1:1:10
    fgetl(fid);  % Jump 10 lines
end

temp            = fgetl(fid);
wavelength      = str2num(temp(strfind(temp,'=')+1:end-1));  % Read Wavelength (first value is the number of sources (1); the second number is the wavelength)
wavelength      = wavelength(2);
obj.Wavelength  = wavelength;
temp            = fgetl(fid);
obj.Amperage    = str2double( temp(strfind(temp,'=')+1:end-4)); % Read Amperage setting in mA
temp            = fgetl(fid);
obj.Voltage     = str2double( temp(strfind(temp,'=')+1:end-4));  % Read Voltage setting in kV
obj.Energy      = obj.Amperage * obj.Voltage;                    % Calculate Energy

for k = 1:1:21
    fgetl(fid);  % Jump 21 lines
end

temp            = fgetl(fid);
DistortionInfo  = str2num(temp(strfind(temp,'=')+1:end-1)); % Read Distortion Info
PixelSize       = DistortionInfo(3:4);  % Values 3 and 4 are the pixel size in mm. Values 1 and 2 are the orgini
obj.PixelSize   = PixelSize;

for k = 1:1:10
    fgetl(fid);  % Jump 10 lines
end

temp              = fgetl(fid);
DetectorGonioSet  = str2num(temp(strfind(temp,'=')+1:end-1));    % Read Detector position. The last value is the distance sample - detector

for k = 1:1:48
    fgetl(fid);  % Jump 48 lines
end

fseek(fid, HeaderBytes, 'bof');   % Skip Header
data = fread(fid,[SizeY SizeX],'int');  % Read image data

data = flip(data,2); %Flip the image data since the detector x axis is flipped

DistanceMin = DetectorGonioSet(end); % The minimal distance Sample-Detector is given by the normal on the Detector 
DistanceEffective = DistanceMin;  % The effective distance at q_|| = 0 is different from the minimal distance when the detector is rotated by ThetaChi


DistortionInfo(2) = SizeX - DistortionInfo(2);  % Blade internally flips the image. Thus the Origin needs to be corrected
origin       = [ DistortionInfo(2)-((tand(DetectorGonioSet(3))*DistanceMin)/PixelSize(1)) ; 1];  % The orgin for a given angle ThetaChi and Distance is given by trigonometric identities
% origin = origin;

obj.Origin  = origin;

% Calculate Pixel coordinate. Note that these Coordinates don't correct for
% Spherical distortion
x_corr_pxCord     = (1:1:SizeX) - origin(1);   
y_corr_pxCord     = (1:1:SizeY) - origin(2);

% The inplane Angle THetaChi does not follow a linear behavior due to the
% planar detector. It can be determined by trigonometric identieties analog
% to the origin.
alpha = zeros(1,SizeX);
for i=0:1:SizeX-1
  alpha(i+1) = atand(  (DistortionInfo(2)*PixelSize(1)-i*0.1) / DetectorGonioSet(end)  ) ;
end

alpha =  - alpha  +  DetectorGonioSet(3); % The Angle needs to be shifted by the setting of ThetaChi
alpha = alpha *1;%0.952;  %The Correction was found by measuring a silicon sample but leads to wrong resuluts for all other samples. 

% Calculate Metric coordinate. Note that these Coordinates don't correct for
% Spherical distortion
x_corr_metricCord = x_corr_pxCord*PixelSize(1);
y_corr_metricCord = y_corr_pxCord*PixelSize(2);  


% Calculate anglular coordinate. Note that these coordinates correct for
% Spherical distortion as described in the calculations above. Blade moves
% the Detecor on the surface of a sphere and reads only lines, which
% matches Bragg's condition. There is no additional spherical correction
% needed.
Theta2Chi         = alpha; % Calculated above
Theta2Theta       = 1*( y_corr_metricCord ./ DistanceEffective) *( 360/(2*pi) );   % Assuming that the pixel-size corresponds radians one can transfer the value to angles by knowing the radius. 

% Calculate reciprocal coordinate. Note that these coordinates correct for
% Spherical distortion as described in the calculations above. Blade moves
% the Detecor on the surface of a sphere and reads only lines, which
% matches Bragg's condition. There is no additional spherical correction
% needed.
qz                = (4*pi/wavelength)*sind(Theta2Theta/2);  % Calculate qpar and qz. The angular scale is 2Theta.
qpar              = (4*pi/wavelength)*sind(Theta2Chi/2);

% Save all parameters in the object
obj.xMetric     = x_corr_metricCord;  
obj.yMetric     = y_corr_metricCord;
obj.Theta2Theta = Theta2Theta;
obj.ThetaChi    = Theta2Chi;
obj.Data2D      = data;
obj.qpar        = qpar;
obj.qz          = qz;
obj.Data2D      = data;
obj.DetectorPos = DetectorGonioSet(end);
obj.DetectorPosChi = DetectorGonioSet(3);
obj.Version     = '5.1';
fclose(fid);
end