% Compute the minimum separation distance in GS sharing for a SU Tx located
% at a distance of d_m from the tower with a bearing (theta). 

function d_GS = getMinDistGS(tower, ant_pattern, d_m, theta_deg, su_tx_eirp, su_tx_height, wall_loss)
debug_flag = false;

global_params = getGlobalParams();

theta = deg2rad(theta_deg);
rx_height = global_params.TV_RX_HEIGHT;
gamma = getThresholdInterference(tower.service, 0);

% Input parameters for Hata model
eirp_dbm = su_tx_eirp;
f_mhz = getCenterFreqByChId(tower.channel);
ht_m = su_tx_height;
hr_m = global_params.TV_RX_HEIGHT;

d_GS_lower = 10;    % meters, Hata limit is [1000, 20000]
d_GS_upper = 10*1000;   % meters

[rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, d_m + d_GS_lower, theta);
desired_signal_dBu = computeSigStrength(tower, [rx_lat, rx_lon], rx_height, ant_pattern, false);
undesired_signal_dBu = compIntHata(eirp_dbm, f_mhz, d_GS_lower, ht_m, hr_m) - wall_loss;

if (debug_flag)
    fprintf('d_m=%.2f, d_GS_lower=%.2f, desired=%.2f, undesired=%.2f, D/U=%.2f, gamma=%.2f\n',...
        d_m, d_GS_lower, desired_signal_dBu, undesired_signal_dBu, desired_signal_dBu-undesired_signal_dBu, gamma)
end

if ( (desired_signal_dBu-undesired_signal_dBu) > gamma )
    d_GS = d_GS_lower;
    return;
end

[rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, d_m + d_GS_upper, theta);
desired_signal_dBu = computeSigStrength(tower, [rx_lat, rx_lon], rx_height, ant_pattern, false);
undesired_signal_dBu = compIntHata(eirp_dbm, f_mhz, d_GS_upper, ht_m, hr_m) - wall_loss;

if (debug_flag)
    fprintf('d_m=%.2f, d_GS_lower=%.2f, desired=%.2f, undesired=%.2f, D/U=%.2f, gamma=%.2f\n',...
        d_m, d_GS_upper, desired_signal_dBu, undesired_signal_dBu, desired_signal_dBu-undesired_signal_dBu, gamma)
end

if ( (desired_signal_dBu-undesired_signal_dBu) < gamma )
    d_GS = NaN;
    return;
end

% The larger d_GS is, the more likely it becomes a GS
tolerance = 1;     % in meters

while ( true )
    if ( abs(d_GS_upper-d_GS_lower)<tolerance )
        break;
    end
    
    d_GS = (d_GS_lower + d_GS_upper)/2;
    [rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, d_m + d_GS, theta);
    desired_signal_dBu = computeSigStrength(tower, [rx_lat, rx_lon], rx_height, ant_pattern, false);
    undesired_signal_dBu = compIntHata(eirp_dbm, f_mhz, d_GS, ht_m, hr_m) - wall_loss;
    
    if ( (desired_signal_dBu-undesired_signal_dBu)>gamma )
        d_GS_upper = d_GS;
    else
        d_GS_lower = d_GS;
    end
end

d_GS = (d_GS_upper+d_GS_lower)/2;

% 