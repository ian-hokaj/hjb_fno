load current.mat;

figure(6621); clf;
L = 0;
for m = 1:length(p)
    L = max(L,length(p{m}.x));
end
[I,J,K] = size(uN); I = 2:(I-1); J = 2:(J-1);
if d==0 && R==0
    d = 0.07;
    R = 0.04;
end
for n = round(linspace(1,L,40))
    clf; hold on;
    for l = 1:length(obs_x)
%         fill(obs_x{l}(n,:),obs_y{l}(n,:),'k');
    end
    
    plot(xf,yf,'r*','markersize',10);
    for m = 1:length(p)
        ind = min(length(p{m}.x),n);
        plot(p{m}.x(1),p{m}.y(1),'*','markersize',10,'color',p{m}.color);
%         plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
%         drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
        plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
        drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
    end
    xticks([]);
    yticks([]);
    axis([min(grid.x(I)) max(grid.x(I)) min(grid.y(J)) max(grid.y(J))]);
    ax = gca;
    ax.FontSize = 14;
    rectangle('Position',[ax.XLim(1) ax.YLim(1) ax.XLim(2)-ax.XLim(1) ax.YLim(2)-ax.YLim(1)],'edgecolor','k','linewidth',2,'facecolor','none');
    axis square;
    F.Units = 'inches'; F.Position = [3 2 5.5 5.5];
    pause(0.1);
end