% Plot building footprint and 100 random locations

load('./data/towers_0315.mat');
total_num = length(centerX);

loc_num = 100;
rng(0);
rand_idx = datasample(1:total_num, loc_num, 'Replace', false);

%% plot random locations
figure1 = figure;
set(figure1, 'Position', [100, 100, 500, 500]);
axes1 = axes('Parent',figure1, 'FontSize',20);
box(axes1,'on');
hold(axes1,'on');

xlabel('X (km)','FontSize',25);
ylabel('Y (km)','FontSize',25);

scatter(centerX, centerY, 'Marker','.');

for i = 1:loc_num
    scatter(centerX(rand_idx(i)), centerY(rand_idx(i)), 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
end

plot([0 0], [-10 5], '-.k', 'LineWidth', 2);
plot([-10 5], [0 0], '-.k', 'LineWidth', 2);
hold off;
axis 'image';

%% 