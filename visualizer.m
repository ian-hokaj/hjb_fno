xi = linspace(-1,1,2**5)
yi = linspace(-1,1,2**5)
zi = linspace(-1,1,2**5)
[X,Y] = meshgrid(xi,yi) ; 
Z = griddata(x,y,z,X,Y) ;
figure
pcolor(X,Y,Z) ; shading interp ; colorbar
figure
surf(X,Y,Z) ; shading interp ; colorbar