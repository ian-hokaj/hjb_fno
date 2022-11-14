Below is a brief description of the files included, their functionality and 
important notes for the user.

To get started, follow these steps:
  - extract all files to a directory
  - navigate to the directory in MATLAB
  - run the script driver.m.
  - run the script plotPath.m to see animations of the cars driving

The files included are: 

(1) driver.m 	-           In this script, you can set all the parameters 
			    for the experiment you want to run. Then running 
			    the script will solve the Hamilton-Jacobi-Bellman 
			    The obstacles used in the animations are created 
                            in this script. This script will also uses the 
                            optimalPath.m function to compute optimal paths
		      	    from all the specified initial points. By default,
			    the data produced by driver will be stored in a 
			    .mat data file called "current.mat" which can then
			    be loaded by plotPath.m to view results as an 
			    animation.

(2) HJBsolve.m  -           This is a function that solves the time dependent
			    HJB equation for the optimal travel time function
							
(3) illegalPoses.m	-   This is a function which computes all the illegal
			    configurations based on the geometry of the vehicle
			    and the obstacles specified in driver.m
				
(4) optimalPath.m       -   This function computes the optimal paths using the 
			    semi-Lagrangian algorithm described in the manuscript

(5) plotPath.m          -   This script plots the optimal paths of each car
			    from a starting point to an ending point in an 
			    animation. The three animations used in the paper 
                            are sectioned off so that the user can run the section
                            for the animation corresponding to the experiment ran
                            in the driver.
							
IMPORTANT NOTE: 
To run each simulation and their accompanying animation there are four places that
need to be commented/uncommented in the code:
(1) In driver.m where the final point (xf,yf,sf) is established, 
(2) in driver.m  where the obstacles are established, 
(3) in driver.m  where the optimal path is resolved and 
(4) in plotPath.m where the plotting is done. 

I have included several .mat data files which include the data used to
make the plots from the paper. The script makeImages.m produces the 
images from the manuscript (assuming you have loaded the correct 
data file). For the changing lanes example, there is a separate script
called plotChangingLanes.m. 

You can also view these as animations by loading the desired .mat at 
the top of plotPath.m and then running the plotPath.m script.
									
The files (car.mat, rotate.m and drawCar.m) are helpers called by 
plotPath.m to draw the car.

The script resolveAxis.m allows the user to choose the size of the 
animations plotted by plotPath.m with a black border.

The script drawRobot.m makes the first picture of the car (labeling
the different parameters) from the manuscript. 


						
							