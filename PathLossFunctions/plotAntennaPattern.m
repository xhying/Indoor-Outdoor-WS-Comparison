function plotAntennaPattern(AntennaPattern, linestyle)
% This function plots antenna patterns in polar coordinates. Input must be
% an array list of [Azimuth, Field Value] from Java.
%
% polargeo function (in HelpingFunctions) is used to achieve clockwise plot 
% wrt North.
%
% Example of using this function from command window:
% set_path; import spectrumobservatory.*;
% handler = TxInfoHandler(getFilePath('setting'));
% handler.connectDB(getFilePath('setting'));
% pattern = handler.getAntennaPattern(18954);
% plotAntennaPattern(pattern, '-*')
%
%
import spectrumobservatory.*;

if(~exist('linstyle', 'var'))
    linestyle = '-';
end

field_value = zeros(1, AntennaPattern.size);
azimuth = zeros(1, AntennaPattern.size);

for ii=0:AntennaPattern.size-1
    azimuth(ii+1) = AntennaPattern.get(ii).azimuth;
    field_value(ii+1) = AntennaPattern.get(ii).fieldValue;
end
        
polargeo(azimuth/180*pi, field_value, linestyle);