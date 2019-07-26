===============
OSCAR Surface currents
===============

Date Created: July 30, 2018

This MATLAB script organizes OSCAR current data and creates monthly movies. 

PART 1: Creates a date index for the downloaded data January 2002 to May 2018. OSCAR data is formatted into 5-day composites, and the index computes the date, beginning at the fifth of each month. 

PART 2: Finds the monthly mean by identifying and grouping values at indices from the same month and then averaging the values. 

PART 3: Uses monthly means matrix to create a movie. OSCAR data (vector format, u and v components) and is plotted as a quiver plot, with arrows showing magnitude and direction. The movie captures the loop through these monthly quiver plots. California coastline is added in through geoshow. 
Saved in AVI format. 

 Parameters
-------------
Input: Surface Current Data downloaded from OPeNDAP

Output: DATE.mat, master_monthly_oscar.mat, NEW_OSCAR_U, NEW_OSCAR_V, NEW_DATES, lat_lon.mat, figure1.avi

 Contact
---------
Name(s): Annemarie Peacock	
E-mail(s): annemariepeacock@berkeley.edu



