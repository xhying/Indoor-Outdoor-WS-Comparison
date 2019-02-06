% Compute the signal strength in dBuV at rx_loc from a tower
function signalStrength = computeSigStrength(tower, rx_loc, rx_height, antenna_pattern, FS_Flag)
ch_id = tower.channel;
tx_loc = [tower.latitude, tower.longitude];
tx_height = tower.rcagl;    % Radiation Center Above Ground Level

erp_dBk = 10 * log10(tower.erp/1000);

% if ~exist('FS_Flag', 'var')
%     FS_Flag = false;
% end

if ~FS_Flag % L-R 
    % Get antenna patterns
    if isempty(antenna_pattern)
        import spectrumobservatory.*;
        antenna_handler = TxInfoHandler('/home/shaun/Dropbox/mahtab/contour_data/DataFiles/default_top.xml');
        antenna_pattern = antenna_handler.getAntennaPattern(tower.antennaId);
    end
    
    % Calculate antenna gain in the tx-rx direction
    az_value = azimuth(tx_loc(1), tx_loc(2), rx_loc(1), rx_loc(2));
    antenna_field_value = InterpRotateAntPattern(antenna_pattern, tower.antennaOrientation, az_value);
    antenna_gain = 20*log10(antenna_field_value(:,2));

    %%
    erp_dBk = erp_dBk + antenna_gain;
    [~, Aref, params] = computeLoss(tx_loc, rx_loc, tx_height, ch_id, rx_height);
    signalStrength = 106.92 + erp_dBk - 20*log10(params.dist_m/1000) - Aref; % in dBuV
else % Free-Space
    dist_m = computeDist(tx_loc(1), tx_loc(2), rx_loc(1), rx_loc(2));
    signalStrength = 106.92 + erp_dBk - 20*log10(dist_m/1000); % in dBuV
end
