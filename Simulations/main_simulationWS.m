load('./data/towers_0315.mat');
total_num = length(centerX);

loc_num = 100;
rng(0);
rand_idx = datasample(1:total_num, loc_num, 'Replace', false);

%%
%su_eirp_range = (0.1:0.1:1)*36;
%wall_loss_range = 15;
%device_type = 'fixed';

su_eirp_range = (0.1:0.1:1)*20;
wall_loss_range = 15;
device_type = 'portable';

su_eirp_range = 36;
wall_loss_range = 5:5:30;
device_type = 'fixed';

su_eirp_range = 20;
wall_loss_range = 5:5:30;
device_type = 'portable';

for su_eirp = su_eirp_range
    for wall_loss = wall_loss_range

        extra_WS_count = zeros(1, loc_num);
        stat = cell(1, loc_num);

        parfor i = 1:length(rand_idx)
            loc_idx = rand_idx(i);
            rx_loc = [centerlat(loc_idx), centerlon(loc_idx)];

            stat{i} = simulationWS(rx_loc, su_eirp, wall_loss, device_type);

            extra_WS_count(i) = sum(stat{i}.indoor_WS) - sum(stat{i}.outdoor_WS);
            fprintf('loc_idx = %d, extra_WS_count=%d\n', i, extra_WS_count(i));
        end
        
        save(sprintf('./log/simulation_ws/stat_%.1f_%d_%s.mat', su_eirp, wall_loss, device_type), ...
            'stat', 'extra_WS_count');
        
    end
end
