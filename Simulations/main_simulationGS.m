load('./data/towers_0315.mat');
total_num = length(centerX);

loc_num = 100;
rng(0);
rand_idx = datasample(1:total_num, loc_num, 'Replace', false);

%%
% su_eirp_range = (0.1:0.1:1)*36;
% wall_loss_range = 0:15:30;
% d_GS_m = 250;  % 500 or 250
% device_type = 'fixed';

% New
su_eirp_range = (0.1:0.1:1)*36; %(0.1:0.1:1)*36;
wall_loss_range = [0,15,30]; %0:15:30;
d_GS_m = 40;  % 20 or 40 meters
device_type = 'fixed';

% su_eirp_range = (0.1:0.1:1)*20;
% wall_loss_range = 0:15:30;
% d_GS_m = 500;   % 500 or 250
% device_type = 'portable';

% New
su_eirp_range = (0.1:0.1:1)*20;
wall_loss_range = 0:15:30;
d_GS_m = 40;   % 20 or 40
device_type = 'portable';

for su_eirp = su_eirp_range
    for wall_loss = wall_loss_range

        extra_GS_count_case1 = zeros(1, loc_num);
        extra_GS_count_case2 = zeros(1, loc_num);
        stat = cell(1, loc_num);

        parfor i = 1:length(rand_idx)
            loc_idx = rand_idx(i);
            rx_loc = [centerlat(loc_idx), centerlon(loc_idx)];

            stat{i} = simulationGS(rx_loc, d_GS_m, su_eirp, wall_loss, device_type);         

            extra_GS_count_case1(i) = sum(stat{i}.indoor_GS_case1) - sum(stat{i}.outdoor_GS);
            extra_GS_count_case2(i) = sum(stat{i}.indoor_GS_case2) - sum(stat{i}.outdoor_GS);
            
            fprintf('loc_idx = %d, outdoor_GS = %d, extra_GS_count_case1=%d, extra_GS_count_case2=%d\n', ...
                i, sum(stat{i}.outdoor_GS), extra_GS_count_case1(i), extra_GS_count_case2(i));
        end
        
        save(sprintf('./log/simulation_gs2/stat_%.1f_%d_%s_%d.mat', su_eirp, wall_loss, device_type, d_GS_m), ...
            'stat', 'extra_GS_count_case1', 'extra_GS_count_case2');
        
    end
end
