function obs = illegalPoses(X,Y,sv,obs_x,obs_y,d,R,n)
%configurations to check are given by (xv(i),yv(j),sv(k))
% (obs_x,obs_y) are vertices for obstacles
% d,R are car parameters
%
% obs = binary matrix
%   obs(i,j,k) = 1 is (xv(i),yv(j),sv(k)) intersects an obstacle, 0 otherwise

[I,J] = size(X);
obs = logical(zeros(I,J,length(sv)));
for k = 1:length(sv)
    X1 = X + d*cos(sv(k)) + R*cos(pi/2-sv(k));
    Y1 = Y + d*sin(sv(k)) - R*sin(pi/2-sv(k));
    X2 = X + d*cos(sv(k)) - R*cos(pi/2-sv(k));
    Y2 = Y + d*sin(sv(k)) + R*sin(pi/2-sv(k));
    X3 = X - d*cos(sv(k)) - R*cos(pi/2-sv(k));
    Y3 = Y - d*sin(sv(k)) + R*sin(pi/2-sv(k));
    X4 = X - d*cos(sv(k)) + R*cos(pi/2-sv(k));
    Y4 = Y - d*sin(sv(k)) - R*sin(pi/2-sv(k));
    for l = 1:length(obs_x)
%         obs(:,:,k) = or(obs(:,:,k),inpolygon(X1,Y1,obs_x{l}(n,:),obs_y{l}(n,:)));
%         obs(:,:,k) = or(obs(:,:,k),inpolygon(X2,Y2,obs_x{l}(n,:),obs_y{l}(n,:)));
%         obs(:,:,k) = or(obs(:,:,k),inpolygon(X3,Y3,obs_x{l}(n,:),obs_y{l}(n,:)));
%         obs(:,:,k) = or(obs(:,:,k),inpolygon(X4,Y4,obs_x{l}(n,:),obs_y{l}(n,:)));
    end
end
end

