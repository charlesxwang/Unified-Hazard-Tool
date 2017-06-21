close all

PGA = load('PGA.txt');
figure
hist(PGA(:,1))
figure
hist(PGA(:,2))
figure
hist(PGA(:,3))

figure('Position', [10, 10, 800, 600]);
hold on
h1=histogram(PGA(:,3),'FaceAlpha',0.7,'FaceColor','w','EdgeColor','k','Normalization','pdf','binwidth',0.02);
set(gca,'fontsize',17)
xlabel('PGA', 'Fontsize', 20,'Fontname','Timesnewroman');
ylabel('PDF', 'Fontsize', 20,'Fontname','Timesnewroman');
box on
grid off
xlim([0.4 0.7])
set(gca,'FontSize',20,'linewidth',1.5)
print(gcf,'-depsc2','-r300','Figures/fig_HistPGA.eps')
saveas(gcf,'Figures/fig_HistPGA','jpg');
