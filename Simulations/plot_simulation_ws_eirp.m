log_folder = './log/simulation_ws/';

su_eirp_range = (0.1:0.1:1)*36;
wall_loss = 15;
device_type = 'fixed';

su_eirp_range = (0.1:0.1:1)*20;
wall_loss = 15;
device_type = 'portable';

avg_outdoor_WS = zeros(1, length(su_eirp_range));
extra_1_WS = zeros(1, length(su_eirp_range));
extra_2_WS = zeros(1, length(su_eirp_range));
extra_3_WS = zeros(1, length(su_eirp_range));

for i = 1:length(su_eirp_range)
    su_eirp = su_eirp_range(i);
    load([log_folder, sprintf('stat_%.1f_%d_%s.mat', su_eirp, wall_loss, device_type)]);
    extra_1_WS(i) = sum(extra_WS_count == 1);
    extra_2_WS(i) = sum(extra_WS_count == 2);
    extra_3_WS(i) = sum(extra_WS_count == 3);
    
    s = 0;
    for j = 1:length(stat)
        s = s + sum(stat{j}.outdoor_WS);
    end
    avg_outdoor_WS(i) = s/length(stat);
    
end

%% fixed 
if strcmp(device_type, 'fixed')
    extra_WS = [extra_1_WS' extra_2_WS'];

    figure1 = figure('Position', [100, 100, 600, 600]);
    axes1 = axes('Parent',figure1,...
        'FontSize',20,'XGrid','on','XTick',[0 1 4 7 10],'XTickLabel',...
        {'','10%','40%','70%','100%'},'YGrid','on','YTick',[0 30 60 90],...
        'YTickLabel',{'0','30%','60%','90%'});

    box(axes1,'on');
    hold(axes1,'all');
    xlim(axes1,[0 11]);
    ylim(axes1,[0,90]);

    % Create multiple lines using matrix input to bar
    bar1 = bar(extra_WS, 'BarLayout','stacked','Parent',axes1);
    set(bar1(1),'DisplayName','1 Extra Indoor WS');
    set(bar1(2),'DisplayName','2 Extra Indoor WS');
    %set(bar1(3),'DisplayName','3 Extra Indoor WS');

    xlabel('EIRP (%)','FontSize',25);
    ylabel('% of Locations - p','FontSize',25);

    legend1 = legend(axes1,'show');
    set(legend1, 'FontSize', 18, 'box', 'off', ...
        'Position',[0.189854956148228 0.779078085642315 0.518642578125 0.14735516372796]);
elseif strcmp(device_type, 'portable')
    extra_WS = [extra_1_WS'];

    figure1 = figure('Position', [100, 100, 600, 600]);
    axes1 = axes('Parent',figure1,...
        'FontSize',20,'XGrid','on','XTick',[0 1 4 7 10],'XTickLabel',...
        {'','10%','40%','70%','100%'},'YGrid','on', 'YTick',[0 4 8 12 16],...
        'YTickLabel',{'0','4%','8%','12%', '16%'});

    box(axes1,'on');
    hold(axes1,'all');
    xlim(axes1,[0 11]);

    % Create multiple lines using matrix input to bar
    bar1 = bar(extra_WS, 'BarLayout','stacked','Parent',axes1);
    set(bar1(1),'DisplayName','1 Extra Indoor WS');
    %set(bar1(2),'DisplayName','2 Extra Indoor WS');
    %set(bar1(3),'DisplayName','3 Extra Indoor WS');

    xlabel('EIRP (%)','FontSize',25);
    ylabel('% of Locations - p','FontSize',25);

    legend1 = legend(axes1,'show');
    set(legend1, 'box', 'off', ...
        'Position',[0.189854956148228 0.787411418975648 0.518642578125 0.14735516372796],...
        'FontSize',18);
end