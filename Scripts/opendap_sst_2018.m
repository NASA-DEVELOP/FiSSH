
% File: opendap_sst_2018.m
% Name: MUR SST
% Date: August 8, 2018
% contact: laelwakamatsu@gmail.com


%Build a .mat file of the required MUR SST
%Use OPeNDAP URLs
%2003 - 2018 All months
%Create time series maps
%California Oceans
%Grunions

%%%%%%%%%%%% PART 1 %%%%%%%%%%%%
%  FIND BOUNDING CA LAT, LON   %
%         CHECK DATA           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

%Bounding Box of CA Coast
bounding_box.lat = [32 39];
bounding_box.lon = [-124 -117];

%Beginning URL
url = 'https://opendap.jpl.nasa.gov:443/opendap/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/2003/091/20030401090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc';
url2 = 'https://opendap.jpl.nasa.gov:443/opendap/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/2002/153/20020602090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc?time[0:1:0],lat[12199:1:12898],lon[5599:1:6298],analysed_sst[0:1:0][12199:1:12898][5599:1:6298]';
%Pull out lat and lon vectors
lat=ncread(url,'lat');
lon=ncread(url,'lon');

%Find the lat and lon indices in the CA Coast bounding box
ilat = find(lat >= bounding_box.lat(1) & lat < bounding_box.lat(2));
ilon = find(lon >= bounding_box.lon(1) & lon < bounding_box.lon(2));

%Reduce lat and lon to bounding box and make double
lat = double(lat(ilat));
lon = double(lon(ilon));

%Define subset to cover bounding box
%lon,lat,time
stride = [1 1 1];
start = [min(ilon) min(ilat) 1];
count = [length(ilon) length(ilat) 1];

%Pull subsetted data to test
sst = ncread(url,'analysed_sst',start,count,stride);
sst = squeeze(sst); %Turn 2d

%Display lat and lon bounds
disp(['Lat: ',num2str(lat(1)),' to ',num2str(lat(end))])
disp(['Lat index: ',num2str(ilat(1)-1),' to ',num2str(ilat(end)-1)])
disp(['Lon: ',num2str(lon(1)),' to ',num2str(lon(end))])
disp(['Lon index: ',num2str(ilon(1)-1),' to ',num2str(ilon(end)-1)])
%NOTE: These indices are 1 index too far when entered directly in the
%OPeNDAP URL due to OPeNDAP indexing starting at 0 compared to MATLAB's
%indexing starting at 1. Must subtract 1 as done above.

%Save lat and lon to data directory
cd('/Users/lwakamat/Desktop/DEVELOP')
save('lat_lon.mat','lat','lon');

%%

%%%%%%%%%%%% PART 2 %%%%%%%%%%%%
%       BUILD .mat FILES       %
%     USE CONSTRUCTED URLS     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

%Load lat and lon
cd('/Users/lwakamat/Desktop/DEVELOP')
load('lat_lon.mat');

%URL components

years = 2003:1:2018;
months = 1:1:12;
leap_yrs = 2004:4:2016;

% months - julian 
jan_julian = 1:1:31;
feb_julian = 32:1:59;
mar_julian = 60:1:90;
apr_julian = 91:1:120;
may_julian = 121:1:151;
june_julian = 152:1:181;
july_julian = 182:1:212;
aug_julian = 213:1:243;
sep_julian = 244:1:273;
oct_julian = 274:1:304;
nov_julian = 305:1:334;
dec_julian = 335:1:365;

%https://opendap.jpl.nasa.gov:443/opendap/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/2002/153/20020602090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc?time[0:1:0],lat[12200:1:12899],lon[5600:1:6299],analysed_sst[0:1:0][12200:1:12899][5600:1:6299]
base_url = 'https://opendap.jpl.nasa.gov:443/opendap/allData/ghrsst/data/GDS2/L4/GLOB/JPL/MUR/v4.1/';
tail_url = '090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1.nc?time[0:1:0],lat[12199:1:12898],lon[5599:1:6298],analysed_sst[0:1:0][12199:1:12898][5599:1:6298]';

%Master data matrix
%(16 yrs * (365 days)) + 4(leap years)
%2018 added (181 days)

amjja_sst2=nan(5630,700,700);

%Count to index master data matrix
count=1;
catch_count = 1;
missing_date = [];

DATE = nan(5688,3);

%Loop through all the data and create a master .mat file
for i = 1:16 %2003 - 2018 has 16 years
    
    current_yr = years(i);
    
    DATE(i,1) = current_yr;
    
    %Check if the year is a leap year
    leap_check = any(leap_yrs==current_yr);
    
    if leap_check
        
        jan_julian = 1:1:31;
        feb_julian = 32:1:60;
        mar_julian = 61:1:91;
        apr_julian = 92:1:121;
        may_julian = 122:1:152;
        june_julian = 153:1:182;
        july_julian = 183:1:213;
        aug_julian = 214:1:244;
        sep_julian = 245:1:274;
        oct_julian = 275:1:305;
        nov_julian = 306:1:335;
        dec_julian = 336:1:366;
        
    end
    
    for ii = 1:12 %All months
        
        current_month = months(ii);
        
        if ii==6 && i==16 %%%%%% HERE %%%%%%
            break
        end
        
        %Different number of days depending on the month
        
        if current_month == 4 || current_month == 6 || current_month == 9 || current_month == 11
            days=1:30;
        elseif current_month == 2
            days=1:28;
        elseif leap_check && current_month == 2
            days=1:29;
        else
            days=1:31;
        end
        
        %Determine which julian set to use
        if current_month == 1
            julian_set = jan_julian;
        elseif current_month == 2
            julian_set = feb_julian;
        elseif current_month == 3
            julian_set = mar_julian;
        elseif current_month == 4
            julian_set = apr_julian;
        elseif current_month == 5
            julian_set = may_julian;
        elseif current_month == 6
            julian_set = june_julian;
        elseif current_month == 7
            julian_set = july_julian;
        elseif current_month == 8
            julian_set = aug_julian;
        elseif current_month == 9
            julian_set = sep_julian;
        elseif current_month == 10
            julian_set = oct_julian;
        elseif current_month == 11
            julian_set = nov_julian;
        elseif current_month == 12
            julian_set = dec_julian;
        end
        
        for iii = days
            
            %Add 1 day to julian day if it is a leap year
            if leap_check
                leap_add = 1;
            else
                leap_add = 0;
            end
            current_julian = julian_set(iii)+leap_add;
            
            try
                
                %Construct the OPeNDAP URL with the required components
                current_url = ([base_url,num2str(current_yr),'/',sprintf('%03d',current_julian),'/',num2str(current_yr),sprintf('%02d',current_month),sprintf('%02d',iii),tail_url]);
                current_date = num2str([current_yr,current_month,iii]);
                
                
                %Pull data from OPeNDAP URL
                current_sst = ncread(current_url,'analysed_sst');
                
            catch
                
                % add catch in case a date is skipped or not downloaded
                
                disp('cannot pull month, sorry');
                missing_date = strvcat(missing_date,current_date)
                catch_count = catch_count +1;
         
            end
            
            % put into mater SST matrix
            amjja_sst2(count,:,:)=current_sst;
            count=count+1;
            
        end
        
    end
    
end

% remove 'extra' space
amjja_sst2 = amjja_sst(1:5630,:,:);

save('everything_sst.mat','amjja_sst2','lat','lon','-v7.3');


%% CREATE DATE 
clc
clear

%Load lat and lon
cd('/Users/lwakamat/Desktop/DEVELOP')
load('lat_lon.mat');

%URL components

years = 2003:1:2018;
months = 1:1:12;
leap_yrs = 2004:4:2016;

count=1;
catch_count = 1;
missing_date = [];

DATE = nan(5630,3);

for i = 1:16 %2003 - 2018 has 16 years
    
    current_yr = years(i);
    
    %Check if the year is a leap year
    leap_check = any(leap_yrs==current_yr);
    
    for ii = 1:12 %All months
        
        current_month = months(ii);
        
        if ii==6 && i==16 %%%%%% change depending on present date %%%%%%
            break
        end
        
        %Different number of days depending on the month
        
        if current_month == 4 || current_month == 6 || current_month == 9 || current_month == 11
            days=(1:30);
        
        elseif leap_check && current_month == 2
            days=(1:29);
        
        elseif current_month == 2
            days=(1:28);
        
        else
            days=(1:31);
        
        end
        
        % Add the dates to a new array
        
        for iii = 1:length(days)
            current_days = days(iii);
            
            DATE(count,1) = current_yr;
            DATE(count,2) = current_month;
            DATE(count,3) = current_days;
        
            count=count+1;
            
        end
        
        
    end
    
end

save('everything_sst.mat','amjja_sst2','lat','lon','DATE','-v7.3');


%% 

%%%%%%%%%%%% PART 2a %%%%%%%%%%%
%      15 day - AVERAGES       %
%     STORE IN NEW MATRIX      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('everything_sst.mat')
load('bounding_boxes.mat')
% create for loop to take days 1:15 and 16:end_of_month and average
% 2 averages for each month 


%%%%%%%%%%%%%%% 15 DAY AVERAGES %%%%%%%%%%%%%%%%%

%Months
jan1=1:1:15;
jan2=16:1:31;
feb1=32:1:46;
feb2=47:1:59;
mar1=60:1:75;
mar2=76:1:90;
apr1=91:1:105;
apr2=106:1:120;
may1=121:1:135;
may2=136:1:151;
june1=152:1:166;
june2=167:1:181;
july1=182:1:197;
july2=198:1:212;
aug1=213:1:228;
aug2=229:1:243;
sep1=244:1:258;
sep2=259:1:273;
oct1=274:1:288;
oct2=289:1:304;
nov1=305:1:319;
nov2=320:1:334;
dec1=335:1:349;
dec2=350:1:365;

% create a monthly range

m_range_15={jan1,jan2,feb1,feb2,mar1,mar2,apr1,apr2,may1,may2,june1,june2,...
    july1,july2,aug1,aug2,sep1,sep2,oct1,oct2,nov1,nov2,dec1,dec2};

years = 1:1:16;
months = 1:1:24;
leap_yrs = 2:4:14;

%Calculate Monthly Climatologies
monthly_sst_15 = cell(9,16,24);

% for anomalies get rid of NaN! to calculate 
%amjja_sst(isnan(amjja_sst))=0;

for i=1:9 %# of beaches
    for ii=1:16 %# of years
        
        current_yr = years(i);
        
        %Check if the year is a leap year
        leap_check = any(leap_yrs==current_yr);
        
        if leap_check
            
            jan1=1:1:15;
            jan2=16:1:31;
            feb1=32:1:46;
            feb2=47:1:60;
            mar1=61:1:76;
            mar2=77:1:91;
            apr1=92:1:106;
            apr2=107:1:121;
            may1=122:1:136;
            may2=137:1:152;
            june1=153:1:167;
            june2=168:1:182;
            july1=183:1:198;
            july2=199:1:213;
            aug1=214:1:229;
            aug2=230:1:244;
            sep1=245:1:259;
            sep2=260:1:274;
            oct1=275:1:289;
            oct2=290:1:305;
            nov1=306:1:320;
            nov2=321:1:335;
            dec1=336:1:350;
            dec2=351:1:366;
            
            range = 366*(ii-1)+1:ii*366; %Index within amjja_sst
            
        else
            
            range=365*(ii-1)+1:ii*365; %Index within amjja_sst
            
        end
        
        for iii=1:24 % # of months * 2
            
            if iii==10 && ii==16
                break
            end
            
            current_range = m_range_15{iii};
            current_range = range(current_range(1)):1:range(current_range(end)); %index within range
            
            %Store the mean for the beach, for the year, for the month
            monthly_sst_15{i,ii,iii} = squeeze(nanmean(amjja_sst2(current_range,...
                bounding_indices(i,3):bounding_indices(i,4),...
                bounding_indices(i,1):bounding_indices(i,2))))-273.15;
            
        end
    end
end

% ignore last 7 months of 2018

%Calculate Monthly Anomalies
monthly_sst_means_15 = nan(size(monthly_sst_15));
for i=1:9 %# of beaches
    for ii=1:16 %# of years
        for iii=1:24 %# of months
            if iii==10 && ii==16
                break
            end
            monthly_sst_means_15(i,ii,iii) = nanmean(nanmean(monthly_sst_15{i,ii,iii}));
        end
    end
end

%Calculate monthly climatology (16 yrs)
monthly_climatologies_15 = squeeze(nanmean(monthly_sst_means_15,2));

%%

%%%%%%%%%%%%%% 15 DAY DATES %%%%%%%%%%%%%%%%

years = 2003:1:2018;
months = 1:1:24;
DATE_15 = nan(370,2);
count = 1;


for ii = 1:16 % years
    
    current_yr = years(ii);
    
    for iii = 1:24 %All months
       
        current_month = months(iii);
        
        DATE_15(count,1) = current_yr;
        DATE_15(count,2) = current_month;
        
        count = count +1;
        
    end
end

%%%%%%%%%%% write csvs for each beach %%%%%%%%%%%%%

% YYYY | MM | DD| SST %

san_francisco_15day_sst_by_box = NaN(370,3);
monterey_15day_sst_by_box = NaN(370,3);
santa_barbara_15day_sst_by_box = NaN(370,3);
ventura_15day_sst_by_box = NaN(370,3);
malibu_15day_sst_by_box = NaN(370,3);
cabrillo_15day_sst_by_box = NaN(370,3);
orange_15day_sst_by_box = NaN(370,3);
oceanside_15day_sst_by_box = NaN(370,3);
san_diego_15day_sst_by_box = NaN(370,3);

for i = 1:9 % loop through each beach
    
    count_rows = 1;
    
    for ii = 1:16 % years
        
        for iii = 1:24 % months * 2
           
            if i == 1 % san francisco
                
                san_francisco_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                san_francisco_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                san_francisco_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 2 % monterey
                
                monterey_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                monterey_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                monterey_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 3 % santa barbara
                santa_barbara_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                santa_barbara_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                santa_barbara_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 4 % ventura
                ventura_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                ventura_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                ventura_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 5 % malibu
                malibu_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                malibu_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                malibu_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 6 % cabrillo
                cabrillo_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                cabrillo_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                cabrillo_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 7 % orange
                orange_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                orange_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                orange_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 8 % oceanside
                oceanside_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                oceanside_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                oceanside_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
            elseif i == 9 % san diego
                san_diego_15day_sst_by_box(count_rows,1) = DATE_15(count_rows,1);
                san_diego_15day_sst_by_box(count_rows,2) = DATE_15(count_rows,2);
                san_diego_15day_sst_by_box(count_rows,3) = monthly_sst_means_15(i,ii,iii);
                
                
            end
            count_rows = count_rows + 1; 
        end
        
    end
    
end

% put 15 day data from each beach into a table

san_francisco_15day = array2table(san_francisco_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
monterey_15day = array2table(monterey_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
santa_barbara_15day = array2table(santa_barbara_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
ventura_15day = array2table(ventura_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
malibu_15day = array2table(malibu_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
cabrillo_15day = array2table(cabrillo_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
orange_15day = array2table(orange_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
oceanside_15day = array2table(oceanside_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});
san_diego_15day = array2table(san_diego_15day_sst_by_box,'VariableNames',{'YYYY','MM','SST'});

newDir = '/Users/lwakamat/Desktop/DEVELOP/output';

% output tables into separate csvs

writetable(cabrillo_15day,[newDir,'cabrillo_15day_MODIS_SST.csv']);
writetable(malibu_15day,[newDir,'malibu_15day_MODIS_SST.csv']);
writetable(monterey_15day,[newDir,'monterey_15day_MODIS_SST.csv']);
writetable(oceanside_15day,[newDir,'oceanside_15day_MODIS_SST.csv']);
writetable(orange_15day,[newDir,'orange_15day_MODIS_SST.csv']);
writetable(san_diego_15day,[newDir,'san_diego_15day_MODIS_SST.csv']);
writetable(san_francisco_15day,[newDir,'san_francisco_15day_MODIS_SST.csv']);
writetable(santa_barbara_15day,[newDir,'santa_barbara_15day_MODIS_SST.csv']);
writetable(ventura_15day,[newDir,'ventura_15day_MODIS_SST.csv']);

save('final_sst_15_day.mat','monthly_sst_means_15','monthly_climatologies_15','DATE_15','-v7.3');

%%


%%%%%%%%%%%% PART 3 %%%%%%%%%%%%
%   SUBSET BOXES FOR BEACHES   %
%     STORE IN CELL ARRAY      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

%Load lat and lon
% cd('~/Desktop/DEVELOP/data/grunions/MUR_SST')
load('lat_lon.mat');

%Master Bounding Box
%Master Bounding Box Indices (stores start and end index)
%Format: 15 rows of beachs
%4 columns: minlat, maxlat, minlon, maxlon
bounding_boxes=nan(9,4);
bounding_indices=nan(9,4);
big_bounding_boxes=nan(3,4);
big_bounding_indices=nan(3,4);

%Beach names
beach_names={'SAN FRANCISCO','MONTEREY',...
    'SANTA BARBARA','VENTURA', 'MALIBU','CABRILLO','ORANGE',...
    'OCEANSIDE','SAN DIEGO'};

%%%% MAY CHANGE IF BEACH REGIONS ARE ALTERED %%%%%%%

%Beach bounding boxes
%San Francisco
bounding_boxes(1,1:2)=[37.31 38.15];
bounding_boxes(1,3:4)=[-123.05 -121.89];

%Monterey
bounding_boxes(2,1:2)=[36.46 37.12];
bounding_boxes(2,3:4)=[-122.63 -121.73];

%Santa Barbara
bounding_boxes(3,1:2)=[33.82 34.49];
bounding_boxes(3,3:4)=[-120.33 -119.46];

%Ventura
bounding_boxes(4,1:2)=[33.63 34.39];
bounding_boxes(4,3:4)=[-119.46 -118.88];

%Malibu
bounding_boxes(5,1:2)=[33.51 34.12];
bounding_boxes(5,3:4)=[-118.88 -118.42];

%Cabrillo
bounding_boxes(6,1:2)=[33.27 33.78];
bounding_boxes(6,3:4)=[-118.42 -118.02];

%Orange
bounding_boxes(7,1:2)=[33.28 33.7];
bounding_boxes(7,3:4)=[-118.02 -117.45];

%Oceanside
bounding_boxes(8,1:2)=[32.83 33.28];
bounding_boxes(8,3:4)=[-117.82 -117.21];

%San Diego
bounding_boxes(9,1:2)=[32.5 32.82];
bounding_boxes(9,3:4)=[-117.82 -117.08];

%Big bounding boxes
%North

%Central

%South
big_bounding_boxes(1,1:2)=[32 39];
big_bounding_boxes(1,3:4)=[-124 -117];

%Loop through each beach bounding box
for i = 1:9
    
    %Bounding Boxes Limits
    bounding_box.lat = bounding_boxes(i,1:2);
    bounding_box.lon = bounding_boxes(i,3:4);
    
    %Find the lat and lon indices in the CA Coast bounding box
    ilat = find(lat >= bounding_box.lat(1) & lat < bounding_box.lat(2));
    ilon = find(lon >= bounding_box.lon(1) & lon < bounding_box.lon(2));
    
    %Add to Bounding Indices
    bounding_indices(i,1:2)=[min(ilat) max(ilat)];
    bounding_indices(i,3:4)=[min(ilon) max(ilon)];
    
end

%Loop through each big bounding box
for i = 1:1 %Just Carbillo Beach currently
    
    %Bounding Boxes Limits
    big_bounding_box.lat = big_bounding_boxes(i,1:2);
    big_bounding_box.lon = big_bounding_boxes(i,3:4);
    
    %Find the lat and lon indices in the CA Coast bounding box
    ilat = find(lat >= big_bounding_box.lat(1) & lat < big_bounding_box.lat(2));
    ilon = find(lon >= big_bounding_box.lon(1) & lon < big_bounding_box.lon(2));
    
    %Add to Bounding Indices
    big_bounding_indices(i,1:2)=[min(ilat) max(ilat)];
    big_bounding_indices(i,3:4)=[min(ilon) max(ilon)];
    
end

save('bounding_boxes.mat','bounding_boxes','bounding_indices',...
    'big_bounding_boxes','big_bounding_indices','beach_names');



%%
%%%%%%%%%%%% PART 5 %%%%%%%%%%%%
%     CALCULATE CLIMATOLOGY    %
%       CALCULATE ANOMALY      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI and images
clc
clear
clf
close all

%Load sst data
cd('/Users/lwakamat/Desktop/DEVELOP')
load('master_sst.mat');
load('bounding_boxes.mat');

%Months
jan=1:1:31;
feb=32:1:59;
mar=60:1:90;
apr=91:1:120;
may=121:1:151;
june=152:1:181;
july=182:1:212;
aug=213:1:243;
sep=244:1:273;
oct=274:1:304;
nov=305:1:334;
dec=335:1:365;

m_range={jan,feb,mar,apr,may,june,july,aug,sep,oct,nov,dec};

years = 1:1:16;
yrs = 2003:1:2018;
months = 1:1:12;
leap_yrs = 2:4:14;

%Calculate Monthly Climatologies
monthly_sst = cell(185,700,700);
%monthly_sst = cell(9,16,12);

% for anomalies get rid of NaN! to calculate 
%amjja_sst(isnan(amjja_sst))=0;

%for i=1:9 %# of beaches
for i = 1:length(amjja_sst2)
    for ii=1:16 %# of years
        
        current_yr = yrs(ii);
        
        %Check if the year is a leap year
        leap_check = any(leap_yrs==current_yr);
        
        if leap_check
            
            jan=1:1:31;
            feb=32:1:60;
            mar=61:1:91;
            apr=92:1:121;
            may=122:1:152;
            june=153:1:182;
            july=183:1:213;
            aug=214:1:244;
            sep=245:1:274;
            oct=275:1:305;
            nov=306:1:335;
            dec=336:1:366;
            
            range = 366*(ii-1)+1:ii*366; %Index within amjja_sst
            
        else
            
            range=365*(ii-1)+1:ii*365;
            
        end
        
        for iii=1:12 %# of months
            
            current_month = months(iii);
            
            if iii==5 && ii==16
                break
            end
            
            current_range = m_range{iii};
                current_range = range(current_range(1)):1:range(current_range(end)); %index within range
            
            %Store the mean for the beach, for the year, for the month
%             monthly_sst{i,ii,iii} = squeeze(nanmean(amjja_sst2(current_range,...
%                 bounding_indices(i,3):bounding_indices(i,4),...
%                 bounding_indices(i,1):bounding_indices(i,2))))-273.15;

              monthly_sst{i,ii,iii} = squeeze(nanmean(amjja_sst2,:,:))-273.15;
            
        end
    end
end

% ignore last 7 months of 2018

%Calculate Monthly Anomalies
monthly_sst_means = nan(size(,700,700));
for i=1:9 %# of beaches
    for ii=1:16 %# of years
        for iii=1:12 %# of months
            if iii==5 && ii==16
                break
            end
            monthly_sst_means(i,ii,iii) = nanmean(nanmean(monthly_sst{i,ii,iii}));
           
        end
    end
end
% 

monthly_climatologies = squeeze(nanmean(monthly_sst_means,2));

%Calculate the anomaly by subtract the climatology from the monthly mean
%SST


%%%% ------ HELP HERE! ------ %%%%

monthly_sst_anomalies = monthly_sst_means;

for i = 1:9  %Beaches
    %for ii = 1:16
    for ii = 1:12 %Months
        %if iii == 5  && ii == 16
        %break
        
        monthly_sst_anomalies(i,:,ii) = [monthly_sst_anomalies(i,:,ii) - monthly_climatologies(i,ii)]';
    end
    
end

save('sst_anomalies.mat','monthly_sst_anomalies','lat','lon','beach_names','monthly_sst','monthly_sst_means','monthly_climatologies');
%%
%%%%%%%%%%%% PART 6 %%%%%%%%%%%%
%        PLOT ANOMALIES        %
%      PLOT MONTHLY MEANS      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear
clf
close all

%Load data
%SST
cd('/Users/lwakamat/Desktop/DEVELOP');
load('sst_anomalies.mat');
sst_anomalies_reformat = nan(16,184);
sst_means_reformat = nan(16,184);

%Reshape data for plotting
for i=1:9 %Beaches
    
    block1 = [];
    
    for ii=1:16
        for iii=1:12
            if iii==5 && ii==16
                break
            end
            block1 = [block1 monthly_sst_anomalies(i,ii,iii)];
        end
    end    

    sst_anomalies_reformat(i,:) = block1;
    
end

sst_means_reformat = monthly_sst_means(:,:);
sst_anomalies_reformat = monthly_sst_anomalies(:,:);

% %Reshape data for plotting
for i=1:9 %Beaches
    
    block2 = [];
    
    for ii=1:16
        for iii=1:12
            if iii==5 && ii==16
                break
            end
            block2 = [block2 monthly_sst_means(i,ii,iii)];
        end
    end
    
    %sst_means_reformat = squeeze(block2)
    sst_means_reformat(i,:) = block2;
    
end


%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);

dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

%Plot anomalies
for i = 1:9
    
    subplot(9,1,i)
    
    %create red bars for a positive values and blue bars for negative values
    neg=sst_anomalies_reformat(i,:);
    neg(neg>0)=nan;
    pos=sst_anomalies_reformat(i,:);
    pos(pos<0)=nan;
    
    %Left Axis
    yyaxis left
    
    neg_chart = bar(neg);
    neg_chart.FaceColor=dev_blue;
    hold on
    pos_chart=bar(pos);
    pos_chart.FaceColor=dev_red;
    hold on
    
    ylim([-3.5 3.5]);
    
    %Right Axis
    yyaxis right
    
    plot(sst_means_reformat(i,:),'linestyle',':','color','k','linewidth',2.5);
    %hold on
    
    %plot dotted lines between years
    for j= 0:12.12:185
        x = line([j j],[-20 38]);
        set(x,'LineStyle',':','Color',[.75 .75 .75],'linewidth',2);
    end
    
    %Add labels and format axis
    xticks(6:12.2:186);
    xlim([0.5 186.5]);
    ylim([-5 25]);
    xticklabels({'2003','2004','2005','2006','2007','2008'...
        ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    ylabel(beach_names{i});
    axes = gca;
    axes.YColor = 'k';
    if i>9
        yticklabels([]);
        yticks([]);
    end
    
    %Title on first graph only
    if i == 1
        title('2003-2018 Monthly 1km Sea Surface Temperatures Anomalies (MUR)');
    end
    
end

print('mur_sst_plot.png','-dpng');

%%

%%%%%%%%%%%% PART 4 %%%%%%%%%%%%
%      CREATE IMAGE FILES      %
%         CREATE MOVIE         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% PART 4.1 %%%
%  LOAD DATA   %
%%%%%%%%%%%%%%%%

%Clear GUI and images
clc
clear
clf
close all

%Load sst data
% cd('~/Desktop/DEVELOP/data/grunions/MUR_SST')
load('master_sst.mat');
load('bounding_boxes.mat');

%%
%%% PART 4.2 %%%
%   VIZ DATA   %
%%%%%%%%%%%%%%%%

jan=1:1:31;
feb=32:1:59;
mar=60:1:90;
apr=91:1:120;
may=121:1:151;
june=152:1:181;
july=182:1:212;
aug=213:1:243;
sep=244:1:273;
oct=274:1:304;
nov=305:1:334;
dec=335:1:365;

m_range={jan,feb,mar,apr,may,june,july,aug,sep,oct,nov,dec};

years = 1:1:16;
months = 1:1:12;
leap_yrs = 2:4:14;
yrs = 2003:1:2018;

%Calculate Monthly Climatologies
monthly_sst = cell(1,16,12);

% for anomalies get rid of NaN! to calculate 
%amjja_sst(isnan(amjja_sst))=0;

for i=1:1 %large bounding box
    for ii=1:16 %# of years
        
        current_yr = years(i);
        
        %Check if the year is a leap year
        leap_check = any(leap_yrs==current_yr);
        
        if leap_check
            
            jan=1:1:31;
            feb=32:1:60;
            mar=61:1:91;
            apr=92:1:121;
            may=122:1:152;
            june=153:1:182;
            july=183:1:213;
            aug=214:1:244;
            sep=245:1:274;
            oct=275:1:305;
            nov=306:1:335;
            dec=336:1:366;
            
            range = 366*(ii-1)+1:ii*366; %Index within amjja_sst
            
        else
            
            range=365*(ii-1)+1:ii*365;
            
        end
        
        for iii=1:12 %# of months
            
            if iii==5 && ii==16
                break
            end
            
            current_range = m_range{iii};
                current_range = range(current_range(1)):1:range(current_range(end)); %index within range
            
            %Store the mean for the beach, for the year, for the month
            monthly_sst{i,ii,iii} = squeeze(nanmean(amjja_sst(current_range,...
                bounding_indices(i,3):bounding_indices(i,4),...
                bounding_indices(i,1):bounding_indices(i,2))))-273.15; 
        
        end
    end
end

% ignore last 7 months of 2018

%Calculate Monthly Anomalies
monthly_sst_means = nan(size(monthly_sst));
for i=1:1 %# of beaches
    for ii=1:16 %# of years
        for iii=1:12 %# of months
            if iii==5 && ii==16
                break
            end
            monthly_sst_means(i,ii,iii) = nanmean(nanmean(monthly_sst{i,ii,iii}));
           
        end
    end
end


%%%%% SAVE DATA %%%%%
save('sst_anomalies.mat','monthly_sst_anomalies','lat','lon','beach_names','monthly_sst','monthly_sst_means');



%%

%Date creator

jan=1:1:31;
feb=1:1:28;
mar=1:1:31;
apr=1:1:30;
may=1:1:31;
june=1:1:30;
july=1:1:31;
aug=1:1:31;
sep=1:1:30;
oct=1:1:31;
nov=1:1:30;
dec=1:1:31;

julian=1:1:365;

apr_jug=[jan feb mar apr may june july aug sep oct nov];

yrs = 2003:1:2018;

% load walker values


%Movie frames
v = VideoWriter('test_movie.avi','Uncompressed AVI');
v.FrameRate = 4;
open(v);

%Loop through entire dataset
for i = 1:1 %3 Big bounding boxes
    
    %Set up figure
    zz=figure;
    set(zz,'Position',[0,0,1920,1080]);
    axesm('mercator','frame','on','MapLatLimit',big_bounding_boxes(i,1:2),'MapLonLimit',...
        big_bounding_boxes(i,3:4),'MeridianLabel','off','MLabelLocation',1,...
        'ParallelLabel','off','PLabelLocation',1,'Grid','on','GLineStyle',':','mlinelocation',70);
    
    %Big Bounding box
    ilat = big_bounding_indices(i,1:2);
    ilon = big_bounding_indices(i,3:4);
    
    
    for ii = 1:16 %14 %Years
        
        count = 1;
        current_yr = yrs(ii);
        
        for iii = 365*(ii-1)+1:ii*365 %size(amj_sst,1)
            
          
            %Plot data
            surfm(lat(ilat(1):ilat(2)),lon(ilon(1):ilon(2)),squeeze(amjja_sst2(iii,ilon(1):ilon(2),ilat(1):ilat(2)))'-273.15);
            
            %Create colorbar
            cb=colorbar('horiz');
            cb.FontSize = 14;
            newmap = jet(256);
            caxis([10 22]);
            colormap(jet);
            cb_title = title(cb,'C\circ');
            cb_title.Position = [349.7917 32.9000 0];
            cb_title.FontSize=14;
            
            %Title with Date
            if julian(count) < 31
                month='Janurary';
            elseif julian(count) < 59
                month='February';
            elseif julian(count) < 90
                month='March';
            elseif julian(count) < 120
                month='April';
            elseif julian(count) < 151
                month='May';
            elseif julian(count) < 181
                month='June';
            elseif julian(count) < 212
                month ='July';
            elseif julian(count) < 243
                month ='August';
            elseif julian(count) < 273
                month = 'September';
            elseif julian(count) < 304
                month = 'October';
            elseif julian(count) < 334
                month = 'November';
            else
                month = 'December';
            end
            
            title_string = ['MUR SST ',month,' ',num2str(apr_jug(count)),', ',num2str(current_yr)];
            fig_title = title(title_string);
            fig_title.FontSize = 18;
            
            %Write video frame into movie file
            writeVideo(v,getframe(gcf));
            count = count + 1;
            
        end
        
    end
    
end

close(v)

%%
%%%%%%%%%% PART MISC %%%%%%%%%%%
%      CREATE IMAGE FILES      %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clf
close all

%Load sst data
cd('/Users/lwakamat/Desktop/DEVELOP')
load('master_sst.mat');
load('bounding_boxes.mat');
load('sst_anomalies.mat');

sst_baseline = squeeze(mean(amjja_sst2(season,:,:)));

%Season  Means %%% CERTAIN YEARS CHOSEN TO VISUALIZE DATA %%%
sst_season_2005 = squeeze(mean(amjja_sst2(791:974,:,:)))-273.15;
sst_season_2009 = squeeze(mean(amjja_sst2(2251:2433,:,:)))-273.15;
sst_season_2010 = squeeze(mean(amjja_sst2(2617:2738,:,:)))-273.15;
sst_season_2012 = squeeze(mean(amjja_sst2(3348:3531,:,:)))-273.15;
sst_season_2013 = squeeze(mean(amjja_sst2(3713:3896,:,:)))-273.15;
sst_season_2015 = squeeze(mean(amjja_sst2(4443:4564,:,:)))-273.15;
sst_season_2017 = squeeze(mean(amjja_sst2(5174:5357,:,:)))-273.15;

bounding_box.lat = [32 39];
bounding_box.lon = [-124 -117];

zz=figure;
set(zz,'Position',[0,0,1920,1080]);
axesm('mercator','frame','on','MapLatLimit',bounding_box.lat,'MapLonLimit',...
    bounding_box.lon,'MeridianLabel','on','MLabelLocation',1,...
    'ParallelLabel','on','PLabelLocation',1,'Grid','off','GLineStyle',':');

% DISPLAY
surfm(lat,lon,sst_season_2015');
surfm(lat,lon,sst_season_2005');
surfm(lat,lon,sst_season_2012');
surfm(lat,lon,sst_season_2013');


%Create colorbar
cb=colorbar('horiz');
cb.FontSize = 14;
newmap = jet(256);
caxis([10 20]);
colormap(newmap);
cb_title = title(cb,'C\circ');
cb_title.Position = [349.7917 32.9000 0];
cb_title.FontSize=14;

