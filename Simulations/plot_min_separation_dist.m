% Load data
load('./data/towers_0315.mat');

figure;
hold on;
for i=0:towers.size-1
    lon = towers.get(i).longitude;
    lat = towers.get(i).latitude;
    scatter(lon, lat, 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    
    if ( abs(lon+121.5)<0.1 && abs(lat-38.27)<0.1)
        fprintf('i=%d\n', i);
    end
end

% Use a tower in the dataset
tower_id = 130;      % starting from 0
tower = towers.get(tower_id);
scatter(tower.longitude, tower.latitude, 'MarkerEdgeColor','b', 'MarkerFaceColor','b');

fprintf('channel=%d, erpWt=%.1f, haat=%.1f, lat=%.2f, lon=%.2f \n', ...
    tower.channel, tower.erp, tower.haat, tower.latitude, tower.longitude);

% Retrieve antenann pattern
ant_patterns = retrieveAntPatterns(towers);
ant_pattern = ant_patterns{tower_id + 1};

%% Plot antenna pattern
plotAntennaPattern(ant_pattern);

%% d_WS as a function of P_t^{SU}
% Tower: tower with id of 130 (starting from 0) in towers_0315.mat
%   - channel: 48 - 755 MHz (center freq.)
%   - erpWt: 1000,000 Watts
%   - lat: 38.27
%   - lon: -121.49
%   - Delta: 41 dBu
%   - gamma: 23 dB (Digital service)
%
% SU Tx: 
%   - eirp: 36 dBm (max.)
%   - height: 15 m
%
Delta = getThreshold(tower.channel,tower.service);      % TV service threshold in dBuV
gamma = getThresholdInterference(tower.service, 0);       % D/U ratio for co-channel interference

global_params = getGlobalParams();

device_type = 'fixed';
max_eirp = global_params.FIXED_SU_TX_MAX_EIRP;      % 36 dBm
su_tx_height = global_params.FIXED_SU_TX_HEIGHT;    % 15 m

device_type = 'portable';
max_eirp = global_params.PORTABLE_SU_TX_MAX_EIRP;      % 20 dBm
su_tx_height = global_params.PORTABLE_SU_TX_HEIGHT;  % 3 m

eirp_vec = 0.1:0.1:1;
d_WS_vec = zeros(4, length(eirp_vec));

for i=1:length(eirp_vec)
    eirp = eirp_vec(i)*max_eirp;
    d_WS_vec(1, i) = getMinDistWS(tower, eirp, su_tx_height, 0);    % outdoor
    d_WS_vec(2, i) = getMinDistWS(tower, eirp, su_tx_height, 10);   % indoor with 10dB wall loss
    d_WS_vec(3, i) = getMinDistWS(tower, eirp, su_tx_height, 20);   % indoor with 20dB wall loss
    d_WS_vec(4, i) = getMinDistWS(tower, eirp, su_tx_height, 30);   % indoor with 30dB wall loss
end

%%
figure1 = figure;
set(figure1, 'Position', [100, 100, 600, 600]);
axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on',...
    'XTick',10:30:100, 'XTickLabel',{'10%','40%','70%','100%'},...
    'FontSize',20);
xlim(axes1,[10,100]);

if strcmp(device_type, 'fixed')
    ylim(axes1, [0,8]);
elseif strcmp(device_type, 'portable')
    ylim(axes1, [0,2]);
end

box(axes1,'on');
hold(axes1,'on');

xlabel('EIRP (%)','FontSize',25);
ylabel('Min. Sep. Dist. (km)','FontSize',25);

plot(eirp_vec*100, d_WS_vec(1,:)/1000, 'LineWidth',3, 'DisplayName', 'Outdoor', ...
    'MarkerSize',10,'Marker','diamond');
plot(eirp_vec*100, d_WS_vec(2,:)/1000, 'LineWidth',3, 'DisplayName', 'Indoor - 10dB Wall Loss', ...
    'MarkerSize',12,'Marker','*');
plot(eirp_vec*100, d_WS_vec(3,:)/1000, 'LineWidth',3, 'DisplayName', 'Indoor - 20dB Wall Loss', ...
    'MarkerSize',12,'Marker','+');
plot(eirp_vec*100, d_WS_vec(4,:)/1000, 'LineWidth',3, 'DisplayName', 'Indoor - 30dB Wall Loss', ...
    'MarkerSize',12,'Marker','x');

legend1 = legend(axes1,'show');

if strcmp(device_type, 'fixed')
    set(legend1, 'box', 'off', ...
        'Position',[0.139583334616489 0.625703125000001 0.5875830078125 0.299921875],...
        'FontSize',18);
elseif strcmp(device_type, 'portable')
    set(legend1, 'box', 'off', ...
        'Position',[0.176250001283156 0.625703125000001 0.5875830078125 0.299921875],...
        'FontSize',18);
end

%% GS Sharing - d_{GS} 
% For a given d, the distance from the TV tower, get the feasible values
% for d_{GS} subject to D/U ratio requirement.

Delta = getThreshold(tower.channel,tower.service);      % TV service threshold in dBuV
gamma = getThresholdInterference(tower.service, 0);       % D/U ratio for co-channel interference

global_params = getGlobalParams();

device_type = 'fixed';
max_eirp = global_params.FIXED_SU_TX_MAX_EIRP;      % 36 dBm
su_tx_height = global_params.FIXED_SU_TX_HEIGHT;    % 15 m

device_type = 'portable';
max_eirp = global_params.PORTABLE_SU_TX_MAX_EIRP;      % 20 dBm
su_tx_height = global_params.PORTABLE_SU_TX_HEIGHT;    % 3 m

power_percentage = 1;

d_km_vec = 5:5:100; 
d_GS_vec = zeros(4, length(d_km_vec));

for i=1:length(d_km_vec)
    eirp = power_percentage*max_eirp;
    d_km = d_km_vec(i);
    
    [rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, d_km*1000, 0);
    desired_signal_dBu = computeSigStrength(tower, [rx_lat, rx_lon], 10, ant_pattern, false);
    
    fprintf('d_km=%.2f (km), desired=%.2f (dBuV/m)\n', d_km, desired_signal_dBu);
    
    d_GS_vec(1,i) = getMinDistGS(tower, ant_pattern, d_km*1000, 0, eirp, su_tx_height, 0)/1000;    % in km
    d_GS_vec(2,i) = getMinDistGS(tower, ant_pattern, d_km*1000, 0, eirp, su_tx_height, 10)/1000;    % in km
    d_GS_vec(3,i) = getMinDistGS(tower, ant_pattern, d_km*1000, 0, eirp, su_tx_height, 20)/1000;    % in km
    d_GS_vec(4,i) = getMinDistGS(tower, ant_pattern, d_km*1000, 0, eirp, su_tx_height, 30)/1000;    % in km
    
end

%%
figure2 = figure;
set(figure2, 'Position', [100, 100, 600, 600]);
axes1 = axes('Parent',figure2,'YGrid','on','XGrid','on', 'XTick',[0 25 50 75 100],...
    'FontSize',20);
xlim(axes1,[0 100]);
if strcmp(device_type, 'portable')
    ylim(axes1,[0, .5]);
end

if strcmp(device_type, 'fixed')
    ylim(axes1,[0, 2]);
end

box(axes1,'on');
hold(axes1,'on');

ylabel('Min. Sep. Dist. (km)','FontSize',25);
xlabel('Dist from TV Tower (km)','FontSize',25);
plot(d_km_vec, d_GS_vec(1,:), 'LineWidth',3, 'DisplayName','Outdoor', ...
    'MarkerSize',10,'Marker','diamond');
plot(d_km_vec, d_GS_vec(2,:), 'LineWidth',3, 'DisplayName','Indoor - 10dB Wall Loss', ...
    'MarkerSize',12,'Marker','*');
plot(d_km_vec, d_GS_vec(3,:), 'LineWidth',3, 'DisplayName','Indoor - 20dB Wall Loss', ...
    'MarkerSize',12,'Marker','+');
plot(d_km_vec, d_GS_vec(4,:), 'LineWidth',3, 'DisplayName','Indoor - 30dB Wall Loss', ...
    'MarkerSize',12,'Marker','x');

% Create legend
legend1 = legend(axes1,'show');
set(legend1, 'box', 'off', ...
    'Location','northwest',...
    'FontSize',18);