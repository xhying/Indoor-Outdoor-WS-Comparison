% Get the destination point from a starting point with a distance of
% dist_km and a bearing (theta) counterclockwise from due east.

% Find the point iteratively by computing its Haversine distance.

function [dest_lat, dest_lon] = getDestPoint(lat, lon, dist_m, theta_deg)
debug = false;

theta = deg2rad(theta_deg);

delta_lower = 0.1;
delta_upper = 0.1;

while ( true )
    tmp_lat = delta_lower*sin(theta) + lat;
    tmp_lon = delta_lower*cos(theta) + lon;
    
    d_m = computeDist(lat, lon, tmp_lat, tmp_lon);
    
    if (d_m < dist_m)
        break
    else
        delta_lower = delta_lower/2;
    end
end


while ( true )
    tmp_lat = delta_upper*sin(theta) + lat;
    tmp_lon = delta_upper*cos(theta) + lon;
    
    d_m = computeDist(lat, lon, tmp_lat, tmp_lon);
    
    if (d_m > dist_m)
        break
    else
        delta_upper = delta_upper*2;
    end
end

tolerance = 0.005;

if debug
    fprintf('delta_lower = %.2f, delta_upper = %.2f, tolerance = %.2f (meters)\n', ...
        delta_lower, delta_upper, tolerance);
end

while ( true )
    if ( abs(delta_upper-delta_lower)<tolerance )
        break;
    end
    
    delta = (delta_upper + delta_lower)/2;
    tmp_lat = delta*sin(theta) + lat;
    tmp_lon = delta*cos(theta) + lon;
    d_m = computeDist(lat, lon, tmp_lat, tmp_lon);
    
	if debug
        fprintf('d_m = %.2f, dist_m = %.2f, tolerance = %.2f\n', d_m, dist_m, tolerance);
	end
    
    if (d_m > dist_m)
        delta_upper = delta;
    else
        delta_lower = delta;
    end
end

delta = (delta_lower + delta_upper)/2;

dest_lat = delta*sin(theta) + lat;
dest_lon = delta*cos(theta) + lon;

