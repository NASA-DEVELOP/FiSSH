%This script takes data from CSV files and outputs a CSV file with daily,
%15day, & monthly mean, min, and max. Original use for NOAA Bouy Data.
%Runs on files of the title format 'buoy_names.xlsx' or 'buoy_names.csv' containing data in table format with the following column header: 
%         "STATION LAT LON YYYY MM DD WD WSPD ATMP WTMP"
%
%Lexi Jones
%6/21/2018
%
%NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%COMPONENTS
% PART 1: Output files with daily mean, min, max for each buoy

%% PART 1: Output files with daily mean, min, max for each buoy

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/raw/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/temp/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(6:end-4);
    csv = readtable(fullfile(currentDir,file));
   
    wspd = csv.WSPD; atmp = csv.ATMP; wtmp = csv.WTMP; %grabs columns with these specific titles 
    %grab single value for lat, lon, station
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = name; 
    
    %This if catch resolves a previous issue where some csv columns were
    %being imported as cell arrays and some as double arrays.
    if iscell(wspd)
        wspd = str2double(wspd);
    end
    if iscell(atmp)
        atmp = str2double(atmp);
    end
    if iscell(wtmp)
        wtmp = str2double(wtmp);
    end
    
    %new_ind reindexes the data points from the same days in csv 
    [unique_dates,~,new_ind] = unique(csv(:,4:6),'rows'); 
    wspd_mean = array2table(accumarray(new_ind,wspd,[],@nanmean),'VariableNames',{'WSPDmean'});
    wspd_min = array2table(accumarray(new_ind,wspd,[],@nanmean),'VariableNames',{'WSPDmin'});
    wspd_max = array2table(accumarray(new_ind,wspd,[],@nanmean),'VariableNames',{'WSPDmax'});
    atmp_mean = array2table(accumarray(new_ind,atmp,[],@nanmean),'VariableNames',{'ATMPmean'});
    atmp_min = array2table(accumarray(new_ind,atmp,[],@nanmean),'VariableNames',{'ATMPmin'});
    atmp_max = array2table(accumarray(new_ind,atmp,[],@nanmean),'VariableNames',{'ATMPmax'});
    wtmp_mean = array2table(accumarray(new_ind,wtmp,[],@nanmean),'VariableNames',{'WTMPmean'});
    wtmp_min = array2table(accumarray(new_ind,wtmp,[],@nanmean),'VariableNames',{'WTMPmin'});
    wtmp_max = array2table(accumarray(new_ind,wtmp,[],@nanmean),'VariableNames',{'WTMPmax'});
    
    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(unique_dates,1);
    station_array = repmat(station,[n 1]); station_array = array2table(cellstr(station_array),'VariableNames',{'STATION'}); 
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create on table 
    mastermat = [station_array,lat_array,lon_array,unique_dates,wspd_mean,wspd_min,wspd_max,atmp_mean,atmp_min,atmp_max,wtmp_mean,wtmp_min,wtmp_max];
    writetable(mastermat,[newDir,name,'_daily.csv']); %saves file as a new 'daily' csv
    
end

%% go through daily files and add nan rows for days not present, and remove anything before 2003

clear
currentDir =  '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%create arrays of the years and months 
years = (2003:2018); years = years(:); 
months = (1:12); months = months(:);

for j = 1:length(fileList)
    file = fileList(j).name; 
    name = file(1:end-4);
    csv = readtable(fullfile(currentDir,file));
    
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = csv.STATION; station = station(1,1);
    
    %add in loop to start table at 2003
    csv_years = csv.YYYY;
    for jj = 1:height(csv)
        if csv_years(jj) < 2003
            continue
        else
            strt = jj;
            break
        end
    end
    
    %add in loop to prevent iterating through empty NaN rows
    for jjj = 1:height(csv)
        if isnan(csv_years(jjj))
            endd = jjj-1;
            break
        elseif jjj == height(csv)
            endd = jjj;
            break
        else
            continue
        end
    end
    
    table = csv(strt:endd,4:15);
    
    count = 0; %counter for index in csv file
    for i = 1:length(years) %loop through years
        for ii = 1:length(months) %loop through months
            if i==2 || i==6 || i==10 || i==14 % if year is leap year -- 2004,2008,2012,2016
                if ii==2
                    days = (1:29); %29 days if leap year
                end
            else
                if ii==2
                    days = (1:28); %28 days if not leap year
                end
            end
            if ii==1 || ii==3 || ii==5 || ii==7 || ii==8 || ii==10 || ii==12 %all 31 day months
                days = (1:31);
            elseif ii==4 || ii==6 || ii==9 || ii==11 %all 30 day months
                days = (1:30);
            end
            days = days(:);
            if (i == 16 && ii == 7) %no data past 6/2018
                break
            else
                for iii = 1:length(days) %loop through the two 15day sets in each month
                    ind = find(csv.YYYY == years(i) & csv.MM == months(ii) & csv.DD == days(iii));      
                    if isempty(ind)
                        new_row = NaN(1,12);
                        new_row(1,1) = years(i);
                        new_row(1,2) = months(ii);
                        new_row(1,3) = days(iii);
                        new_row = array2table(new_row,'VariableNames',{'YYYY','MM','DD','WSPDmean','WSPDmin','WSPDmax','ATMPmean','ATMPmin','ATMPmax','WTMPmean','WTMPmin','WTMPmax'});
                        table = [table(1:count,:); new_row; table(count+1:height(table),:)];
                    end             
                    count = count + 1;
                end
            end  
        end
    end
    
    %create new station, lat, and lon arrays
    n = size(table,1);
    if iscell(station)
        station_array = repmat(station,[n 1]); station_array = array2table(station_array,'VariableNames',{'STATION'}); 
    else isnumeric(station)
        station_array = num2cell(repmat(station,[n 1])); station_array = array2table(station_array,'VariableNames',{'STATION'});
    end
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create one table 
    mastermat = [station_array,lat_array,lon_array,table];
    writetable(mastermat,[newDir,name,'_all_days.csv']); %saves file as a new csv
end

%% Create new daily file combining Santa Barbara stations 46053 + NTBC1

clear

newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/'; %directory to put the new files
path1 = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/46053_daily_all_days.csv';
path2 = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/NTBC1_daily_all_days.csv';

csv1 = readtable(fullfile(path1));
csv2 = readtable(fullfile(path2));
data1 = table2array(csv1(:,7:15));
data2 = table2array(csv2(:,7:15));
table = NaN(height(csv1),9); %new matrix to hold the averaged data
for i = 1:height(csv1)
    wspdmean = NaN(1,2); wspdmin = NaN(1,2); wspdmax = NaN(1,2);
    atmpmean = NaN(1,2); atmpmin = NaN(1,2); atmpmax = NaN(1,2);
    wtmpmean = NaN(1,2); wtmpmin = NaN(1,2); wtmpmax = NaN(1,2);
    
    wspdmean(1,1)=data1(i,1);wspdmean(1,2)=data2(i,1);
    wspdmin(1,1)=data1(i,2);wspdmin(1,2)=data2(i,2);
    wspdmax(1,1)=data1(i,3);wspdmax(1,2)=data2(i,3);
    
    atmpmean(1,1)=data1(i,4);atmpmean(1,2)=data2(i,4);
    atmpmin(1,1)=data1(i,5);atmpmin(1,2)=data2(i,5);
    atmpmax(1,1)=data1(i,6);atmpmax(1,2)=data2(i,6);
    
    wtmpmean(1,1)=data1(i,7);wtmpmean(1,2)=data2(i,7);
    wtmpmin(1,1)=data1(i,8);wtmpmin(1,2)=data2(i,8);
    wtmpmax(1,1)=data1(i,9);wtmpmax(1,2)=data2(i,9);
    
    table(i,1)=nanmean(wspdmean);
    table(i,2)=nanmean(wspdmin);
    table(i,3)=nanmean(wspdmax);
    table(i,4)=nanmean(atmpmean);
    table(i,5)=nanmean(atmpmin);
    table(i,6)=nanmean(atmpmax);
    table(i,7)=nanmean(wtmpmean);
    table(i,8)=nanmean(wtmpmin);
    table(i,9)=nanmean(wtmpmax);
end
table = array2table(table,'VariableNames',{'WSPDmean','WSPDmin','WSPDmax','ATMPmean','ATMPmin','ATMPmax','WTMPmean','WTMPmin','WTMPmax'});
mastermat = [csv1(:,1:6),table];
writetable(mastermat,[newDir,'46053_&_NTBC1_daily_all_days.csv']); %saves file as a new csv


%% Output files with 15 day mean, min, max for each buoy BASED on daily mean, min, max

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/15day/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-19);
    csv = readtable(fullfile(currentDir,file));
   
    wspd_mean = csv.WSPDmean; atmp_mean = csv.ATMPmean; wtmp_mean = csv.WTMPmean; %grabs columns with these specific titles from input file
    wspd_min = csv.WSPDmin; atmp_min = csv.ATMPmin; wtmp_min = csv.WTMPmin;
    wspd_max = csv.WSPDmax; atmp_max = csv.ATMPmax; wtmp_max = csv.WTMPmax;
    %grab single value for lat, lon, station
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = name; 
    
    [unique_yrmon] = unique(csv(:,4:5),'rows'); %finds unique years and months from the year/month columns in input file
    pts =(height(csv)); 
    new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into 15ish day groups
    NEW_DATES = NaN(1,3); %will contain a new date label for each 15 day group
    ind = 1;
    for ii = 1:height(unique_yrmon)
        days = csv(:,6); 
        %early_month finds the indexes of the days within the given unique
        %year/month of day 15 or less, and late_month finds anything with a
        %day 16 or greater
        early_month = find(table2array(csv(:,4))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,5))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,6))<=15);
        late_month = find(table2array(csv(:,4))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,5))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,6))>15);
        
        %NOTE: It is important to catch the following different senarios if there
        %is gaps in the data within a given month!!!
        
        %scenario where dates are only in the late month
        if isempty(early_month) && ~isempty(late_month)
            new_ind(late_month) = ind;
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 16;
            ind = ind+1;
        
        %scenario where dates are only in the early month
        elseif ~isempty(early_month) && isempty(late_month)  
            new_ind(early_month) = ind;
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 1;
            ind = ind+1;
            
        %scenario where dates in both the early and late month are present
        else
            %reindex so that each month has 2 indeces (for ex. month 1 has
            %indeces 1,2 ; month 2 has indeces 3,4 ; month 3 has indeces 5, 6;
            %if you look at the math, the second number is always double the
            %month and the first number is double - 1 :) 
            new_ind(early_month) = ind; 
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 1;
            ind = ind+1;
            new_ind(late_month) = ind;
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 16;
            ind = ind+1;
        end

    end    
    
    %accumarray is nifty all i gotta say. Takes new_ind which contains the reindex values, finds mean/min/max
    %at those indeces
    wspd_15day_mean = array2table(accumarray(new_ind,wspd_mean,[],@nanmean),'VariableNames',{'WSPDmean'});
    wspd_15day_min = array2table(accumarray(new_ind,wspd_min,[],@nanmean),'VariableNames',{'WSPDmin'});
    wspd_15day_max = array2table(accumarray(new_ind,wspd_max,[],@nanmean),'VariableNames',{'WSPDmax'});
    atmp_15day_mean = array2table(accumarray(new_ind,atmp_mean,[],@nanmean),'VariableNames',{'ATMPmean'});
    atmp_15day_min = array2table(accumarray(new_ind,atmp_min,[],@nanmean),'VariableNames',{'ATMPmin'});
    atmp_15day_max = array2table(accumarray(new_ind,atmp_max,[],@nanmean),'VariableNames',{'ATMPmax'});
    wtmp_15day_mean = array2table(accumarray(new_ind,wtmp_mean,[],@nanmean),'VariableNames',{'WTMPmean'});
    wtmp_15day_min = array2table(accumarray(new_ind,wtmp_min,[],@nanmean),'VariableNames',{'WTMPmin'});
    wtmp_15day_max = array2table(accumarray(new_ind,wtmp_max,[],@nanmean),'VariableNames',{'WTMPmax'});
    
    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(NEW_DATES,1);
    NEW_DATES = array2table(NEW_DATES,'VariableNames',{'YYYY','MM','DD'});
    station_array = repmat(station,[n 1]); station_array = array2table(cellstr(station_array),'VariableNames',{'STATION'}); 
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create on table 
    mastermat = [station_array,lat_array,lon_array,NEW_DATES,wspd_15day_mean,wspd_15day_min,wspd_15day_max,atmp_15day_mean,atmp_15day_min,atmp_15day_max,wtmp_15day_mean,wtmp_15day_min,wtmp_15day_max];
    writetable(mastermat,[newDir,name,'_15day.csv']); %saves file as a new 'daily' csv
    
end

%% Output files with monthly mean, min, max for each buoy BASED on daily mean, min, max

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/daily/daily_all_days/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/monthly/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-19);
    csv = readtable(fullfile(currentDir,file));
   
    wspd_mean = csv.WSPDmean; atmp_mean = csv.ATMPmean; wtmp_mean = csv.WTMPmean; %grabs columns with these specific titles from input file
    wspd_min = csv.WSPDmin; atmp_min = csv.ATMPmin; wtmp_min = csv.WTMPmin;
    wspd_max = csv.WSPDmax; atmp_max = csv.ATMPmax; wtmp_max = csv.WTMPmax;
    %grab single value for lat, lon, station
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = name; 
    
    [unique_yrmon] = unique(csv(:,4:5),'rows'); %finds unique years and months from the year/month columns in input file
    pts =(height(csv)); 
    new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into 15ish day groups
    NEW_DATES = NaN((height(unique_yrmon)),3); %will contain a new date label for each 15 day group
    for ii = 1:height(unique_yrmon)
        days_in_month = find(table2array(csv(:,4))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,5))==table2array(unique_yrmon(ii,2)));
        %reindex so that each month has 1 index (for ex. month 1 has
        %index 1 ; month 2 has index 2;)
        new_ind(days_in_month) = ii; 
        %input new values for the dates for the final table
        NEW_DATES(ii,1) = table2array(unique_yrmon(ii,1));
        NEW_DATES(ii,2) = table2array(unique_yrmon(ii,2));
        NEW_DATES(ii,3) = 1;
    end    
    
    %accumarray is nifty all i gotta say. Takes new_ind which contains the reindex values, finds mean/min/max
    %at those indeces
    wspd_month_mean = array2table(accumarray(new_ind,wspd_mean,[],@nanmean),'VariableNames',{'WSPDmean'});
    wspd_month_min = array2table(accumarray(new_ind,wspd_min,[],@nanmean),'VariableNames',{'WSPDmin'});
    wspd_month_max = array2table(accumarray(new_ind,wspd_max,[],@nanmean),'VariableNames',{'WSPDmax'});
    atmp_month_mean = array2table(accumarray(new_ind,atmp_mean,[],@nanmean),'VariableNames',{'ATMPmean'});
    atmp_month_min = array2table(accumarray(new_ind,atmp_min,[],@nanmean),'VariableNames',{'ATMPmin'});
    atmp_month_max = array2table(accumarray(new_ind,atmp_max,[],@nanmean),'VariableNames',{'ATMPmax'});
    wtmp_month_mean = array2table(accumarray(new_ind,wtmp_mean,[],@nanmean),'VariableNames',{'WTMPmean'});
    wtmp_month_min = array2table(accumarray(new_ind,wtmp_min,[],@nanmean),'VariableNames',{'WTMPmin'});
    wtmp_month_max = array2table(accumarray(new_ind,wtmp_max,[],@nanmean),'VariableNames',{'WTMPmax'});
    
    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(NEW_DATES,1);
    NEW_DATES = array2table(NEW_DATES,'VariableNames',{'YYYY','MM','DD'});
    station_array = repmat(station,[n 1]); station_array = array2table(cellstr(station_array),'VariableNames',{'STATION'}); 
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create on table 
    mastermat = [station_array,lat_array,lon_array,NEW_DATES,wspd_month_mean,wspd_month_min,wspd_month_max,atmp_month_mean,atmp_month_min,atmp_month_max,wtmp_month_mean,wtmp_month_min,wtmp_month_max];
    writetable(mastermat,[newDir,name,'_monthly.csv']); %saves file as a new 'daily' csv
    
end


%% monthly climatologies & anomalies

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/monthly/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/monthly/monthly_anomalies/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-4);
    csv = readtable(fullfile(currentDir,file));

    %grab columns with these specific titles from input file
    lat = array2table(csv.LAT,'VariableNames',{'LAT'}); 
    lon = array2table(csv.LON,'VariableNames',{'LON'}); 
    station = array2table(csv.STATION,'VariableNames',{'STATION'});
    year = array2table(csv.YYYY,'VariableNames',{'YYYY'});  
    day = array2table(csv.DD,'VariableNames',{'DD'});
    month = csv.MM;
    
    wspd_mean = csv.WSPDmean; atmp_mean = csv.ATMPmean; wtmp_mean = csv.WTMPmean; %grabs columns with these specific titles from input file
    wspd_min = csv.WSPDmin; atmp_min = csv.ATMPmin; wtmp_min = csv.WTMPmin;
    wspd_max = csv.WSPDmax; atmp_max = csv.ATMPmax; wtmp_max = csv.WTMPmax;
    
    climatologies = NaN(12,9);
    for ii = 1:12
        indeces_of_month = find(month==ii);
        wspd_mean_clim=nanmean(wspd_mean(indeces_of_month));
        wspd_min_clim=nanmean(wspd_min(indeces_of_month));
        wspd_max_clim=nanmean(wspd_max(indeces_of_month));
        atmp_mean_clim=nanmean(atmp_mean(indeces_of_month));
        atmp_min_clim=nanmean(atmp_min(indeces_of_month));
        atmp_max_clim=nanmean(atmp_max(indeces_of_month));
        wtmp_mean_clim=nanmean(wtmp_mean(indeces_of_month));
        wtmp_min_clim=nanmean(wtmp_min(indeces_of_month));
        wtmp_max_clim=nanmean(wtmp_max(indeces_of_month));
        climatologies(ii,1)=wspd_mean_clim; 
        climatologies(ii,2)=wspd_min_clim; 
        climatologies(ii,3)=wspd_max_clim;
        climatologies(ii,4)=atmp_mean_clim; 
        climatologies(ii,5)=atmp_min_clim; 
        climatologies(ii,6)=atmp_max_clim;
        climatologies(ii,7)=wtmp_mean_clim; 
        climatologies(ii,8)=wtmp_min_clim; 
        climatologies(ii,9)=wtmp_max_clim;
    end
    
    anomalies = NaN(height(csv),9);
    for iii = 1:height(csv)
        mon = month(iii);
        anomalies(iii,1) = wspd_mean(iii)-climatologies(mon,1);
        anomalies(iii,2) = wspd_min(iii)-climatologies(mon,2);
        anomalies(iii,3) = wspd_max(iii)-climatologies(mon,3);
        anomalies(iii,4) = atmp_mean(iii)-climatologies(mon,4);
        anomalies(iii,5) = atmp_min(iii)-climatologies(mon,5);
        anomalies(iii,6) = atmp_max(iii)-climatologies(mon,6);
        anomalies(iii,7) = wtmp_mean(iii)-climatologies(mon,7);
        anomalies(iii,8) = wtmp_min(iii)-climatologies(mon,8);
        anomalies(iii,9) = wtmp_max(iii)-climatologies(mon,9);
    end   
    
    anomalies = array2table(anomalies,'VariableNames',{'WSPDmean','WSPDmin','WSPDmax','ATMPmean','ATMPmin','ATMPmax','WTMPmean','WTMPmin','WTMPmax'});
    month = array2table(month,'VariableNames',{'MM'});
    %concatenate to create on table 
    mastermat = [station,lat,lon,year,month,day,anomalies];
    writetable(mastermat,[newDir,name,'_anomalies.csv']); %saves file as a new 'monthly' csv
    
end
    

%% Plot anomalies

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_NDBC_water_temp/monthly/monthly_anomalies/in_bounding_box/renamed/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Figure window
clf
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-22);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    
    %This loop manually assigns an order to the locations (North to South)
    if i==1 %Malibu & Cabrillo
        subplot(length(fileList),1,5)
    elseif i==2 %Monterey
        subplot(length(fileList),1,2)
    elseif i==3 %Orange & Oceanside
        subplot(length(fileList),1,6)
    elseif i==4 %SF
        subplot(length(fileList),1,1)
    elseif i==5 %San Diego
        subplot(length(fileList),1,7)
    elseif i==6 %Santa Barbara
        subplot(length(fileList),1,3)
    elseif i==7 %Ventura
        subplot(length(fileList),1,4)
    end

    %create red bars for a positive values and blue bars for negative values
    neg=csv.WTMPmean;
    neg(neg>0)=nan;
    pos=csv.WTMPmean;
    pos(pos<0)=nan;
    
    %%%Left Axis
    yyaxis left
    
    neg_chart = bar(neg,'FaceColor',dev_blue);
    hold on
    pos_chart=bar(pos,'FaceColor',dev_red);
    hold on
    
    ylim([-5 5]);
    axes = gca;
    axes.YColor = 'k';
    ylabel('C\circ','Color','k');
    
    %%%Right Axis
    yyaxis right
    
    %plot dotted lines between years
     for j= 12:12:190
         x = line([j j],[-50 50]);
         set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
         set(gca,'YTickLabel',[]); %removes y axes labels associated with dotted lines
     end
    
    %Add labels and format axis
    xticks(6:12:365); %
    xlim([0 190]);
    xticklabels({'2003','2004','2005','2006','2007','2008'...
         ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    ylabel(newName);
    axes = gca;
    axes.YColor = 'k';
    axes.TickLength = [0 0];
    
    %Title on first graph only
    if i == 4 %place title above SF, which should be the first plot
        title('NOAA NDBC Water Temperature Monthly Anomalies 2003-2018');
    end
    
end
