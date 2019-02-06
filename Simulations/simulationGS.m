% Determine outdoor and indoor GS for a building at a given location.
% rx_loc: [lat, lon]
% d_GS_m: a given minimum separation distance for GS
% su_eirp: SU Tx EIRP in dBm
% wall_loss: wall penetration loss
% device_type: 'fixed' or 'portable'

function report = simulationGS(building_loc, d_GS_m, su_eirp, wall_loss, device_type)

debug_flag = true;
load('./data/towers_0315.mat');

%% Parameters
antenna_patterns = retrieveAntPatterns(towers);
outdoor_tv_ant_height = 10;     % 10 meters
rooftop_tv_ant_height = 30;     % 30 meters
dist_to_rooftop_tv_ant = 15;    % meters

if strcmp(device_type, 'fixed')
    su_tx_ant_height  = 15;     % 15 meters
elseif strcmp(device_type, 'portable')
    su_tx_ant_height  = 3;      % 3 meters
else
    error('Unknown device type');
end

%% GS determination for each tower.
outdoor_GS_per_tower = zeros(1, towers.size);
indoor_GS_per_tower1 = zeros(1, towers.size);   % Case 1: both rooftop and nearby TV receivers
indoor_GS_per_tower2  = zeros(1, towers.size);   % Case 2: nearby TV receivers only
is_building_within_contours = zeros(1, towers.size);

for tower_id=1:towers.size
    tower = towers.get(tower_id-1);
    ant_pattern = antenna_patterns{tower_id};
    Delta = getThreshold(tower.channel, tower.service);
    
    % The building needs to be within the protection contours.
    pu_sig = computeSigStrength(tower, building_loc, outdoor_tv_ant_height, ant_pattern, false);
    
    if ( pu_sig < Delta )
        % We do NOT consider this tower for GS
        is_building_within_contours(tower_id) = 0;
        outdoor_GS_per_tower(tower_id) = -1;
        indoor_GS_per_tower1(tower_id) = -1;
        indoor_GS_per_tower2(tower_id) = -1;
    else 
        is_building_within_contours(tower_id) = 1;
        outdoor_GS_per_tower(tower_id) = 0;
        indoor_GS_per_tower1(tower_id) = 0;
        indoor_GS_per_tower2(tower_id) = 0;
    
        gamma = getThresholdInterference(tower.service, 0);
    
        % Find the location in the radial direction with a distance of d_m + d_GS_m.
        building_lat = building_loc(1);
        building_lon = building_loc(2);
        theta_rad = atan2( building_lat-tower.latitude, building_lon-tower.longitude ); % simple calulation

        [tv_rx_lat, tv_rx_lon] = getDestPoint(building_lat, building_lon, d_GS_m, rad2deg(theta_rad));
    
        % Configure parameters for Hata model
        eirp_dbm = su_eirp;
        f_mhz = getCenterFreqByChId(tower.channel);
        ht_m = su_tx_ant_height;
        hr_m = outdoor_tv_ant_height;
    
        if (f_mhz < 150)
            f_mhz = 150;
        end
    
        % Determine if this is an outdoor GS
        desired_signal_dbu = computeSigStrength(tower, [tv_rx_lat, tv_rx_lon], outdoor_tv_ant_height, ant_pattern, false);
        undesired_signal_dbu = compIntHata(eirp_dbm, f_mhz, d_GS_m, ht_m, hr_m); 
    
        if debug_flag
            fprintf('Outdoor - desired=%.2f, undesired=%.2f, gamma=%.2f\n', ...
                desired_signal_dbu, undesired_signal_dbu, gamma);
        end

        if ( (desired_signal_dbu-undesired_signal_dbu) >= gamma )
            if debug_flag
                fprintf('\tCase 2 - D/U ratio=%.2f, gamma=%.2f\n', ...
                    desired_signal_dbu-undesired_signal_dbu, gamma);
            end
            
            outdoor_GS_per_tower(tower_id) = 1;
            indoor_GS_per_tower2(tower_id)  = 1;
        else
            outdoor_GS_per_tower(tower_id) = 0;

            % Determine if this is an indoor GS
            undesired_signal_dbu = undesired_signal_dbu - wall_loss;

            if ( (desired_signal_dbu-undesired_signal_dbu) >= gamma )
                if debug_flag
                    fprintf('\tCase 2 - D/U ratio=%.2f, gamma=%.2f\n', ...
                        desired_signal_dbu-undesired_signal_dbu, gamma);
                end
                
                indoor_GS_per_tower2(tower_id) = 1;
            else
                indoor_GS_per_tower2(tower_id) = 0;
            end
        end
        
        % Check the interference at the rooftop TV antenna
        if (indoor_GS_per_tower2(tower_id) == 1)
            % Compute TV signal strength at the rooftop antenna
            desired_signal_dbu = computeSigStrength(tower, [building_lat, building_lon], ...
                rooftop_tv_ant_height, ant_pattern, false);
            undesired_signal_dbu = computeSUtoRooftopPUInt(dist_to_rooftop_tv_ant, tower.channel, su_eirp);
            
            if ( (desired_signal_dbu-undesired_signal_dbu) >= gamma )
                if debug_flag
                    fprintf('\tCase 1 - desired=%.2f, undesired=%.2f, D/U ratio=%.2f, gamma=%.2f\n', ...
                        desired_signal_dbu, undesired_signal_dbu, desired_signal_dbu-undesired_signal_dbu, gamma);
                end
                
                indoor_GS_per_tower1(tower_id) = 1;
            else
                indoor_GS_per_tower1(tower_id) = 0;
            end
        else
            indoor_GS_per_tower1(tower_id) = 0;
        end

    end
end

%% Summary
if strcmp(device_type,'fixed')
    permissible_chns = setdiff(2:51, [3,4,37]);
elseif strcmp(device_type, 'portable')
    permissible_chns = setdiff(21:51, 37);
else
    error('[simulationWS] unknown device type');
end

outdoor_GS = zeros(1, 51);
indoor_GS_case1  = zeros(1, 51);
indoor_GS_case2  = zeros(1, 51);
active_tower_count = zeros(1,51);

for tower_id = 1:towers.size
    tower = towers.get(tower_id-1);
    ch_id = tower.channel;
    
    % Mark channels that are being used and can be considered for GS.
    if ismember(ch_id, permissible_chns) && is_building_within_contours(tower_id)==1
        outdoor_GS(ch_id) = 1;
        indoor_GS_case1(ch_id) = 1;
        indoor_GS_case2(ch_id) = 1;
        active_tower_count(ch_id) = active_tower_count(ch_id) + 1;
    end
end

% A channel is a GS at the building location, if it is the case for all
% towers whose signals cover the building locaiton.
for tower_id = 1:towers.size
    tower = towers.get(tower_id - 1);
    ch_id = tower.channel;
    
    if ismember(ch_id, permissible_chns) && is_building_within_contours(tower_id)==1
        if ( outdoor_GS_per_tower(tower_id) == 0 )
            outdoor_GS(ch_id) = 0;
        end
        
        if ( indoor_GS_per_tower1(tower_id) == 0 )
            indoor_GS_case1(ch_id) = 0;
        end
        
        if ( indoor_GS_per_tower2(tower_id) == 0 )
            indoor_GS_case2(ch_id) = 0;
        end
    end
end

%%
if debug_flag
    fprintf('\n----- Summary (SU EIRP=%d, Wall_loss=%d, type=%s) -----\n', ...
        su_eirp, wall_loss, device_type);
    fprintf('# of outdoor GS = %d, # of indoor GS: Case 1= %d, Case 2 = %d\n', ...
        sum(outdoor_GS), sum(indoor_GS_case1), sum(indoor_GS_case2));
end

report.rx_loc = building_loc;
report.su_eirp = su_eirp;
report.wall_loss = wall_loss;
report.device_type = device_type;
report.outdoor_GS_per_tower = outdoor_GS_per_tower;
report.indoor_GS_per_tower1 = indoor_GS_per_tower1;
report.indoor_GS_per_tower2 = indoor_GS_per_tower2;
report.outdoor_GS = outdoor_GS;
report.indoor_GS_case1 = indoor_GS_case2;
report.indoor_GS_case2 = indoor_GS_case2;
report.active_tower_count = active_tower_count;