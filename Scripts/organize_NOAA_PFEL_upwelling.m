%This script was used to organize and process NOAA PFEL upwelling data for
%3 stations in California. Data was download for monthly and daily indeces.
%Ultimately, only 2 upwelling stations were used for analysis.
%
%
%NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%COMPONENTS
%PART 1: Reformat the downloaded data into a column
%PART 2: Use daily values to calculate 15 day averages
%PART 3:Calculate monthly anomalies
%PART 4: Plot monthly anomaly time series

%% PART 1: Reformat the downloaded data into a column
%Each row as a date,rather than one row for each year

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/monthly_raw/temp/';
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/monthly/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-4);
    csv = readtable(fullfile(currentDir,file));
    
    %Define each column as variable
    jan=csv.JAN; feb=csv.FEB; mar=csv.MAR; apr=csv.APR; may=csv.MAY; jun=csv.JUN; 
    jul=csv.JUL; aug=csv.AUG; sep=csv.SEP; oct=csv.OCT; nov=csv.NOV; dec=csv.DEC;
    lat=csv.LATITUDE; lon=csv.LONGITUDE; lat = lat(1,1); lon = lon(1,1);
    year=csv.YEAR; 
    NEW_MAT = NaN(612,3); %year,month,data
    ind = 1; %set index counter for new matrix
    for ii = 1:height(csv) %iterate through each month of the year
        NEW_MAT(ind:(ind+11),1)= year(ii); %set the next 12 pts to have the given year
        %assign the 12 monthly values
        NEW_MAT(ind,2)= 01; NEW_MAT((ind+1),2)= 02; NEW_MAT((ind+2),2)= 03; NEW_MAT((ind+3),2)= 04; 
        NEW_MAT((ind+4),2)= 05; NEW_MAT((ind+5),2)= 06; NEW_MAT((ind+6),2)= 07; NEW_MAT((ind+7),2)= 08; 
        NEW_MAT((ind+8),2)= 09; NEW_MAT((ind+9),2)= 10; NEW_MAT((ind+10),2)= 11; NEW_MAT((ind+11),2)= 12;
        %assign the data value
        NEW_MAT(ind,3)= jan(ii); NEW_MAT((ind+1),3)= feb(ii); NEW_MAT((ind+2),3)= mar(ii); NEW_MAT((ind+3),3)= apr(ii); 
        NEW_MAT((ind+4),3)= may(ii); NEW_MAT((ind+5),3)= jun(ii); NEW_MAT((ind+6),3)= jul(ii); NEW_MAT((ind+7),3)= aug(ii); 
        NEW_MAT((ind+8),3)= sep(ii); NEW_MAT((ind+9),3)= oct(ii); NEW_MAT((ind+10),3)= nov(ii); NEW_MAT((ind+11),3)= dec(ii);
        ind = ind + 12;
    end
    n = size(NEW_MAT,1);
    
    %Add lat and lon to table
    lat_array = repmat(lat,[n 1]); lat_array = array2table(lat_array,'VariableNames',{'LAT'});
    lon_array = repmat(lon,[n 1]); lon_array = array2table(lon_array,'VariableNames',{'LON'});
    
    %Create new table
    NEW_MAT = array2table(NEW_MAT,'VariableNames',{'YYYY','MM','Index'});
    mastermat = [lat_array,lon_array,NEW_MAT];
    writetable(mastermat,[newDir,name,'.csv']); %saves file as a new 'monthly' csv
end

%% PART 2: Use daily values to calculate 15 day averages

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/daily/';
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/15day/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-10);
    csv = readtable(fullfile(currentDir,file));
    
    up_index = csv.Index;  %grabs columns with these specific titles from input file
    %grab single value for lat, lon, station

    [unique_yrmon] = unique(csv(:,1:2),'rows'); %finds unique years and months from the year/month columns in input file
    pts =(height(csv)); 
    new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into 15ish day groups
    NEW_DATES = NaN(1,3); %will contain a new date label for each 15 day group, cannot predefine the size of the array because we don't know yet
    ind = 1; %counter for the current index
    for ii = 1:height(unique_yrmon)
        %early_month finds the indexes of the days within the given unique
        %year/month of day 15 or less, and late_month finds anything with a
        %day 16 or greater
        early_month = find(table2array(csv(:,1))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,2))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,3))<=15);
        late_month = find(table2array(csv(:,1))==table2array(unique_yrmon(ii,1)) & table2array(csv(:,2))==table2array(unique_yrmon(ii,2)) & table2array(csv(:,3))>15);
 
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
            %input new values for the dates for the final table
        end
    end    
    
    %accumarray takes new_ind which contains the reindex values, finds mean/min/max
    %at those indeces
    up_index_15day = array2table(accumarray(new_ind,up_index,[],@nanmean),'VariableNames',{'INDEX'});

    %create new arrays with station, lat, and lon that is the same size as
    %the new matrix
    n = size(NEW_DATES,1);
    NEW_DATES = array2table(NEW_DATES,'VariableNames',{'YYYY','MM','DD'});

    %concatenate to create on table 
    mastermat = [NEW_DATES,up_index_15day];
    writetable(mastermat,[newDir,name,'_15day.csv']); %saves file as a new 'daily' csv
    
end

%% PART 3:Calculate monthly anomalies
%NOTE: The data source provides monthly anomalies, however these anomalies 
%are not reflective of our short study period from 2003-2018

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/monthly/';
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Data/NOAA_PFEL_upwelling/monthly_anomalies/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-4);
    csv = readtable(fullfile(currentDir,file));
    
    %grab columns with these specific titles from input file
    index = csv.Index;
    lat = array2table(csv.LAT,'VariableNames',{'LAT'}); 
    lon = array2table(csv.LON,'VariableNames',{'LON'}); 
    year = array2table(csv.YYYY,'VariableNames',{'YYYY'});
    month = csv.MM;
    
    %Calculate climatologies
    climatologies = NaN(12,1);
    for ii = 1:12
        indeces_of_month = find(month==ii);
        index_clim=nanmean(index(indeces_of_month));
        climatologies(ii,1)=index_clim; 
    end
    
    %Calculate anomalies
    anomalies = NaN(height(csv),1);
    for iii = 1:height(csv)
        mon = month(iii);
        anomalies(iii,1) = index(iii)-climatologies(mon,1);
    end   
    
    anomalies = array2table(anomalies,'VariableNames',{'INDEX'});
    month = array2table(month,'VariableNames',{'MM'});
    %concatenate to create on table 
    mastermat = [lat,lon,year,month,anomalies];
    writetable(mastermat,[newDir,name,'_anomalies.csv']); %saves file as a new csv
    
end

%% PART 4: Plot monthly anomaly time series

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/NOAA_PFEL_upwelling/monthly/monthly_anomalies/in_bounding_box/renamed/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255]
dev_red = [192/255 74/255 74/255];

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-22);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    
    %This loop manually assigns an order to the locations (North to South)
    if i==1 %North
        subplot(length(fileList),1,1)
    elseif i==2 %South
        subplot(length(fileList),1,2)
    end

    %create red bars for a positive values and blue bars for negative values
    neg=csv.INDEX;
    neg(neg>0)=nan;
    pos=csv.INDEX;
    pos(pos<0)=nan;
    
    %%%Left Axis
    yyaxis left
    
    neg_chart = bar(neg,'FaceColor',dev_blue);
    hold on
    pos_chart=bar(pos,'FaceColor',dev_red);
    hold on
    
    ylim([-120 120]);
    axes = gca;
    axes.YColor = 'k';
    ylabel('m^3/second/100m','Color','k');
    
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
    if i == 1 %place title above SF, which should be the first plot
        title('NOAA PFEL Upwelling Monthly Anomalies 2003-2018');
    end
    
end