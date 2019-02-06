% Return the protection contour edge location in the radial direction of rx_loc w.r.t the tower

% r_PC: protection contour range
% rc_loc: TV RX location; actually its direction w.r.t. the tower matters.
% ant_pattern: antenna pattern of TV transmitter
% FS_flag: FS is used if true, LR otherwise

function [r_PC, border_loc] = getProtectionContourLoc(tower, rx_loc, ant_pattern, FS_Flag)
global_params = getGlobalParams();
TV_RX_HEIGHT = global_params.TV_RX_HEIGHT;  % 10 meters by default

tower_loc = [tower.latitude, tower.longitude];
Delta  = getThreshold(tower.channel, tower.service); % TV service threshold

% Choose a new rx location along the line between TV Tx and RX_loc, which
% is outside the protection contour.
tmp_rx_loc = rx_loc;
while computeSigStrength(tower, tmp_rx_loc, TV_RX_HEIGHT, ant_pattern, FS_Flag) > Delta
    tmp_rx_loc = 2*tmp_rx_loc - tower_loc;
end

% Now tmp_rx_loc must be outside the protection contour
% Determine the border location iteratively (bisection)
ini_loc = tower_loc;       % lower bound of d
end_loc = tmp_rx_loc;   % upper bound of d
epsilon = 100;          % tolerance in meters  
 
d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));    % in meters
while epsilon < d_tmp
    mid_loc = (ini_loc + end_loc)/2;
    sigStr = computeSigStrength(tower, mid_loc, TV_RX_HEIGHT, ant_pattern, FS_Flag);

    if sigStr >= Delta
        ini_loc = mid_loc;
    else
        end_loc = mid_loc;
    end

    d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));
    %fprintf('Mid-point at (%f, %f), d_tmp = %f\n', mid_loc(1), mid_loc(2), d_tmp);
end

border_loc = end_loc;
r_PC = computeDist(tower_loc(1), tower_loc(2), border_loc(1), border_loc(2));