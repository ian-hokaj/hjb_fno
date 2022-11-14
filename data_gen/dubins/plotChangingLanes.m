figure(6621); clf;
load changingLanes.mat
L = 0;
for m = 1:length(p)
    L = max(L,length(p{m}.x));
end
[~,L] = min(abs(grid.t-3));
[I,J,K] = size(uN); I = 2:(I-1); J = 2:(J-1);
if d==0 && R==0
    d = 0.07;
    R = 0.04;
end
color = {[0.0 0.0 0.9],[0.0 0.0 0.9]};
i=0;
for n = round(linspace(1,L,40))
    clf; hold on;
    plot(x0,y0,'*','markersize',10,'color',[0 0.6 0]);
    plot(xf,yf,'r*','markersize',10);
    for m = 1:length(p)
        ind = min(length(p{m}.x),n);
        plot(p{m}.x(1:ind),p{m}.y(1:ind),'linestyle',':','color',p{m}.color,'linewidth',2);
        drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
    end
    for l = 1:length(obs_x)
        %fill(obs_x{l}(n,:),obs_y{l}(n,:),'k');
        carx = mean(obs_x{l}(n,1:end-1));
        cary = mean(obs_y{l}(n,1:end-1));
        drawCar(carx,cary,d,R,pi/2,color{l});
    end
    xticks([]);
    yticks([]);
    axis([-0.4 0.4 min(grid.y(J)) max(grid.y(J))]);
    ax = gca;
    ax.FontSize = 14;
    rectangle('Position',[ax.XLim(1) ax.YLim(1) ax.XLim(2)-ax.XLim(1) ax.YLim(2)-ax.YLim(1)],'edgecolor','k','linewidth',2,'facecolor','none');
    axis image;
    F.Units = 'inches'; F.Position = [3 2 5.5 5.5];
    resolveAxis(2,5);
    
%     NAME = sprintf('ChangingLanes%i',i);
%     print(NAME,'-dpng'); 
    i = i+1;
    pause(0.1);
end