% Return the border location in the radial direction of rx_loc w.r.t the tower

function [d, border_loc] = computeBorder(tower, rx_loc, rx_height, ant_pattern, FS_Flag)

tx_loc = [tower.latitude, tower.longitude];
thr = getThreshold(tower.channel, tower.service);
%thr = 100;

tmp_rx_loc = rx_loc; 
% If rx_loc is within the protection contour, choose one that is far away
while computeSigStrength(tower, tmp_rx_loc, rx_height, ant_pattern, FS_Flag) >= thr
   tmp_rx_loc = 2*tmp_rx_loc - tx_loc;
end

% Now tmp_rx_loc must be outside the protection contour
% Determine the border location iteratively (bisection)
ini_loc = tx_loc;       % lower bound of d
end_loc = tmp_rx_loc;   % upper bound of d
epsilon = 100;          % tolerance in meters  
 
d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));
while epsilon < d_tmp
    mid_loc = (ini_loc + end_loc)/2;
    sigStr = computeSigStrength(tower, mid_loc, rx_height, ant_pattern, FS_Flag);

    if sigStr >= thr
        ini_loc = mid_loc;
    else
        end_loc = mid_loc;
    end

    d_tmp = computeDist(ini_loc(1), ini_loc(2), end_loc(1), end_loc(2));
    %fprintf('Mid-point at (%f, %f), d_tmp = %f\n', mid_loc(1), mid_loc(2), d_tmp);
end

border_loc = end_loc;
d = computeDist(tx_loc(1), tx_loc(2), border_loc(1), border_loc(2));