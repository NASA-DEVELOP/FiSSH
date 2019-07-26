===============
FiSSH
Finding Suitable Spawning Habitats
===============

NASA DEVELOP 2018 Summer JPL Southern California Water Resources II Team
Date Created: July, 2018

FiSSH uses a compilation of data products during the study range 2003-2018, and includes Grunion Greeters citizen science data, in situ 
measurements, and NASA Earth Observations. The Grunion is a fish endemic to California with a range historically in Southern California 
(San Diego to Santa Barbara), and a more recent expansion northward to Monterey and San Francisco in the past three decades. During a 
"grunion run", the fish spawns on the beach, riding the waves onshore to lay its eggs in the sand. This MATLAB app matches user input 
of chlorophyll-a levels, ocean temperature, and upwelling indices, to the most the similar conditions at a recorded grunion run from 
available data. It may be used to get an idea of the potential size of future grunion runs based on the conditions during past runs. 

The application was created using MATLAB's App Designer.


 Data Products
-------------
***All required data products are packaged with the app under the directory /mat_files/

Grunion Greeters data: Obtained from Dr. Karen Martin (Pepperdine University), recorded on the Walker Scale with values ranging from 0 to 5 
describing the size and intensity of grunion runs (0 as little to no fish and 5 as a maximum sized grunion run).

In situ measurements: 
	NOAA PFEL Coastal Upwelling Index 
	NOAA NDBC Buoy Water Temperature
	SCCOOS HABs
	NOAA NCEI Air Temperature

Climate indeces:
	NOAA NCEI ENSO
	NOAA NCEP PDO

NASA Earth Observations: 
	MUR SST - downloaded from NOAA’s data server Easier Access to Scientific Data (ERDDAP) 
	Aqua MODIS Chlorophyll-a - downloaded from NOAA’s data server Easier Access to Scientific Data (ERDDAP) 
	OSCAR Ocean Surface Current - downloaded from Open-source Project for Network Data Access Protocol (OPeNDAP)

NOTE: All downloaded data was processed in MATLAB into 15-day and monthly averages and saved into the .mat files that are packaged with the 
software application.

 Required Packages
===================
MATLAB

 Parameters
-------------

FiSSH Window
1. Select desired "Beach Region" to analyze, 9 options available
3. Check factors you wish to analyze and input numeric values. At least one factor must be checked.
* "Chlorophyll-a" is an average of in situ SCCOOS and satellite Aqua MODIS chlorophyll-a data
* "Ocean Temperature" is an average of in situ water temperature (NOAA Buoy Data) and satellite MUR SST
4. Select specific Month or choose "None" to analyze data from all months January 2004 to June 2018
5. Select the number of data points to output
6. Press "Find Closest Grunion Runs"
* FiSSH will not output data points if there are no data within the beach region and month selected.
Grunion spawning season is March through August, and limited Grunion Greeters data available for the rest of the year 
* If datapoints are available within the beach region and month, FiSSH searches through the "suitable data points" and outputs 
the number of selected data points with grunion run conditions that most closely match the searched factors (chlorophyll-a, 
temperature, upwelling values). Other information about the conditions at the grunion runs including the year, month, air temperature, 
pseudo-nitzschia, ENSO index, and PDO index are also in the output. 

Animations Window
1. Select the dataset to create satellite imagery video
2. Select time frame of video including start year, month, end year, month
3. Choose whether you want grunion run indicators overlayed on the map
4. Press "Create Map Videos" 
* Video will output via movie player and also be saved as a .avi file
NOTE: This is a beta version of the application, and the output for the video imagery is very slow

Contact
---------
Name(s): Alexandra Jones, Harrison Knapp, Annemarie Peacock, Lael Wakamatsu 
E-mail(s): lexxii1456@gmail.com