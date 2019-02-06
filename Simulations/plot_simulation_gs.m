log_folder = './log/simulation_gs2/';

% su_eirp_range = 0.1:0.1:1;
% max_eirp = 36;
% d_GS_m = 500;   % 500 or 250 meters
% wall_loss_range = 0:15:30;
% device_type = 'fixed';

% New
su_eirp_range = 0.1:0.1:1;
max_eirp = 36;
d_GS_m = 40;   % 20 or 40 meters
wall_loss_range = [0,15,30]; % 0:15:30;
device_type = 'fixed';

% su_eirp_range = 0.1:0.1:1;
% max_eirp = 20;
% d_GS_m = 500;
% wall_loss_range = 0:15:30;
% device_type = 'portable';

% su_eirp_range = 0.1:0.1:1;
% max_eirp = 20;
% d_GS_m = 40;
% wall_loss_range = 0:15:30;
% device_type = 'portable';

% Legend: 
% Outdoor
% Indoor Case 1 - 15dB Wall Loss
% Indoor Case 2 - 15dB Wall Loss
% Indoor Case 1 - 30dB Wall Loss
% Indoor Case 2 - 30dB Wall Loss

avg_num_indoor_GS_case1 = zeros(length(wall_loss_range), length(su_eirp_range));
avg_num_indoor_GS_case2 = zeros(length(wall_loss_range), length(su_eirp_range));

for i=1:length(wall_loss_range)
    for j=1:length(su_eirp_range)
        wall_loss = wall_loss_range(i);
        su_eirp = su_eirp_range(j)*max_eirp;
        
        load([log_folder, sprintf('stat_%.1f_%d_%s_%d.mat', su_eirp, wall_loss, device_type, d_GS_m)]);

        num_indoor_GS_case1 = zeros(1, length(stat));
        num_indoor_GS_case2 = zeros(1, length(stat));
        for k=1:length(stat)
            num_indoor_GS_case1(k) = sum(stat{k}.indoor_GS_case1);
            num_indoor_GS_case2(k) = sum(stat{k}.indoor_GS_case2);
        end

        avg_num_indoor_GS_case1(i,j) = mean(num_indoor_GS_case1);
        avg_num_indoor_GS_case2(i,j) = mean(num_indoor_GS_case2);
        
    end
end

%% fixed 
if strcmp(device_type, 'fixed')
    figure1 = figure;
    set(figure1, 'Position', [100,100,600,600]);

    axes1 = axes('Parent',figure1);
    set(axes1,'FontSize',25,'XGrid','on','XTick',[0.1 0.4 0.7 1],'XTickLabel',...
        {'10%','40%','70%','100%'},'YGrid','on');
    hold(axes1,'on');
    box(axes1,'on');
    
    xlim(axes1, [0.1,1]);
    %ylim(axes1, [5,35]);
    ylim(axes1, [0,25]);

    plot(su_eirp_range, avg_num_indoor_GS_case1(1,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Outdoor','MarkerSize',10,'Marker','diamond');
    plot(su_eirp_range, avg_num_indoor_GS_case1(2,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (1) - 15dB Wall Loss','Marker','+');
    plot(su_eirp_range, avg_num_indoor_GS_case2(2,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (2) - 15dB Wall Loss','Marker','x', 'LineStyle','--');
    plot(su_eirp_range, avg_num_indoor_GS_case1(3,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (1) - 30dB Wall Loss','Marker','^');
    plot(su_eirp_range, avg_num_indoor_GS_case2(3,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (2) - 30dB Wall Loss','Marker','v', 'LineStyle','--');

    xlabel({'EIRP (%)'}, 'FontSize', 25);
    ylabel({'Avg. Num of Gray Spaces'}, 'FontSize', 25);

    legend1 = legend(axes1,'show');
    set(legend1, 'box', 'off', 'FontSize', 18,...
        'Position',[0.157045533117586 0.155741391261989 0.74255126953125 0.2479296875]);

elseif strcmp(device_type, 'portable')
    figure1 = figure;
    set(figure1, 'Position', [100,100,600,600]);

    axes1 = axes('Parent',figure1);
    set(axes1,'FontSize',25,'XGrid','on','XTick',[0.1 0.4 0.7 1],'XTickLabel',...
        {'10%','40%','70%','100%'},'YGrid','on');
    hold(axes1,'on');
    box(axes1,'on');
    
    xlim(axes1, [0.1,1]);
    ylim(axes1, [0, 25]);

    plot(su_eirp_range, avg_num_indoor_GS_case1(1,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Outdoor','MarkerSize',10,'Marker','diamond');
    plot(su_eirp_range, avg_num_indoor_GS_case1(2,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (1) - 15dB Wall Loss','Marker','+');
    plot(su_eirp_range, avg_num_indoor_GS_case2(2,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (2) - 15dB Wall Loss','Marker','x', 'LineStyle','--');
    plot(su_eirp_range, avg_num_indoor_GS_case1(3,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (1) - 30dB Wall Loss','Marker','^');
    plot(su_eirp_range, avg_num_indoor_GS_case2(3,:), 'MarkerSize',12,'LineWidth',3, ...
        'DisplayName','Indoor (2) - 30dB Wall Loss','Marker','v', 'LineStyle','--');

    xlabel({'EIRP (%)'}, 'FontSize', 25);
    ylabel({'Avg. Num of Gray Spaces'}, 'FontSize', 25);

    legend1 = legend(axes1,'show');
    set(legend1, 'box', 'off', 'FontSize', 18, ...
        'Position',[0.158712199784253 0.159074724595323 0.74255126953125 0.2479296875]);
end