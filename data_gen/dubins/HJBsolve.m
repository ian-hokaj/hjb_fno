function [u,uN] = HJBsolve(grid,u0,W,d,R,init_x,init_y,init_s,obs_x,obs_y)
% solve the time-dep HJB equation for optimal travel time func
uN = u0;
[I,J,K] = size(u0);
N = length(grid.t);
u = cell(1,N);
dx = grid.dx; dy = grid.dy; ds = grid.ds; dt = grid.dt;
s = grid.s;
[X,Y,S] = ndgrid(grid.x,grid.y,grid.s);
u{N} = griddedInterpolant(X,Y,S,u0);

% precompute the coefficients Ak,Bk,ak,bk
% A = zeros(6,K); B = zeros(6,K); a = zeros(6,K); b = zeros(6,K);
A = zeros(3,K); B = zeros(3,K); a = zeros(3,K); b = zeros(3,K);


for k = 1:K
    %v = 1, w = 1
    A(1,k) = abs(cos(s(k)) - W*d*sin(s(k)));
    a(1,k) = sign(cos(s(k)) - W*d*sin(s(k)));
    B(1,k) = abs(sin(s(k)) + W*d*cos(s(k)));
    b(1,k) = sign(sin(s(k)) + W*d*cos(s(k)));
    
    %v = 1, w = -1
    A(2,k) = abs(cos(s(k)) + W*d*sin(s(k)));
    a(2,k) = sign(cos(s(k)) + W*d*sin(s(k)));
    B(2,k) = abs(sin(s(k)) - W*d*cos(s(k)));
    b(2,k) = sign(sin(s(k)) - W*d*cos(s(k)));
    
    %v = 1, w = 0
    A(3,k) = abs(cos(s(k)));
    a(3,k) = sign(cos(s(k)));
    B(3,k) = abs(sin(s(k)));
    b(3,k) = sign(sin(s(k)));
    
%     %v = -1, w = 1
%     A(4,k) = abs(-cos(s(k)) - W*d*sin(s(k)));
%     a(4,k) = sign(-cos(s(k)) - W*d*sin(s(k)));
%     B(4,k) = abs(-sin(s(k)) + W*d*cos(s(k)));
%     b(4,k) = sign(-sin(s(k)) + W*d*cos(s(k)));
%     
%     %v = -1, w = -1
%     A(5,k) = abs(-cos(s(k)) + W*d*sin(s(k)));
%     a(5,k) = sign(-cos(s(k)) + W*d*sin(s(k)));
%     B(5,k) = abs(-sin(s(k)) - W*d*cos(s(k)));
%     b(5,k) = sign(-sin(s(k)) - W*d*cos(s(k)));
%     
%     %v = -1, w = 0
%     A(6,k) = abs(-cos(s(k)));
%     a(6,k) = sign(-cos(s(k)));
%     B(6,k) = abs(-sin(s(k)));
%     b(6,k) = sign(-sin(s(k)));
end


for n = N:-1:2
    if mod(n,100) == 0
%         fprintf('%i ',n);
    end
    
    % find illegal poses for this time step
    obs = illegalPoses(grid.X,grid.Y,grid.s,obs_x,obs_y,d,R,n);
    size(obs);

    for i = 2:I-1
        for j = 2:J-1
            for k = 2:K
                if obs(i,j,k)
                    uN(i,j,k) = 200;
                else
                    % update value function unless it's at the goal state
                    if ~(((k==init_s) || (k==init_s+K-1)) && (j==init_y) && (i==init_x))
                        
                        %choose k+1 accounting for periodicity
                        kp1 = (k+1)*(k+1<=K) + 2*(k+1>K);
                        
                        % construct 7 possible upwind deriv approximations
                        %v = 1, w = 1
                        u1 = u0(i,j,k) + dt*(1+(A(1,k)/dx)*(u0(i+a(1,k),j,k)-u0(i,j,k))...
                            +(B(1,k)/dy)*(u0(i,j+b(1,k),k)-u0(i,j,k))...
                            +(W/ds)*(u0(i,j,kp1)-u0(i,j,k)));
                        %v = 1, w = -1
                        u2 = u0(i,j,k) + dt*(1+(A(2,k)/dx)*(u0(i+a(2,k),j,k)-u0(i,j,k))...
                            +(B(2,k)/dy)*(u0(i,j+b(2,k),k)-u0(i,j,k))...
                            +(W/ds)*(u0(i,j,k-1)-u0(i,j,k)));
                        %v = 1, w = 0
                        u3 = u0(i,j,k) + dt*(1+(A(3,k)/dx)*(u0(i+a(3,k),j,k)-u0(i,j,k))...
                            +(B(3,k)/dy)*(u0(i,j+b(3,k),k)-u0(i,j,k)));
                        %v = -1, w = 1
%                         u4 = u0(i,j,k) + dt*(1+(A(4,k)/dx)*(u0(i+a(4,k),j,k)-u0(i,j,k))...
%                             +(B(4,k)/dy)*(u0(i,j+b(4,k),k)-u0(i,j,k))...
%                             +(W/ds)*(u0(i,j,kp1)-u0(i,j,k)));
%                         %v = -1, w = -1
%                         u5 = u0(i,j,k) + dt*(1+(A(5,k)/dx)*(u0(i+a(5,k),j,k)-u0(i,j,k))...
%                             +(B(5,k)/dy)*(u0(i,j+b(5,k),k)-u0(i,j,k))...
%                             +(W/ds)*(u0(i,j,k-1)-u0(i,j,k)));
%                         %v = -1, w = 0
%                         u6 = u0(i,j,k) + dt*(1+(A(6,k)/dx)*(u0(i+a(6,k),j,k)-u0(i,j,k))...
%                             +(B(6,k)/dy)*(u0(i,j+b(6,k),k)-u0(i,j,k)));
                        
%                         % v = 0, w = 0
%                         u7 = u0(i,j,k) + dt;
                        
                        %update u(i,j,k,n-1)
%                         uN(i,j,k) = min([u1,u2,u3,u4,u5,u6,u7,u0(i,j,k)]);
                        uN(i,j,k) = min([u1,u2,u3,u0(i,j,k)]);

                        %                     if u(i,j,k,n-1)< 200
                        %                        fprintf('(i,j,k) = (%i,%i,%i), u = %.4f\n',i,j,k,u(i,j,k,n-1));
                        %                     end
                    end
                end
            end
        end
    end
    %enforce periodicity
    uN(:,:,1) = uN(:,:,K);
    u{n-1} = griddedInterpolant(X,Y,S,uN);
    u0 = uN;
end

% fprintf('\n');
end

