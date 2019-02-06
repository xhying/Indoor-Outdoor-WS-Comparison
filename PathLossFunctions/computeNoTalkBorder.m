function [d, no_talk_border_loc] = computeNoTalkBorder(SU_profile, tower, ant_pattern, wall_penetration_loss, FS_Flag)
%% SU_profile
%   .latitude
%   .longitude
%   .eirp
%   .height      ==> Tx ant. height
SU_profile.channel = tower.channel;

debug_plot_flag = false;

tower_loc = [tower.latitude, tower.longitude];
thr = getThreshold(tower.channel, tower.service);
D_U_ratio = getThrsholdIntrference(tower.service, 0);

rx_loc = [SU_profile.latitude, SU_profile.longitude];
rx_height = SU_profile.height;

% Determine the border location in the radial direction of SU
[~, border_loc] = computeBorder(tower, rx_loc, rx_height, ant_pattern, FS_Flag);

% The border location is the midpoint of tmp_rx_loc and tx_loc.
% This should guarantee that tmp_rx_loc is outside the no-talk region
tmp_rx_loc = 2*border_loc - tower_loc; 

% Check if this is true
RSS = computeSigStrength(tower, tmp_rx_loc, rx_height, ant_pattern, FS_Flag);
Interference = computeSUtoPUInt(SU_profile, border_loc, FS_Flag) - wall_penetration_loss;

if (RSS >= thr) || ((thr - Interference) < D_U_ratio)
    warning('Something is wrong');
end

% Now apply the bisection method to determine the no-talk border
ini_loc = border_loc;
end_loc = tmp_rx_loc;
epsilon = 100;          % tolerance in meters
tmp_su = SU_profile;

if debug_plot_flag
    figure;
    hold on;
end

d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));

while epsilon < d_tmp
    mid_loc = (ini_loc + end_loc)/2;
    
    tmp_su.latitude = mid_loc(1);
    tmp_su.longitude = mid_loc(2);
    
    int = computeSUtoPUInt(tmp_su, border_loc, FS_Flag) - wall_penetration_loss;
    
    if ((thr - int) < D_U_ratio)  % mid_loc is too close
        ini_loc = mid_loc;
    else
        end_loc = mid_loc;
    end
    
    d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));
    if debug_plot_flag
        fprintf('Mid-point at (%f, %f), d_tmp = %f, thr = %f, int = %f, D/U ratio = %f\n', ...
                mid_loc(1), mid_loc(2), d_tmp, thr, int, D_U_ratio);
        scatter(mid_loc(1), mid_loc(2));
    end
end

no_talk_border_loc = end_loc;
d = computeDist(tower_loc(1), tower_loc(2), no_talk_border_loc(1), no_talk_border_loc(2));


