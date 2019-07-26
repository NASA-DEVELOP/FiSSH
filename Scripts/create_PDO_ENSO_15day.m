%NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%COMPONENTS
%PART 1: Reformat PDO so that year and month are in seperate columns
%PART 2: Reformat ENSO so that year and month are in seperate columns

%% PART 1: Reformat PDO so that year and month are in seperate columns

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/PDO/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/PDO/15day'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention
file = fileList(1).name; 
name = 'PDO';
csv = readtable(fullfile(currentDir,file));

%Define date variables 
date = csv.date;
year = NaN(size(date)); month = NaN(size(date));

%Loop through dates to create temp vectors
for i = 1:length(date)
    temp = num2str(date(i));  
    year(i) = str2double(temp(1:4));
    month(i) = str2double(temp(5:6));
end

NEW_MAT = NaN(); % empty matrix

%Fill in NEW_MAT with values
for ii = 1:length(year)
    NEW_MAT(ii*2,1) = year(ii,1);
    NEW_MAT(((ii*2)-1),1) = year(ii,1);
    NEW_MAT(ii*2,2) = month(ii,1);
    NEW_MAT(((ii*2)-1),2) = month(ii,1);
    NEW_MAT(ii*2,3) = csv.value(ii);
    NEW_MAT(((ii*2)-1),3) = csv.value(ii);
end

%Output table
table = array2table(NEW_MAT,'VariableNames',{'YYYY','MM','PDO_Index'});
mastermat = [table];
writetable(mastermat,[newDir,'PDO_Index_15day.csv']); %saves file as a new csv

%% PART 2: Reformat ENSO so that year and month are in seperate columns

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/ENSO/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/ENSO/15day/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention
file = fileList(1).name; 
name = 'ENSO';
csv = readtable(fullfile(currentDir,file));
date = csv.date;
year = NaN(size(date)); month = NaN(size(date));

%Loop through dates to create temp vectors
for i = 1:length(date)
    temp = num2str(date(i));  
    year(i) = str2double(temp(1:4));
    month(i) = str2double(temp(5:6));
end

NEW_MAT = NaN();% empty matrix

%Fill in NEW_MAT with values
for ii = 1:length(year)
    NEW_MAT(ii*2,1) = year(ii,1);
    NEW_MAT(((ii*2)-1),1) = year(ii,1);
    NEW_MAT(ii*2,2) = month(ii,1);
    NEW_MAT(((ii*2)-1),2) = month(ii,1);
    NEW_MAT(ii*2,3) = csv.anom(ii);
    NEW_MAT(((ii*2)-1),3) = csv.anom(ii);
end

%Output table
table = array2table(NEW_MAT,'VariableNames',{'YYYY','MM','ENSO_Index'});
mastermat = [table];
writetable(mastermat,[newDir,'ENSO_Index_15day.csv']); %saves file as a new csv