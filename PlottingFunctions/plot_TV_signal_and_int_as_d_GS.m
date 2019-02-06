% Plot TV signals and secondary interference as a function of d_GS.

load('./data/towers_0315.mat');
tower_id = 130;      % starting from 0
tower = towers.get(tower_id);
ant_patterns = retrieveAntPatterns(towers);
ant_pattern = ant_patterns{tower_id + 1};

% Setting 1: d=80km, 
% Setting 2: d=100km, wall_loss = 15 dB.

wall_loss = 15; % dB
d = 100*1000; % 50km
d_m_vec   = 50:10:5000;  % Separation distance in meters
tv_signal  = zeros(1, length(d_m_vec));
int_signal = zeros(1, length(d_m_vec));
int_signal2 = zeros(1, length(d_m_vec));

for i=1:length(d_m_vec)
    [rx_lat, rx_lon] = getDestPoint(tower.latitude, tower.longitude, (d+d_m_vec(i)), 0); 
    tv_signal(i) = computeSigStrength(tower, [rx_lat, rx_lon], 10, ant_pattern, false);
   
    eirp_dbm = 36;   % fixed device
    f_mhz = getCenterFreqByChId(tower.channel);
    ht_m = 15;
    hr_m = 10;
    
    if (f_mhz < 150)
        f_mhz = 150;
    end
    
    int_signal(i) = compIntHata(eirp_dbm, f_mhz, d_m_vec(i), ht_m, hr_m);
    int_signal2(i) = int_signal(i) - wall_loss; 
end

gamma = getThresholdInterference(tower.service, 0);
[~, idx] = min(abs(tv_signal - int_signal - gamma));
d_GS = d_m_vec(idx)

[~, idx] = min(abs(tv_signal - int_signal2 - gamma));
d_GS_2 = d_m_vec(idx)

%%
figure1 = figure;
set(figure1, 'Position', [100, 100, 600, 500]);

axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on','FontSize',18);
hold(axes1,'on');

xlim([0,5000]);

ylabel('Field Strength (dBu)');
xlabel('Separation Dist (m)');

% Setting 1
%plot(d_m_vec, tv_signal, 'LineWidth',3,'DisplayName','TV Signal Strength','LineStyle','--','Color','blue');
%plot(d_m_vec, int_signal,'LineWidth',3, 'DisplayName','Secondary Interference', 'Color', 'red');

% Setting 2
plot(d_m_vec, tv_signal, 'LineWidth',3,'DisplayName','TV Signal Strength','LineStyle','--','Color','blue');
plot(d_m_vec, int_signal,'LineWidth',3, 'DisplayName','Secondary Int - Outdoor', 'Color', 'red');
plot(d_m_vec, int_signal2,'LineWidth',3, 'DisplayName','Secondary Int - Indoor', 'LineStyle','--', 'Color', 'red');

% Create legend
legend1 = legend(axes1,'show');
set(legend1,'FontSize',18);

% Setting 1
plot([d_GS d_GS], [0,100], 'LineWidth',3,'LineStyle',':', 'Color', 'black');
% Setting 2
plot([d_GS_2 d_GS_2], [0,100], 'LineWidth',3,'LineStyle',':', 'Color', 'black');