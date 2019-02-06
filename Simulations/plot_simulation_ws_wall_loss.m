log_folder = './log/simulation_ws/';

su_eirp = 36;
wall_loss_range = 5:5:30;
device_type = 'fixed';

su_eirp = 20;
wall_loss_range = 5:5:30;
device_type = 'portable';

avg_outdoor_WS = zeros(1, length(wall_loss_range));
extra_1_WS = zeros(1, length(wall_loss_range));
extra_2_WS = zeros(1, length(wall_loss_range));
extra_3_WS = zeros(1, length(wall_loss_range));
extra_4_WS = zeros(1, length(wall_loss_range));

for i = 1:length(wall_loss_range)
    wall_loss = wall_loss_range(i);
    load([log_folder, sprintf('stat_%.1f_%d_%s.mat', su_eirp, wall_loss, device_type)]);
    extra_1_WS(i) = sum(extra_WS_count == 1);
    extra_2_WS(i) = sum(extra_WS_count == 2);
    extra_3_WS(i) = sum(extra_WS_count == 3);
    extra_4_WS(i) = sum(extra_WS_count == 4);
    
    s = 0;
    for j = 1:length(stat)
        s = s + sum(stat{j}.outdoor_WS);
    end
    avg_outdoor_WS(i) = s/length(stat);
    
end

%% fixed 
if strcmp(device_type, 'fixed')
    extra_WS = [extra_1_WS' extra_2_WS', extra_3_WS'];

    figure1 = figure('Position', [100, 100, 600, 600]);
    axes1 = axes('Parent',figure1,...
        'FontSize',20,'XGrid','on','XTick',0:6,'XTickLabel',...
        {'', '5','10','15','20','25','30'},'YGrid','on','YTick',[0 25 50 75 100],...
        'YTickLabel',{'0','25%','50%','75%','100%'});

    box(axes1,'on');
    hold(axes1,'all');
    xlim(axes1,[-1 7]);

    % Create multiple lines using matrix input to bar
    bar1 = bar(extra_WS, 'BarLayout','stacked','Parent',axes1);
    set(bar1(1),'DisplayName','1 Extra Indoor WS');
    set(bar1(2),'DisplayName','2 Extra Indoor WS');
    set(bar1(3),'DisplayName','3 Extra Indoor WS');

    xlabel('Wall Penetration Loss (dB)','FontSize',25);
    ylabel('% of Locations - p','FontSize',25);

    legend1 = legend(axes1,'show');
    set(legend1, 'box', 'off', ...
        'Position',[0.233973326165679 0.737268922121485 0.362068965517241 0.177057356608479],...
        'FontSize',12);
elseif strcmp(device_type, 'portable')
    extra_WS = [extra_1_WS'];

    figure1 = figure('Position', [100, 100, 600, 600]);
    axes1 = axes('Parent',figure1,...
        'FontSize',20,'XGrid','on','XTick', 1:6,'XTickLabel',...
        {'5','10','15','20','25','30'},'YGrid','on', 'YTick', 0:5:25,...
        'YTickLabel',{'0','5%','10%','15%','20%','25%'});

    box(axes1,'on');
    hold(axes1,'all');
    xlim(axes1,[0 7]);
    ylim(axes1,[0,25]);

    % Create multiple lines using matrix input to bar
    bar1 = bar(extra_WS, 'BarLayout','stacked','Parent',axes1);
    set(bar1(1),'DisplayName','1 Extra Indoor WS');
    %set(bar1(2),'DisplayName','2 Extra Indoor WS');
    %set(bar1(3),'DisplayName','3 Extra Indoor WS');

    xlabel('Wall Penetration Loss (dB)','FontSize',25);
    ylabel('% of Locations - p','FontSize',25);

    legend1 = legend(axes1,'show');
    set(legend1, 'box', 'off', ...
        'Position',[0.208188289481562 0.779078085642315 0.518642578125 0.14735516372796],...
        'FontSize',18);
end