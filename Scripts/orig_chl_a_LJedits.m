%
%Lexi Jones - NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%NOTE: Parts of this script are an adaptation of the 'orig_chl_a.m' script 
%from Term 1 of this project.
%
%COMPONENTS
%PART 1: Create 15 day chl matrix
%PART 2: Create monthly matrix for entire bounding box
%PART 3: Subset 15day matrix into beach areas
%PART 4: Create 15 day 2D chl matrices by bounding box for correlations
%PART 5: Create monthly avg matrix by bounding box
%PART 6: Create satellite imagery movies
%PART 7: Plot monthly anomalies

%% PART 1: Create 15 day chl matrix

%The ouputted matrix will contain 2 data pionts per month, averaging all
%data points within the 15 day time frame. The determination of the
%placement of the data point is whether the record is before or after the
%16th of each month, i.e., some data points are not exactly 15 day groups 
%depending on the length of the month. Binning into 15 groups allowed the 
%team to compare this data to the Grunion data which was grouped by early 
%and late month data points. 

clear

%Load MODIS Aqual chlorophyll data generated using PART 1 of 'orig_chl_a.m'
load('master_chl_a.mat');
dates = cellstr(time_matlab_string);

%Create DATES matrix containing year, month, and day in seperate double
%arrays rather than strings
DATES = NaN(length(dates),3); 
for i = 1:length(dates)
    date_str = dates{i};
    DATES(i,1) = str2double(date_str(1:4)); 
    DATES(i,2) = str2double(date_str(5:6)); 
    DATES(i,3) = str2double(date_str(7:8));
end

%Override the 'master_chl_a.mat' file, to now contain the new DATES matrix
save('master_chl_a.mat','DATES','lon','lat','chl_a');

%Find unique years and months from the year/month columns in input file
[unique_yrmon] = unique(DATES(:,1:2),'rows'); 
pts =(length(DATES)); 
%new_ind reindexes the current date points into the 15 day groups
new_ind = NaN(pts,1,'double'); 
%NEW_DATES will contain a new date label for each 15 day group
NEW_DATES = NaN(1,3); 
ind = 1; %counter for the current index
for ii = 1:length(unique_yrmon)
    %early_month finds the indexes of the days within the given unique
    %year/month of day 15 or less, and late_month finds anything with a
    %day 16 or greater
    early_month = find(DATES(:,1)==unique_yrmon(ii,1) & DATES(:,2)==unique_yrmon(ii,2) & DATES(:,3)<=15);
    late_month = find(DATES(:,1)==unique_yrmon(ii,1) & DATES(:,2)==unique_yrmon(ii,2) & DATES(:,3)>15);

    %NOTE: It is important to catch the following different senarios if there
    %is gaps in the data within a given month!!!

    %scenario where dates are only in the late month
    if isempty(early_month) && ~isempty(late_month)
        new_ind(late_month) = ind;
        DATES(ind,1) = unique_yrmon(ii,1);
        NEW_DATES(ind,2) = unique_yrmon(ii,2);
        NEW_DATES(ind,3) = 16;
        ind = ind+1;

    %scenario where dates are only in the early month
    elseif ~isempty(early_month) && isempty(late_month)  
        new_ind(early_month) = ind;
        NEW_DATES(ind,1) = unique_yrmon(ii,1);
        NEW_DATES(ind,2) = unique_yrmon(ii,2);
        NEW_DATES(ind,3) = 1;
        ind = ind+1;

    %scenario where dates in both the early and late month are present
    else
        %reindex so that each month has 2 indeces (for ex. month 1 has
        %indeces 1,2 ; month 2 has indeces 3,4 ; month 3 has indeces 5, 6;
        %if you look at the math, the second number is always double the
        %month and the first number is double - 1 :) 
        new_ind(early_month) = ind; 
        NEW_DATES(ind,1) = unique_yrmon(ii,1);
        NEW_DATES(ind,2) = unique_yrmon(ii,2);
        NEW_DATES(ind,3) = 1;
        ind = ind+1;
        new_ind(late_month) = ind;
        NEW_DATES(ind,1) = unique_yrmon(ii,1);
        NEW_DATES(ind,2) = unique_yrmon(ii,2);
        NEW_DATES(ind,3) = 16;
        ind = ind+1;
        %input new values for the dates for the final table
    end
end 

%Here we need to make a new chl_a 3D matrix, but collapsed to the size of 
%the NEW_DATES matrix, i.e., average points within 15 month groups
indices = arrayfun(@(s) 1:s, size(chl_a), 'UniformOutput', false);
indices{1} = new_ind;
[indices{:}] = ndgrid(indices{:});
indices = cell2mat(cellfun(@(v) v(:), indices, 'UniformOutput', false));
NEW_CHL = accumarray(indices, chl_a(:),[],@nanmean);

%Save the data in a new .mat file
save('master_15day_chl_a.mat','NEW_CHL','NEW_DATES','lat','lon');
%% PART 2: Create monthly matrix for entire bounding box

clear
load('master_chl_a.mat');

%Finds unique years and months from the year/month columns in input file
[unique_yrmon] = unique(DATES(:,1:2),'rows'); 
pts =(length(DATES)); 
%new_ind array that reindexes the current date points into monthly groups
new_ind = NaN(pts,1,'double');
%NEW_DATES will contain the dates for each month
NEW_DATES = NaN(1,2); 
ind = 1;
for ii = 1:length(unique_yrmon)
    days_in_month = find(DATES(:,1)==unique_yrmon(ii,1) & DATES(:,2)==unique_yrmon(ii,2));
    %Reindex so that each month has 1 index (for ex. month 1 has
    %index 1 ; month 2 has index 2;)
    new_ind(days_in_month) = ii; 
    %Input new values for the dates for the final table
    NEW_DATES(ii,1) = unique_yrmon(ii,1);
    NEW_DATES(ii,2) = unique_yrmon(ii,2);
end    

%Take the average of the days in the matrix within the 15 day time frame
indices = arrayfun(@(s) 1:s, size(chl_a), 'UniformOutput', false);
indices{1} = new_ind;
[indices{:}] = ndgrid(indices{:});
indices = cell2mat(cellfun(@(v) v(:), indices, 'UniformOutput', false));
NEW_CHL = accumarray(indices, chl_a(:),[],@nanmean);

save('master_monthly_chl_a.mat','NEW_CHL','NEW_DATES','lat','lon');
%% PART 3: Subset 15day matrix into beach areas

%Clear GUI
clc
clear

%Load lat and lon
load('master_15day_chl_a.mat');

%bounding_boxes will contain min lat, max lat, min lon, max lon
bounding_boxes=nan(9,4); 
%bounding_indices will contain the indeces for mins and maxes from the lat and lon arrays
bounding_indices=nan(9,4);

beach_names={'San Francisco','Monterey',...
   'Santa Barbara','Ventura','Malibu','Cabrillo','Orange',...
   'Oceanside','San Diego'};

%%%%Beach bounding boxes%%%%
%The original large bounding boxes are commented out, toward the end of the
%term we decreased the size of the beach bounding boxes to improve
%correlations. 

%%San Francisco%%
% bounding_boxes(1,1:2)=[37.31 38.15];
% bounding_boxes(1,3:4)=[-123.05 -121.89];
bounding_boxes(1,1:2)=[37.57 38.14];
bounding_boxes(1,3:4)=[-122.99 -122.29];
%%Monterey%%
% bounding_boxes(2,1:2)=[36.46 37.12];
% bounding_boxes(2,3:4)=[-122.63 -121.73];
bounding_boxes(2,1:2)=[36.55 37.04];
bounding_boxes(2,3:4)=[-122.06 -121.73];
%%Santa Barbara%%
% bounding_boxes(3,1:2)=[33.82 34.49];
% bounding_boxes(3,3:4)=[-120.33 -119.46];
bounding_boxes(3,1:2)=[34.21 34.49];
bounding_boxes(3,3:4)=[-120.12 -119.46];
%%Ventura%%
% bounding_boxes(4,1:2)=[33.63 34.39];
% bounding_boxes(4,3:4)=[-119.46 -118.88];
bounding_boxes(4,1:2)=[34.01 34.4];
bounding_boxes(4,3:4)=[-119.46 -118.83];
%%Malibu%%
% bounding_boxes(5,1:2)=[33.51 34.12];
% bounding_boxes(5,3:4)=[-118.88 -118.42];
bounding_boxes(5,1:2)=[33.81 34.1];
bounding_boxes(5,3:4)=[-118.83 -118.35];
%%Cabrillo%%
% bounding_boxes(6,1:2)=[33.27 33.78];
% bounding_boxes(6,3:4)=[-118.42 -118.02];
bounding_boxes(6,1:2)=[33.55 33.78];
bounding_boxes(6,3:4)=[-118.43 -118.03];
%%Orange%%
% bounding_boxes(7,1:2)=[33.28 33.7];
% bounding_boxes(7,3:4)=[-118.02 -117.45];
bounding_boxes(7,1:2)=[33.34 33.69];
bounding_boxes(7,3:4)=[-118.02 -117.44];
%%Oceanside%%
% bounding_boxes(8,1:2)=[32.83 33.28];
% bounding_boxes(8,3:4)=[-117.82 -117.21];
bounding_boxes(8,1:2)=[32.83 33.33];
bounding_boxes(8,3:4)=[-117.52 -117.21];
%%San Diego%%
% bounding_boxes(9,1:2)=[32.5 32.82];
% bounding_boxes(9,3:4)=[-117.82 -117.08];
bounding_boxes(9,1:2)=[32.5 32.8];
bounding_boxes(9,3:4)=[-117.35 -117.08];

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

save('bounding_boxes_small.mat','bounding_boxes','bounding_indices','beach_names');

%% PART 4: Create 15 day 2D chl matrices by bounding box for correlations
clear
load('master_15day_chl_a.mat');
%load('bounding_boxes.mat');
load('bounding_boxes_small.mat');

%The following matricies will contain the dates and average chl over that
%dates within the bounding box
%San Francisco
san_francisco_15day_chla_by_box = NaN(370,4);
%Monterey
monterey_15day_chla_by_box = NaN(370,4);
%Santa Barbara
santa_barbara_15day_chla_by_box = NaN(370,4);
%Ventura
ventura_15day_chla_by_box = NaN(370,4);
%Malibu
malibu_15day_chla_by_box = NaN(370,4);
%Cabrillo
cabrillo_15day_chla_by_box = NaN(370,4);
%Orange
orange_15day_chla_by_box = NaN(370,4);
%Oceanside
oceanside_15day_chla_by_box = NaN(370,4);
%San Diego
san_diego_15day_chla_by_box = NaN(370,4);
for i=1:length(NEW_DATES) %Loop through each date
    san_francisco_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    monterey_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    santa_barbara_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    ventura_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    malibu_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    cabrillo_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    orange_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    oceanside_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    san_diego_15day_chla_by_box(i,1:3) = NEW_DATES(i,1:3);
    for ii = 1:9 %Loop through the beach areas
        temp=squeeze(NEW_CHL(i,bounding_indices(ii,1):bounding_indices(ii,2),bounding_indices(ii,3):bounding_indices(ii,4)));
        if ii == 1
            san_francisco_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 2
            monterey_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 3
            santa_barbara_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 4
            ventura_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 5
            malibu_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 6
            cabrillo_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 7
            orange_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 8
            oceanside_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        elseif ii == 9
            san_diego_15day_chla_by_box(i,4) = mean2(temp(~isnan(temp)));
        end
    end
end
        
save('master_15day_chl_by_box_small.mat','san_francisco_15day_chla_by_box','monterey_15day_chla_by_box',...
    'santa_barbara_15day_chla_by_box','ventura_15day_chla_by_box','malibu_15day_chla_by_box',...
    'cabrillo_15day_chla_by_box','orange_15day_chla_by_box','oceanside_15day_chla_by_box',...
    'san_diego_15day_chla_by_box','NEW_DATES','lat','lon');

%Here a seperate file is created for each beach region
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/CHL/chloreee/15day_small_box/';
cabrillo_15day_chla_by_box = array2table(cabrillo_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
malibu_15day_chla_by_box = array2table(malibu_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
monterey_15day_chla_by_box = array2table(monterey_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
oceanside_15day_chla_by_box = array2table(oceanside_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
orange_15day_chla_by_box = array2table(orange_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
san_diego_15day_chla_by_box = array2table(san_diego_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
san_francisco_15day_chla_by_box = array2table(san_francisco_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
santa_barbara_15day_chla_by_box = array2table(santa_barbara_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
ventura_15day_chla_by_box = array2table(ventura_15day_chla_by_box,'VariableNames',{'YYYY','MM','DD','CHL'});
writetable(cabrillo_15day_chla_by_box,[newDir,'cabrillo_15day_MODIS_CHL.csv']);
writetable(malibu_15day_chla_by_box,[newDir,'malibu_15day_MODIS_CHL.csv']);
writetable(monterey_15day_chla_by_box,[newDir,'monterey_15day_MODIS_CHL.csv']);
writetable(oceanside_15day_chla_by_box,[newDir,'oceanside_15day_MODIS_CHL.csv']);
writetable(orange_15day_chla_by_box,[newDir,'orange_15day_MODIS_CHL.csv']);
writetable(san_diego_15day_chla_by_box,[newDir,'san_diego_15day_MODIS_CHL.csv']);
writetable(san_francisco_15day_chla_by_box,[newDir,'san_francisco_15day_MODIS_CHL.csv']);
writetable(santa_barbara_15day_chla_by_box,[newDir,'santa_barbara_15day_MODIS_CHL.csv']);
writetable(ventura_15day_chla_by_box,[newDir,'ventura_15day_MODIS_CHL.csv']);


%% PART 5: Create monthly avg matrix by bounding box
%This matrix is used to calculate monthly anomalies & monthly movies

clc
clear
clf
close all

%Load sst data
load('master_chl_a.mat');
load('bounding_boxes_small.mat');

%Create a matrix holding the average chla values by month by beach area box
years = (2003:2018);
months = (1:12);
monthly_chla = cell(9,16,12); %stations, years, months
monthly_chla_means=NaN(9,16,12); %stations, years, months
for i=1:9 %Loop through beaches
    for ii=1:length(years) %Loop through years
        for iii=1:length(months) %Loop through months
            if ii==16 && iii==6 %Stop at the last available data
                break
            else
                ind = find(DATES(:,1)==years(ii) & DATES(:,2)==months(iii));
                beg = ind(1); fin = ind(end);
                monthly_chla{i,ii,iii} = squeeze(nanmean(chl_a(beg:fin,...
                    bounding_indices(i,1):bounding_indices(i,2),...
                    bounding_indices(i,3):bounding_indices(i,4))));
                monthly_chla_means(i,ii,iii) = nanmean(nanmean(monthly_chla{i,ii,iii}));
            end
        end
    end
end

%Calculate Monthly Climatologies
monthly_climatologies = squeeze(nanmean(monthly_chla_means,2));

%Calculate the anomaly by subtract the climatology from the monthly mean
monthly_chla_anomalies = NaN(size(monthly_chla_means));
for k = 1:9  %Beaches
    for kk = 1:12 %Months
        monthly_chla_anomalies(k,:,kk) = monthly_chla_means(k,:,kk)-monthly_climatologies(k,kk);
    end
end

MONTHLY_DATES = NaN(192,2);
monthly_chla_anomalies_reformat = NaN(192,9);

%Reformat 3D matrix into 2D
for j = 1:9
    count = 1;
    for jj = 1:length(years)
        for jjj = 1:length(months)
            if j == 1
                MONTHLY_DATES(count,1) = years(jj);
                MONTHLY_DATES(count,2) = months(jjj);
            end
            monthly_chla_anomalies_reformat(count,j)=monthly_chla_anomalies(j,jj,jjj);
            count = count+1;
        end
    end
end

save('chla_anomalies_small_boxes.mat','monthly_chla_anomalies','monthly_chla_anomalies_reformat','MONTHLY_DATES','lat','lon','beach_names','monthly_climatologies','monthly_chla_means');

%% PART 6: Create satellite imagery movies

%Clear images
clear
clf
close all

load('master_monthly_chl_a.mat');
% load('master_chl_a.mat');
lat = double(lat);
lon = double(lon);

%Movie frames
v = VideoWriter('chla_for_vid.avi','Uncompressed AVI');
v.FrameRate = 1;
open(v);

%Set up figure
zz=figure;
% set(zz,'Visible','off');
lat_min=lat(end); lat_max=lat(1); lat_lim = [lat_min,lat_max];
lon_min=lon(end); lon_max=lon(1); lon_lim = [lon_max,lon_min];
set(zz,'Position',[0,0,1920,1080]);
ax = axesm('mercator','frame','on','MapLatLimit',lat_lim,'MapLonLimit',...
    lon_lim,'MeridianLabel','on','MLabelLocation',1,...
    'ParallelLabel','on','PLabelLocation',1,'Grid','on','GLineStyle',':',...
    'mlinelocation',70); %mlinelocation 70 pushes the line off of the grid
    %so it isn't visible. The functionality to turn the line off was not
    %working.
month_vec = {'January' 'February' 'March' 'April' 'May' 'June' 'July' ...
    'August' 'September' 'October' 'November' 'December'};
[x,y]=meshgrid(lat,lon);
gridm on;

start_year = 2005;
start_month = 4;
end_year = 2006;
end_month = 2;

start_inds = find(NEW_DATES(:,1)==start_year & NEW_DATES(:,2)==start_month);
end_inds = find(NEW_DATES(:,1)==end_year & NEW_DATES(:,2)==end_month);

for i = start_inds(1):end_inds(end)
%for i = 1:length(NEW_DATES)
%     layer = squeeze(chl_a(i,:,:));
    set(ax);
    hold on;
    layer = squeeze(NEW_CHL(i,:,:));
    surfm(x,y,layer');
    
    %Create colorbar
    cb=colorbar('horiz');
    cb.FontSize = 14;
    newmap = jet(256);
    caxis([0 8]);
%  colormap(flipud(newmap));
    
    cb_title = title(cb,'mg/m^3');
    pos = get(cb,'Position');
    cb_title.Position = [245 32.9000 0];
%     cb_title.Position = [275 40 0];
    cb_title.FontSize=14;
    
    year = NEW_DATES(i,1);
    month = NEW_DATES(i,2);
    month_string = month_vec(month);
%     day = DATES(i,3);
    
    title_string = {['MODIS Aqua Chlorophyll-a '];[month_string{1},' ',num2str(year)]};
    fig_title = title(title_string);
    fig_title.FontSize = 18;
            
    %Write video frame into movie file
        %Need to get entire figure to write to video
    writeVideo(v,getframe(gcf)); 
end

close(v)
implay('chla_for_vid.avi');
%% PART 7: Plot monthly anomalies

clear
load('chla_anomalies_small_boxes.mat');

%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);

dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

%Plot anomalies
for i = 1:9
    subplot(9,1,i)
    
   %create red bars for a positive values and blue bars for negative values
    neg=monthly_chla_anomalies_reformat(:,i);
    neg(neg>0)=nan;
    pos=monthly_chla_anomalies_reformat(:,i);
    pos(pos<0)=nan;
   
   %%%Left Axis
    yyaxis left
    
    neg_chart = bar(neg,'FaceColor',dev_blue);
    hold on
    pos_chart=bar(pos,'FaceColor',dev_red);
    hold on
    
    ylim([-10 10]);
    axes = gca;
    axes.YColor = 'k';
    if i == 5
        ylabel('mg/m^3','Color','k');
    end
    
    %%%Right Axis
    yyaxis right
    
    %plot dotted lines between years
    for j= 12:12:190
        x = line([j j],[-50 50]);
        set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
        set(gca,'YTickLabel',[]); %removes y axes labels associated with dotted lines
    end
 
    %Add labels and format axis
    %
    xlim([0 190]);
    if i ~= 9
        set(gca,'xtick',[]);
    else
        xticks(6:12:365); 
        xticklabels({'2003','2004','2005','2006','2007','2008'...
             ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    end
    ylabel(beach_names{i});
    axes = gca;
    axes.YColor = 'k';
    axes.TickLength = [0 0];
   
   %Title on first graph only
   if i == 1
       title('2003-2018 Monthly MODIS Aqua Chlorophyll-a Anomalies');
   end
   
end
