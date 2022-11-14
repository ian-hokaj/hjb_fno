clear; timer = tic;
%% car parameters
W = 6;       % maximum angular velocity
% R = 0.04;    % axle length
% d = 0.07;    % dist from rear axle to center of mass
R = 0.0;
d = 0.0;
%% set up grid
N_samples = 1100;   % number of trials

M = 2^4;    % grid resolution
% M = 51;
grid.x = linspace(-1,1,M); grid.y = linspace(-1,1,M);
grid.s = linspace(0,2*pi,M);
grid.dx = grid.x(2) - grid.x(1);
grid.dy = grid.y(2) - grid.y(1);
grid.ds = grid.s(2) - grid.s(1);
grid.dt = 1/(ceil(((1+W*d)/grid.dx + (1+W*d)/grid.dy + W/grid.ds)/50)*50);
% grid.dt = 1/200;
grid.T = 5;
grid.t = 0:grid.dt:grid.T;
N = length(grid.t);
grid.gn = 1; % how many layers of ghost nodes
% create the ghost nodes for the spatial domain
for l = 1:grid.gn
    grid.x = [grid.x(1)-grid.dx,grid.x,grid.x(end)+grid.dx];
    grid.y = [grid.y(1)-grid.dy,grid.y,grid.y(end)+grid.dy];
end
[grid.X,grid.Y] = ndgrid(grid.x,grid.y);

%% desired ending configuration
% xf = 0.0; yf = 0.0; sf = pi; % for circles example
Xf = 2 * rand(N_samples,1) - 1;
Yf = 2 * rand(N_samples,1) - 1;
Sf = 2*pi * rand(N_samples,1);

%% Initialize/Sovle N_samples HJB Equations
% a_out = zeros(N_samples, length(grid.x), length(grid.y), length(grid.s));
% u_out = zeros(N_samples, length(grid.x), length(grid.y), length(grid.s));
a_out = zeros(N_samples, M, M, M);
u_out = zeros(N_samples, M, M, M);

for i = 1:N_samples
    if mod(i,10) == 0
        fprintf('%i', i);
        fprintf('\n');
    end

    % extract final states
    xf = Xf(i,1);
    yf = Yf(i,1);
    sf = Sf(i,1);

    % initialization
    [~,init_x] = min(abs(grid.x-xf));
    [~,init_y] = min(abs(grid.y-yf));
    [~,init_s] = min(abs(grid.s-sf));
    u0 = 200*ones(length(grid.x),length(grid.y),length(grid.s));
    u0(init_x,init_y,init_s) = 0;
    if init_s == 1 || init_s == size(u0,3)
        u0(init_x,init_y,1) = 0;
        u0(init_x,init_y,end) = 0;
    end
    
    % determine illegal poses
    % STATIONARY OBSTACLES
    obs_x{1} = [0.2 0.2 -0.2 -0.2 0.2];
    obs_y{1} = [-0.2 0.2 0.2 -0.2 -0.2];
    
    % solve HJB equation
    [u,uN] = HJBsolve(grid,u0,W,d,R,init_x,init_y,init_s,obs_x,obs_y);
    T2 = toc(timer);
%     fprintf('[I,J,K] = [%i,%i,%i]. Solved HJB equation in %.2f sec.\n',M,M,M,T2);

    % store initial and final value function, dropping spatial ghost modes
    a_out(i,:,:,:) = u0(2:end-1, 2:end-1, :);
    u_out(i,:,:,:) = uN(2:end-1, 2:end-1, :);
end

%% compute optimal paths
x0 = -0.8; y0 = 0.8; s0 = 3*pi/2;
p{1} = optimalPath(grid,u,W,d,x0,y0,s0,xf,yf,sf);
p{1}.color = [0.5 0.5 1];
x0 = 0.8; y0 = 0.8; s0 = pi/4;
p{2} = optimalPath(grid,u,W,d,x0,y0,s0,xf,yf,sf);
p{2}.color = [1 0.5 0.5];
x0 = 0.8; y0 = -0.8; s0 = 5*pi/4;
p{3} = optimalPath(grid,u,W,d,x0,y0,s0,xf,yf,sf);
p{3}.color = [0.25 0.75 0.25];
x0 = -0.8; y0 = -0.8; s0 = 3*pi/2;
p{4} = optimalPath(grid,u,W,d,x0,y0,s0,xf,yf,sf);
p{4}.color = [0.5 0.5 0.5];

%% save results in current.mat
% save current.mat R d grid obs_x obs_y p s0 sf uN x0 xf y0 yf;
save data/N1100_R4.mat a_out u_out