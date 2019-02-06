% Determine outdoor and indoor WS for a building at a given location.
% rx_loc: [lat, lon]
% su_eirp: EIRP of SU Tx
% wall_loss: wall penetration loss in dB
% device_type: 'fixed' or 'portable'

function report = simulationWS(rx_loc, su_eirp, wall_loss, device_type)

debug = false;

load('./data/towers_0315.mat');

%% Parameters
antenna_patterns = retrieveAntPatterns(towers);
outdoor_tv_ant_height = 10;     % 10 meters

if strcmp(device_type, 'fixed')
    su_tx_ant_height  = 15;     % 15 meters
elseif strcmp(device_type, 'portable')
    su_tx_ant_height  = 3;      % 3 meters
else
    error('Unknown device type');
end

%% WS determination for each tower.
outdoor_WS_per_tower = zeros(1, towers.size);
indoor_WS_per_tower  = zeros(1, towers.size);

tower_id_range = 1:towers.size;

for tower_id = tower_id_range
    tower = towers.get(tower_id - 1);
    ant_pattern = antenna_patterns{tower_id};
    Delta = getThreshold(tower.channel, tower.service);
    
    % Check if the location is outside protection contours
    pu_sig = computeSigStrength(tower, rx_loc, outdoor_tv_ant_height, ant_pattern, false);  % PU signal
    
    if debug
        fprintf('tower_id=%d, channel=%d, pu_sig=%.2f, Delta=%.2f\n', ...
            tower_id, tower.channel, pu_sig, Delta);
    end
    
    if ( pu_sig >= Delta )  
        % If it is within protection contours, then the channel is neither an outdoor nor indoor WS.
        outdoor_WS_per_tower(tower_id) = 0;
        indoor_WS_per_tower(tower_id)  = 0;
    else
        gamma = getThresholdInterference(tower.service, 0);
        max_int = Delta - gamma;
        
        [r_PC, border_loc] = computeBorder(tower, rx_loc, outdoor_tv_ant_height, ant_pattern, false);
        
        f_mhz = getCenterFreqByChId(tower.channel);
        d_m   = computeDist(border_loc(1), border_loc(2), rx_loc(1), rx_loc(2));
        ht_m  = su_tx_ant_height;
        hr_m  = outdoor_tv_ant_height;
        
        if ( d_m > 20000 )
            if debug
                fprintf('\t r_PC=%.2f, d_m=%.2f is greater than 20,000\n', r_PC, d_m);
            end
            
            outdoor_WS_per_tower(tower_id) = 1;
            indoor_WS_per_tower(tower_id)  = 1;
            continue;
        end
        
        if debug
            fprintf('[debug] channel = %d, d_m=%d, f_mhz = %d\n', tower.channel, d_m, f_mhz);
        end
        
        % Hata model only accepts frequencies between 150 and 1500 MHz.
        if (f_mhz < 150)
            f_mhz = 150;
        end
        
        su_int = compIntHata(su_eirp, f_mhz, d_m, ht_m, hr_m);
        
        if ( su_int < max_int )
            % If an outdoor SU Tx causes less interference than the maximum,
            % then it is both outdoor and indoor WS.
            outdoor_WS_per_tower(tower_id) = 1;
            indoor_WS_per_tower(tower_id)  = 1;
        else
            outdoor_WS_per_tower(tower_id) = 0;
            
            if ( su_int < max_int + wall_loss )
                % Walls provide an additional interference budget.
                indoor_WS_per_tower(tower_id) = 1;
            end
        end
        
        if debug
            fprintf('\t max_int=%.2f, su_int=%.2f, wall_loss=%.2f\n', ...
                max_int, su_int, wall_loss);
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

outdoor_WS = zeros(1, 51);
indoor_WS  = zeros(1, 51);

outdoor_WS(permissible_chns) = 1;
indoor_WS(permissible_chns)  = 1;

for tower_id = tower_id_range
    tower = towers.get(tower_id - 1);
    ch_id = tower.channel;
    
    if ismember(ch_id, permissible_chns)
        if ( outdoor_WS_per_tower(tower_id) == 0 )
            outdoor_WS(ch_id) = 0;
        end
        
        if ( indoor_WS_per_tower(tower_id) == 0)
            indoor_WS(ch_id)  = 0;
        end
    end
end

%%
if debug
    fprintf('\n----- Summary (SU EIRP=%d, Wall_loss=%d, type=%s) -----\n', ...
        su_eirp, wall_loss, device_type);
    fprintf('# of outdoor WS = %d, # of indoor WS = %d\n', sum(outdoor_WS), sum(indoor_WS));
end

report.rx_loc = rx_loc;
report.su_eirp = su_eirp;
report.wall_loss = wall_loss;
report.Delta = Delta;
report.gamma = gamma;
report.device_type = device_type;
report.outdoor_WS_per_tower = outdoor_WS_per_tower;
report.indoor_WS_per_tower = indoor_WS_per_tower;
report.outdoor_WS = outdoor_WS;
report.indoor_WS = indoor_WS;