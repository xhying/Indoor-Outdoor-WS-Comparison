beta = 344;

r = 10:1:100; % meter

p = exp(-beta*pi*((r/1000).^2));

%%
figure1 = figure;
set(figure1, 'Position', [100, 100, 600, 500]);

axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on',...
    'XTick',10:10:70, ...
    'FontSize',25);
xlim(axes1,[10 70]);
box(axes1,'on');
hold(axes1,'on');

ylabel({'Prob.'},'FontSize',25);
xlabel({'Radius (m)'},'FontSize',25);

plot(r,p,'LineWidth',3);