load current.mat;
load params/params_R5.mat;
load params/finalStates_R5.mat;
trial = 703;
% trial = 13;
% trial = 100;
xf = Xf(trial); yf = Yf(trial); sf = Sf(trial);



% Compute optimal paths according to FD solution
load data/N1100_R5_clip.mat
% load data/N110_R5_fill.mat
uN = squeeze(u_out(trial,:,:,:));
uN = padarray(uN, [1 1 0], 0, 'both');
% BUG: padding will cause incorrect actions in fnoOptimalPath if car reaches
% boundary, since padding is set to 0 (not solved ghost node value)
p = {};

x0 = -0.8; y0 = 0.8; s0 = 3*pi/2;
p{1} = fnoOptimalPath(grid,uN,W,d,x0,y0,s0,xf,yf,sf);
p{1}.color = [0.5 0.5 1];
x0 = 0.8; y0 = 0.8; s0 = 7*pi/4;
p{2} = fnoOptimalPath(grid,uN,W,d,x0,y0,s0,xf,yf,sf);
p{2}.color = [1 0.5 0.5];
x0 = 0.8; y0 = -0.8; s0 = 5*pi/4;
p{3} = fnoOptimalPath(grid,uN,W,d,x0,y0,s0,xf,yf,sf);
p{3}.color = [0.25 0.75 0.25];
x0 = -0.8; y0 = -0.8; s0 = 3*pi/2;
p{4} = fnoOptimalPath(grid,uN,W,d,x0,y0,s0,xf,yf,sf);
p{4}.color = [0.5 0.5 0.5];



% % Compute optimal paths according to FNO solution
% load pred/fno_R4_full_v1.mat;
% uNPred = squeeze(pred(trial,:,:,:));  % take the last one from the tester
% uNPred = padarray(uNPred, [1 1 0], 0, 'both');
% pPred = {};
% 
% x0 = -0.8; y0 = 0.8; s0 = 3*pi/2;
% pPred{1} = fnoOptimalPath(grid,uNPred,W,d,x0,y0,s0,xf,yf,sf);
% pPred{1}.color = [0.8 0.8 1];
% x0 = 0.8; y0 = 0.8; s0 = 7*pi/4;
% pPred{2} = fnoOptimalPath(grid,uNPred,W,d,x0,y0,s0,xf,yf,sf);
% pPred{2}.color = [1 0.8 0.8];
% x0 = 0.8; y0 = -0.8; s0 = 5*pi/4;
% pPred{3} = fnoOptimalPath(grid,uNPred,W,d,x0,y0,s0,xf,yf,sf);
% pPred{3}.color = [0.5 1 0.5];
% x0 = -0.8; y0 = -0.8; s0 = 3*pi/2;
% pPred{4} = fnoOptimalPath(grid,uNPred,W,d,x0,y0,s0,xf,yf,sf);
% pPred{4}.color = [0.8 0.8 0.8];


figure(6621); clf;
L = 0;
for m = 1:length(p)
    L = max(L,length(p{m}.x));
end
[I,J,K] = size(uN);
% I = 2:I+1; J = 2:J+1;
I = 2:(I-1); J = 2:(J-1);  %already pre-formatted

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
%     plot([xf,xf+grid.dx],[yf, yf+grid.dy],'r*','markersize',10);

    for m = 1:length(p)
        ind = min(length(p{m}.x),n);
        plot(p{m}.x(1),p{m}.y(1),'*','markersize',10,'color',p{m}.color);
%         plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
%         drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);
        plot(p{m}.x(1:ind),p{m}.y(1:ind),'color',p{m}.color,'linewidth',2);
        drawCar(p{m}.x(ind),p{m}.y(ind),d,R,p{m}.s(ind),p{m}.color);

%         % repeat for pPred
%         ind = min(length(pPred{m}.x),n);
%         plot(pPred{m}.x(1),pPred{m}.y(1),'*','markersize',10,'color',pPred{m}.color);
%         plot(pPred{m}.x(1:ind),pPred{m}.y(1:ind),'--','color',pPred{m}.color,'linewidth',2);
%         drawCar(pPred{m}.x(ind),pPred{m}.y(ind),d,R,pPred{m}.s(ind),pPred{m}.color);

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