%% first example
% figure(6621); clf;
% load annularSectors2.mat
% L = 0;
% for m = 1:length(p)
%     L = max(L,length(p{m}.x));
% end
% [I,J,K] = size(uN); I = 2:(I-1); J = 2:(J-1);
% if d==0 && R==0
%     d = 0.07;
%     R = 0.04;
% end
% i = 1;
% Xs = 0.6*cos(pi/16:pi/200:3*pi/16); Ys = 0.6*sin(pi/16:pi/200:3*pi/16);
% rotate = @(s) [cos(s) -sin(s); sin(s) cos(s)];
% % for n = round(linspace(1,round(2*L/3),4))r
% for n = round(linspace(1,L,40))
%     clf; hold on;
%     for l = 1:length(obs_x)
%         if mod(l,2)==1
%             fill(obs_x{l}(n,:),obs_y{l}(n,:),'k');
%             AA = rotate(3*pi*grid.t(n)/grid.T + (l-1)*pi/2)*[Xs;Ys];
%             xs = AA(1,:); ys = AA(2,:);
%             plot(xs,ys,'linewidth',2,'color',[1 1 1]);
%             drawArrow(xs(end-2),ys(end-2),xs(end),ys(end),1.5,[1 1 1],1);
%         else
%             fill(obs_x{l}(n,:),obs_y{l}(n,:),[0 0 1]);
%             AA = rotate(pi*grid.t(n)/grid.T+(l-1)*pi/2)*[Xs;Ys];
%             xs = AA(1,:); ys = AA(2,:);
%             plot(xs,ys,'linewidth',2,'color',[1 1 1]);
%             drawArrow(xs(end-2),ys(end-2),xs(end),ys(end),1.5,[1 1 1],1);
%         end
%     end
%     
%     plot(xf,yf,'r*','markersize',10);
%     for m = 1:length(p)
%         plot(p{m}.x(1),p{m}.y(1),'*','markersize',10,'color',[0 0.6 0]);
%         ind = min(length(p{m}.x),n);
%         plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
%         drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
%     end
%     xticks([]);
%     yticks([]);
%     axis([min(grid.x(I)) max(grid.x(I)) min(grid.y(J)) max(grid.y(J))]);
%     ax = gca;
%     ax.FontSize = 14;
%     rectangle('Position',[ax.XLim(1) ax.YLim(1) ax.XLim(2)-ax.XLim(1) ax.YLim(2)-ax.YLim(1)],'edgecolor','k','linewidth',2,'facecolor','none');
%     resolveAxis(5,5);
%     axis square;
%     pause(0.01);
%     
%     NAME = sprintf('examp1%i',i);
%     print(NAME,'-dpng');
%     i = i+1;
% end


%% Moving Doors example
figure(6621); clf;
L = 0;
load movingDoors3.mat;
for m = 1:length(p)
    L = max(L,length(p{m}.x));
end
[I,J,K] = size(uN); I = 2:(I-1); J = 2:(J-1);
if d==0 && R==0
    d = 0.07;
    R = 0.04;
end
i = 1;
for n = round(linspace(1,L-1,25))
    clf; hold on;
    for l = 1:length(obs_x)
        fill(obs_x{l}(n,:),obs_y{l}(n,:),'k');
        xc = mean(obs_x{l}(n,1:4));
        if mod(l,2) == 1
            yc = min(obs_y{l}(n,:));
            if yc > min(obs_y{l}(n+1,:))
                drawArrow(xc,yc+0.3,xc,yc+0.1,1.5,[1,1,1],2);
            else
                drawArrow(xc,yc+0.1,xc,yc+0.3,1.5,[1,1,1],1.5);
            end
        else
            yc = max(obs_y{l}(n,:));
            if yc < max(obs_y{l}(n+1,:))
                drawArrow(xc,yc-0.3,xc,yc-0.1,1.5,[1,1,1],2);
            else
                drawArrow(xc,yc-0.1,xc,yc-0.3,1.5,[1,1,1],2);
            end
        end
        
    end
    plot(x0,y0,'*','markersize',10,'color',[0 0.6 0]);
    plot(xf,yf,'r*','markersize',10);
    for m = 1:length(p)
        ind = min(length(p{m}.x),n);
%         plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
%         drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
        plot(p{m}.x(1:ind),p{m}.y(1:ind),'color','r','linewidth',2);
        drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),'r');
    end
    xticks([]);
    yticks([]);
    axis([min(grid.x(I)) max(grid.x(I)) min(grid.y(J)) max(grid.y(J))]);
    ax = gca;
    ax.FontSize = 14;
    rectangle('Position',[ax.XLim(1) ax.YLim(1) ax.XLim(2)-ax.XLim(1) ax.YLim(2)-ax.YLim(1)],'edgecolor','k','linewidth',2,'facecolor','none');
    resolveAxis(5,5);
    axis square;
    pause(0.1);
    
%     NAME = sprintf('doorsPic%i',i);
%     print(NAME,'-depsc');
%     NAME = sprintf('DoorsPic%i',i);
%     print(NAME,'-dpng');
    i = i+1;
end

%%  changing lanes example
% clear; load changingLanes.mat;
% figure(6621); clf;
% L = 0;
% for m = 1:length(p)
%     L = max(L,length(p{m}.x));
% end
% [~,L] = min(abs(grid.t-3));
% [I,J,K] = size(uN); I = 2:(I-1); J = 2:(J-1);
% if d==0 && R==0
%     d = 0.07;
%     R = 0.04;
% end
% color = {[0.0 0.0 0.9],[0.0 0.0 0.9]};
% XX = 1;
% for n = round(linspace(1,length(p{m}.x)+30,25))
%     clf; hold on;
%     rectangle('Position',[-0.4 -1 0.8 2],'edgecolor','none','linewidth',2,'facecolor',[0.3 0.3 0.3]);
%     rectangle('Position',[-0.4 -1 0.15 2],'edgecolor','none','linewidth',2,'facecolor',[0.7 0.7 0.7]);
%     xp = (1/2)*(x0+xf);
%     yp = -0.9; tn = 0.03; db = 0.2;
%     for g = 1:10
%        rectangle('Position',[xp-tn/2 yp+(g-1)*db tn 0.12],'edgecolor','none','linewidth',2,'facecolor','y'); 
%     end
%     rectangle('Position',[0.08 -1 tn/2 2],'edgecolor','none','linewidth',2,'facecolor','y'); 
%     rectangle('Position',[0.11 -1 tn/2 2],'edgecolor','none','linewidth',2,'facecolor','y'); 
%     plot(x0,y0,'*','markersize',10,'color',[0 0.6 0]);
%     plot(xf,yf,'r*','markersize',10);
%     for m = 1:length(p)
%         ind = min(length(p{m}.x),n);
%         plot(p{m}.x(1:ind),p{m}.y(1:ind),'linestyle',':','color',[1 1/2 0],'linewidth',2);
%         drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),[1 1/2 0]);
%     end
%     for l = 1:length(obs_x)
% %         fill(obs_x{l}(n,:),obs_y{l}(n,:),'k');
%         carx = mean(obs_x{l}(n,1:end-1));
%         cary = mean(obs_y{l}(n,1:end-1));
%         drawCar(carx,cary,d,R,pi/2,'b');
%     end
%     xticks([]);
%     yticks([]);
%     axis([-0.4 0.2 -1 1]);
%     ax = gca;
%     ax.FontSize = 14;
%     rectangle('Position',[ax.XLim(1) ax.YLim(1) ax.XLim(2)-ax.XLim(1) ax.YLim(2)-ax.YLim(1)],'edgecolor','k','linewidth',2,'facecolor','none');
%     axis image;
%     F.Units = 'inches'; F.Position = [3 2 5.5 5.5];
%     resolveAxis(1.5,5);
%     axis([-0.4 0.2 -1 1]);
%     pause(0.01);
%     
% %     NAME = sprintf('changingLanes%i',XX);
% %     print(NAME,'-depsc');
% %     NAME = sprintf('ChangingLanes%i',XX);
% %     print(NAME,'-dpng');
%    
%     XX = XX+1;
%     
% end