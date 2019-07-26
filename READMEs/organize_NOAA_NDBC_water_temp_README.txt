
================================
organize_NOAA_NDBC_water_temp.m
================================

Date Created: August 8, 2018

This script takes data from CSV files and outputs a CSV file with daily,
15day, & monthly mean, min, and max. Original use for NOAA Bouy Data.
Runs on files of the title format 'buoy_names.xlsx' or 'buoy_names.csv' containing data in table format with the following column header: 
         "STATION LAT LON YYYY MM DD WD WSPD ATMP WTMP"


Components
———————————
PART 1: Output files with daily mean, min, max for each buoy


Parameters
———————————

Input: NOAA NDBC water temperature csvs

Output: for each station:[daily.csv, all_days.csv, 15day.csv, monthly.csv, anomalies.csv] and one anomaly plot containing all the station’s data


Contact
————————
Name: Alexandra Jones
E-mail: lexxii1456@gmail.com