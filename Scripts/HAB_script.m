%
%NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
% HAB yourself a merry little grunion run
% Objective:    uses HAB data for chlorophyll-a and pseudo-nitzschia
%               pulled down for 8 stations from 2009 to 2018 to compute
%               15-day and monthly means with climatologies and anomalies


%COMPONENTS
%Episode 1: Compute output tables containing 15-day means
%Episode II: Compute output tables containing monthly means
%Episode III: Calculate monthly climatologies and anomalies

%%
% Episode I: The Phyto Menace
%   (computes output tables containing 15-day means)

%Clear GUI, set directories
clc
clear
currentDir = 'C:\Users\hknapp\Desktop\HAB_processing\input_tables\'; %directory containing files (one for each pier)
newDir = 'C:\Users\hknapp\Desktop\HAB_processing\mean_tables\'; %directory for new files

%Start file cycle
fileList = dir(fullfile(currentDir,'*.csv'));
for i = 1:length(fileList)
    file = fileList(i).name; %file name w/ .csv
    [~,name,~] = fileparts(file); %returns the name of the file w/o .csv
    csv = readtable(fullfile(currentDir,file)); %creates a temp csv for the current file
    
    %Grabs columns, gets station name/value for lat and lon
    chl = csv.CHL; pn = csv.PN;
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = csv.STATION; station = station{1,1};
    
    [unique_yrmon] = unique(csv(:,1:2),'rows'); %finds unique years and months from the year/month columns in input file
    pts =(height(csv)); 
    new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into 15ish day groups
    NEW_DATES = NaN(1,3); %will contain a new date label for each 15 day group
    ind = 1; %counter for the current index
    
    for ii = 1:height(unique_yrmon)
        %early_month finds the indexes of the days within the given unique
        %year/month of day 15 or less, and late_month finds anything with a day 16 or greater
        early_month = find(table2array(csv(:,1))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,2))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,3))<=15);
        late_month = find(table2array(csv(:,1))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,2))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,3))>15);
        

        %NOTE: the following section catches possible gaps in each month

        %Scenario where dates are only in the late month
        if isempty(early_month) && ~isempty(late_month)
            new_ind(late_month) = ind;
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 16;
            ind = ind+1;
        
        %Scenario where dates are only in the early month
        elseif ~isempty(early_month) && isempty(late_month)  
            new_ind(early_month) = ind;
            NEW_DATES(ind,1) = table2array(unique_yrmon(ii,1));
            NEW_DATES(ind,2) = table2array(unique_yrmon(ii,2));
            NEW_DATES(ind,3) = 1;
            ind = ind+1;
            
        %Scenario where dates in both the early and late month are present
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
            %input new values for the dates for the final table
        end
        
    end    
    
    %"accumarray is nifty all i gotta say. Takes new_ind which contains the reindex values, finds mean/min/max
    %at those indeces"
    chl_15day_mean = array2table(accumarray(new_ind,chl,[],@nanmean),'VariableNames',{'CHL'});
    pn_15day_mean = array2table(accumarray(new_ind,pn,[],@nanmean),'VariableNames',{'PN'});
    
    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(NEW_DATES,1);
    NEW_DATES = array2table(NEW_DATES,'VariableNames',{'YYYY','MM','DD'});
    station_array = repmat(station,[n 1]); station_array = array2table(cellstr(station_array),'VariableNames',{'STATION'}); 
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create on table 
    mastermat = [station_array,lat_array,lon_array,NEW_DATES,chl_15day_mean,pn_15day_mean];
    writetable(mastermat,[newDir,name,'_15day.csv']); %saves file as a new 'daily' csv
    
end

%%
% Episode II: Attack of the Foams
%   (computes output tables containing monthly means)

%Clear GUI, set directories
clear
currentDir = 'C:\Users\hknapp\Desktop\HAB_processing\input_tables\'; %directory containing files (one for each pier)
newDir = 'C:\Users\hknapp\Desktop\HAB_processing\mean_tables\'; %directory for new files

%Start file cycle
fileList = dir(fullfile(currentDir,'*.csv'));
for i = 1:length(fileList)
    file = fileList(i).name; %file name w/ .csv
    [~,name,~] = fileparts(file); %returns the name of the file w/o .csv
    csv = readtable(fullfile(currentDir,file)); %creates a temp csv for the current file
    
    %Grabs columns, gets station name/value for lat and lon
    chl = csv.CHL; pn = csv.PN;
    lat = csv.LAT; lon = csv.LON; lat = lat(1,1); lon = lon(1,1);
    station = csv.STATION; station = station{1,1};
    
    [unique_yrmon] = unique(csv(:,1:2),'rows'); %finds unique years and months from the year/month columns in input file
    pts =(height(csv)); 
    new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into 15ish day groups
    NEW_DATES = NaN(1,3); %will contain a new date label for each 15 day group
    
    for ii = 1:height(unique_yrmon)
        days_in_month = find(table2array(csv(:,1))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,2))==table2array(unique_yrmon(ii,2)));
        %reindex so that each month has 1 index (for ex. month 1 has
        %index 1 ; month 2 has index 2;)
        new_ind(days_in_month) = ii; 
        %input new vaslues for the dates for the final table
        NEW_DATES(ii,1) = table2array(unique_yrmon(ii,1));
        NEW_DATES(ii,2) = table2array(unique_yrmon(ii,2));
        NEW_DATES(ii,3) = 1;
    end
    
    %"accumarray is nifty all i gotta say. Takes new_ind which contains the reindex values, finds mean/min/max
    %at those indeces"
    chl_month_mean = array2table(accumarray(new_ind,chl,[],@nanmean),'VariableNames',{'CHL'});
    pn_month_mean = array2table(accumarray(new_ind,pn,[],@nanmean),'VariableNames',{'PN'});
    
    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(NEW_DATES,1);
    NEW_DATES = array2table(NEW_DATES,'VariableNames',{'YYYY','MM','DD'});
    station_array = repmat(station,[n 1]); station_array = array2table(cellstr(station_array),'VariableNames',{'STATION'}); 
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %concatenate to create on table 
    mastermat = [station_array,lat_array,lon_array,NEW_DATES,chl_month_mean,pn_month_mean];
    writetable(mastermat,[newDir,name,'_month.csv']); %saves file as a new 'daily' csv
    
end

%%
% Episode III: Revenge of the TIFFs
%   (calculates monthly climatologies and anomalies)

%Clear GUI, set directories
clear
currentDir = 'C:\Users\hknapp\Desktop\HAB_processing\mean_tables\'; %directory containing files (one for each pier)
newDir = 'C:\Users\hknapp\Desktop\HAB_processing\anomalies_tables\'; %directory for new files

%Start file cycle
fileList = dir(fullfile(currentDir,'*month.csv')); %finds all of the files in the current directory with .csv extention

for i = 1:length(fileList)
    file = fileList(i).name; 
    [~,name,~] = fileparts(file); %returns the name of the file w/o .csv
    csv = readtable(fullfile(currentDir,file));

    %grab columns with these specific titles from input file
    chl = csv.CHL; pn = csv.PN;
    lat = array2table(csv.LAT,'VariableNames',{'LAT'}); 
    lon = array2table(csv.LON,'VariableNames',{'LON'}); 
    station = array2table(csv.STATION,'VariableNames',{'STATION'});
    year = array2table(csv.YYYY,'VariableNames',{'YYYY'});  
    day = array2table(csv.DD,'VariableNames',{'DD'});
    month = csv.MM;
    
    %Calculate climatologies
    climatologies = NaN(12,3);
    for ii = 1:12
        indeces_of_month = find(month==ii);
        chl_clim = nanmean(chl(indeces_of_month));
        pn_clim = nanmean(pn(indeces_of_month));
        climatologies(ii,1)=chl_clim; 
        climatologies(ii,2)=pn_clim; 
    end
    
    %Calculate anomalies
    anomalies = NaN(height(csv),2);
    for iii = 1:height(csv)
        mon = month(iii);
        anomalies(iii,1) = chl(iii)-climatologies(mon,1);
        anomalies(iii,2) = pn(iii)-climatologies(mon,2);
    end   
    
    anomalies = array2table(anomalies,'VariableNames',{'CHL','PN'});
    month = array2table(month,'VariableNames',{'MM'});
    %concatenate to create on table 
    mastermat = [station,lat,lon,year,month,day,anomalies];
    writetable(mastermat,[newDir,name,'_anomalies.csv']); %saves file as a new 'monthly' csv
    
end
