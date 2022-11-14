d = 0.75; R = 0.5;
car = [d d -d -d d;
    -R R R -R -R];
rotate = @(s) [cos(s) -sin(s); sin(s) cos(s)];

tri = (1/40) *[-1 2 -1 -1;
        2 0 -2 2];
tri = rotate(pi/4)*tri + [0.5*cos(pi/4);0.5*sin(pi/4)];
car = rotate(pi/4)*car; 
axel = [0 0; 0.35 -0.35];
axel = rotate(pi/4)*axel + [-0.5*cos(pi/4);-0.5*sin(pi/4)];
wheel1 = (1/30)*[3 3 -3 -3 3;
          -1 1 1 -1 -1];
wheel2 = wheel1;
wheel1 = rotate(pi/4)*wheel1 + [axel(1,1);axel(2,1)];
wheel2 = rotate(pi/4)*wheel2 + [axel(1,2);axel(2,2)];

axel2 = [0 0; 0.28 -0.28];
axel2 = rotate(pi/4)*axel2 + [-0.5*cos(pi/4);-0.5*sin(pi/4)];

q = 0:0.01:(pi/4);
tri2 = (1/100)*[-1 2 -1 -1;
                2 0 -2 2];
I = 66;
tri2 = rotate(q(I)+pi/2)*tri2 + [0.2*cos(q(I));0.2*sin(q(I))];

tri3 = (1/100)*[-1 2 -1 -1;
                2 0 -2 2];
tri3 = rotate(3*pi/4)*tri3 + [axel2(1,1)-0.03;axel2(1,2)-0.03];
tri4 = (1/100)*[-1 2 -1 -1;
                2 0 -2 2];
tri4 = rotate(-pi/4)*tri4 + [axel2(2,1)-0.03;axel2(2,2)-0.03];

figure(42);clf;hold on;
plot(car(1,:),car(2,:),'k','linewidth',2);
plot(axel(1,:),axel(2,:),'color','b','linewidth',2);
plot(axel2(1,:)-0.03,axel2(2,:)-0.03,'color','k','linewidth',1.5)
fill(tri3(1,:),tri3(2,:),'k');
fill(tri4(1,:),tri4(2,:),'k');
fill(tri(1,:),tri(2,:),'k');
plot([0,0.5*cos(pi/4)],[0,0.5*sin(pi/4)],'k','linewidth',2);
plot([0 0.5], [0 0], 'k--','linewidth',1.5);
plot(0.2*cos(q(1:I)),0.2*sin(q(1:I)),'k','linewidth',1.5);
fill(tri2(1,:),tri2(2,:),'k');
text(0.25*cos(pi/8),0.25*sin(pi/8),'$\theta$','Interpreter','latex','Fontsize',15);
plot([0,-0.5*cos(pi/4)],[0,-0.5*sin(pi/4)],'color',[0 0.5 0],'linewidth',2);
text(-0.23,0.13,'$(x,y)$','Interpreter','latex','Fontsize',15);
text(-0.26,-0.12,'$d$','Interpreter','latex','Fontsize',15);
% text(-0.4,-0.5,'$R$','Interpreter','latex','Fontsize',15);
p1 =  -0.17 + 0.5*(axel(1,2) + axel(1,1));
p2 =  -0.13 + 0.5*(axel(2,2) + axel(2,1));
text(p1,p2,'$2R$','Interpreter','latex','Fontsize',15);
fill(wheel1(1,:),wheel1(2,:),'k');
fill(wheel2(1,:),wheel2(2,:),'k');
plot(0,0,'r.','MarkerSize',20);
plot(-0.5*cos(pi/4),-0.5*sin(pi/4),'k.','MarkerSize',20);
axis([-1 1 -1 1]);
axis square;
axis off;

print('robotPic','-depsc');