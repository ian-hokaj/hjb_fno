function [a] = resolveAxis(h,w)
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
ax.Position = [0.005 0.005 0.99 0.99];
set(gca,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[]);
set(gcf, 'Units', 'Inches', 'Position', [4, 2.5, h/0.95, w/0.95])
end