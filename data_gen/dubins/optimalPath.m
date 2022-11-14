function [p] = optimalPath(grid,u,W,d,x0,y0,s0,xf,yf,sf)
% computes the optimal path from (x0,y0,s0) to (xf,yf,sf) which is 
% the point where T(xf,yf,sf) = 0

% function for RHS of the initial condition
f = @(s,v,w) [v*cos(s) - W*d*w*sin(s); v*sin(s) + W*d*w*cos(s); W*w];

% set up functions for integrating equation of motion
dt = grid.dt; dx = grid.dx; dy = grid.dy; ds = grid.ds;
% x = zeros(1,length(grid.t)); y = x; s = x; w = x; v = x;
x(1) = x0;
y(1) = y0;
s(1) = s0;
v(1) = 0;
w(1) = 0;
% vs = [1 1 1 -1 -1 -1 0]; 
% ws = [1 0 -1 1 0 -1 0];
vs = [1 1 1];
ws = [1 0 -1];
xs = zeros(1,length(vs)); ys = xs; ss = xs;
t(1) = 0;
for n = 1:length(grid.t)-1
    for i = 1:length(vs)
       step = f(s(n),vs(i),ws(i));
       xs(i) = x(n) + dt*step(1); ys(i) = y(n)+dt*step(2); ss(i) = s(n) + dt*step(3);
    end
    [~,m] = min(u{n+1}(xs,ys,ss));
    v(n+1) = vs(m); 
    w(n+1) = ws(m);
    x(n+1) = xs(m);
    y(n+1) = ys(m);
    s(n+1) = ss(m);
    s(n+1) = mod(s(n+1),2*pi);
    t(n+1) = t(n)+dt;
    
    if norm([x(n+1)-xf;y(n+1)-yf;s(n+1)-sf],2) < norm([dx;dy;ds],2)/2 || norm([x(n+1)-xf;y(n+1)-yf;s(n+1)-sf-2*pi],2) < norm([dx;dy;ds],2)/2
        break 
    end
end

p.x = x; p.y = y; p.s = s; p.v = v; p.w = w; p.t = t;

end

