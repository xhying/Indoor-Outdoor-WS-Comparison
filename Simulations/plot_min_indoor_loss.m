load('./data/towers_0315.mat');

tower_id = 130;     % index starting from 0
tower = towers.get(tower_id);
ant_patterns = retrieveAntPatterns(towers);
ant_pattern = ant_patterns{tower_id + 1};

[rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, 1000, 0);

r_PC = getProtectionContourLoc(tower, [rx_lat, rx_lon], ant_pattern, false)

% r_PC = 149 km

%%
roof_tv_ant_height = 30;    % in meters

device_type = 'portable';
eirp_percentage_vec = 0.25:0.25:1;
dist_km_vec = [1,3, 5:5:100];
min_indoor_floor_vec = zeros(length(eirp_percentage_vec), length(dist_km_vec));

if strcmp(device_type, 'fixed')
    max_eirp = 36;
elseif strcmp(device_type, 'portable')
    max_eirp = 20;
end

for i=1:length(eirp_percentage_vec)
    for j=1:length(dist_km_vec)
        eirp = eirp_percentage_vec(i) * max_eirp;
        dist_km = dist_km_vec(j);
        min_indoor_floor_vec(i,j) = getMinIndoorLoss(tower, ant_pattern, ...
            dist_km*1000, 0, roof_tv_ant_height, eirp);
    end
end

%%
figure1 = figure;
set(figure1, 'Position', [100, 100, 600, 600]);
axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on',...
    'XTick',[0 25 50 75 100], ...
    'FontSize',20);
xlim(axes1,[0,100]);
ylim(axes1,[20,120]);

if strcmp(device_type, 'fixed')
    %ylim(axes1, [0,8]);
elseif strcmp(device_type, 'portable')
    %ylim(axes1, [0,2]);
end

box(axes1,'on');
hold(axes1,'on');

xlabel('Distance (km)','FontSize',25);
ylabel('Min. Indoor Path Loss (dB)','FontSize',25);

plot(dist_km_vec, min_indoor_floor_vec(1,:), 'LineWidth',3, 'DisplayName', '25% EIRP', ...
    'MarkerSize',10,'Marker','diamond');
plot(dist_km_vec, min_indoor_floor_vec(2,:), 'LineWidth',3, 'DisplayName', '50% EIRP', ...
    'MarkerSize',12,'Marker','*');
plot(dist_km_vec, min_indoor_floor_vec(3,:), 'LineWidth',3, 'DisplayName', '75% EIRP', ...
    'MarkerSize',12,'Marker','+');
plot(dist_km_vec, min_indoor_floor_vec(4,:), 'LineWidth',3, 'DisplayName', '100% EIRP', ...
    'MarkerSize',12,'Marker','x');

legend1 = legend(axes1,'show');

if strcmp(device_type, 'fixed')
    set(legend1, 'box', 'off', ...
        'Location', 'southeast',...
        'FontSize',18);
elseif strcmp(device_type, 'portable')
    set(legend1, 'box', 'off', ...
        'Location', 'southeast',...
        'FontSize',18);
end
