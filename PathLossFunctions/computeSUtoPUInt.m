% Interference from SU to PU at a different location from SU

function signalStrength = computeSUtoPUInt(su, border_pu_loc, FS_Flag)

ch_id = su.channel;
su_loc = [su.latitude, su.longitude];
su_hgt = su.height;
su_eirp = su.eirp;  % max. EIRP in dBm (including antenna gain)

erp_dBk = su_eirp - 2.15 - 60;   % dBkW = dBm - 60;

% if ~exist('debug', 'var')
%     FS_Flag = false;
% end

if ~FS_Flag % L-R
    [~, Aref, params] = computeLoss(su_loc, border_pu_loc, su_hgt, ch_id);
    signalStrength = 106.92 + erp_dBk - 20*log10(params.dist_m/1000) - Aref; % in dBuV
else
    %dist_m = computeDist(su_loc(1), su_loc(2), border_pu_loc(1), border_pu_loc(2));
    dist_m = 20;    % WARNING: 20 meters between the building and nearby PU Rx
    warning('dist_m = 20 between the building and nearby PU Rx by default');
    signalStrength = 106.92 + erp_dBk - 20*log10(dist_m/1000); % in dBuV
end