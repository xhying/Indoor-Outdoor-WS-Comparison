% Compute the minimum floor penetration loss required so that the secondary 
% interference to the roof TV is below antenna a certain limit.
% tower: TV tower
% ant_pattern: antenna pattern
% d_m: distance bewteen the tower and SU Tx
% theta_deg: the bearing of SU Tx or the building w.r.t. the tower 
%           (i.e., the counterclockwise angle from the due east)
% roof_tv_ant_height: height of the TV antenna on the roof
% su_tx_eirp: 

function min_indoor_loss = getMinIndoorLoss(tower, ant_pattern, d_m, theta_deg, roof_tv_ant_height, su_tx_eirp_dBm)
debug_flag = true;

theta = deg2rad(theta_deg);
% ERP: antenna gain is relative to an ideal half-wave dipole antenna
% EIRP: antenna gain is relative to an ideal isotropic antenna
% ERP = EIRP - 2.15 dB.
su_tx_erp_dBk = su_tx_eirp_dBm - 2.15 - 60;

% Logic: 
% free_space_loss = 20*log10(f) + 20*log10(d) - 28, where d is in meters.
% indoor_loss = 20log(f) + N*log10(d) + L_f - 28, where d is in meters.
% A_ref = indoor_loss - free_space_loss
% SignalStrength = 166.92 + ERP_dBk - 20*log10(d) - A_ref (in dBuV/m),
% where d is in meters.
% Hence,
% SignalStrength = 166.92 + ERP_dBk - indoor_loss + 20*log10(f) - 28

% Compute TV RSS at the roof TV antenna
[rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, d_m, theta);
desired_signal_dBu = computeSigStrength(tower, [rx_lat, rx_lon], roof_tv_ant_height, ant_pattern, false);
gamma = getThresholdInterference(tower.service, 0);
f_mhz = getCenterFreqByChId(tower.channel);

% undesired_signal_dBu <= desired_signal_dBu - gamma
% undesired_signal_dBu = 166.92 + ERP_dBk - indoor_loss + 20*log10(f) - 28
% indoor_loss >= (166.92 + ERP_dBk  + 20*log10(f) - 28) - (desired_signal_dBu - gamma)

max_undesired_signal_dBu = 166.92 + su_tx_erp_dBk + 20*log10(f_mhz) - 28;
max_undesired_signal_dBu = 166.92 + su_tx_erp_dBk + 20*log10(f_mhz) - 28 - 39.1;    % at 3m

min_indoor_loss = 166.92 + su_tx_erp_dBk + 20*log10(f_mhz) - 28 - (desired_signal_dBu - gamma);
%min_indoor_loss = max(0, min_indoor_loss);

if debug_flag
    fprintf('desired=%.2f, gamma=%.2f, max_undesired_signal_dBu=%.2f, min_indoor_floor=%.2f\n', ...
        desired_signal_dBu, gamma, max_undesired_signal_dBu, min_indoor_loss);
end

