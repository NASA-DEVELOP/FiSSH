
=====================
orig_chl_a_LJedits.m
=====================

Date Created: August 8, 2018

This is a MATLAB script used to process and organize Aqua MODIS chlorophyll-a data. It creates several matrices to hold the original data, climatologies,15-day averages, monthly averages, bounding box, and the lat/lon of the study area. This script also creates chl-a movies and plots anomalies.

NOTE: Parts of this script are an adaptation of the 'orig_chl_a.m' script 
%from Term 1 of this project.

Components
———————————
PART 1: Create 15 day chl matrix
PART 2: Create monthly matrix for entire bounding box
PART 3: Subset 15day matrix into beach areas
PART 4: Create 15 day 2D chl matrices by bounding box for correlations
PART 5: Create monthly avg matrix by bounding box
PART 6: Create satellite imagery movies
PART 7: Plot monthly anomalies 

Parameters
———————————

Input: chlorophyll-a matrix downloaded from ERDDAP

Output: lat_lon.mat, master_chl_a.mat, master_monthly_chl_a.mat, master_15day_chl_a.mat, bounding_boxes_small.mat, sst_anomalies.mat


Contact
————————
Name: Alexandra Jones
E-mail: lexxii1456@gmail.com