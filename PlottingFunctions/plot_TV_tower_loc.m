%% Plot on x-y coordinates
load('./data/towers_0315.mat');

%%
figure1 = figure;
set(figure1, 'Position', [100, 100, 500, 500]);
axes1 = axes('Parent',figure1, 'FontSize',20);
axis 'image'

xlim(axes1, [-270,270]);
ylim(axes1, [-270,270]);
box(axes1,'on');
hold(axes1,'on');

xlabel('X (km)','FontSize',25);
ylabel('Y (km)','FontSize',25);


%scatter(centerX, centerY, 'Marker','.');

for i = 0:towers.size-1
    [tmp_x, tmp_y] = computeXY(SF_center, [towers.get(i).latitude, towers.get(i).longitude]);
    scatter(tmp_x, tmp_y, 'MarkerEdgeColor','r', 'MarkerFaceColor','r', 'LineWidth', 3);
end

plot([0 0], [-200 200], '-.k', 'LineWidth', 2);
plot([-200 200], [0 0], '-.k', 'LineWidth', 2);

% Draw a circle with a radius of 200km w.r.t. the SF center
ang = 0:0.01:2*pi; 
xp = 200*cos(ang);
yp = 200*sin(ang);
plot(xp, yp, 'b');

%hold off;
