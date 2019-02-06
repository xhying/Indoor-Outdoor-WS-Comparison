% This function achieves anetanna patternds and stores them as .mat file
function antenna_patterns = retrieveAntPatterns(towers)
import spectrumobservatory.*;

antenna_patterns = cell(1, towers.size);
if ( ~isempty( strfind( computer, 'MACI64' ) ) )    % Mac Pro
    antenna_handler = TxInfoHandler('./default_top.xml');
elseif ( ~isempty( strfind( computer, 'GLNX' ) ) )
    antenna_handler = TxInfoHandler('/home/shaun/Dropbox/mahtab/contour_data/DataFiles/default_top.xml');
end

for i = 1:towers.size
    antenna_patterns{i} = antenna_handler.getAntennaPattern(towers.get(i-1).antennaId);    
end

%save('antenna_patterns.mat', 'antenna_patterns');