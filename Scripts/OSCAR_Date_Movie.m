%%Create Date Index for OSCAR Surface Current Data 

clc
clear 
cd('C:\Users\peacock\Desktop\Develop\OSCAR_script');
load('oscar_matrix_u.mat');
load('oscar_matrix_v.mat');
load('lat_lon.mat');

%Date components

years = 2002:1:2018;
months = 1:1:12;
leap_yrs = 2004:4:2016;

count=1;
catch_count = 1;
missing_date = [];

%Set for number of datapoints and columns year/month/day 
DATE = nan(1160,3); 

for i = 1:17 %2002 - 2018 has 16 years
   
   current_yr = years(i);
   
   %Check if the year is a leap year
   leap_check = any(leap_yrs==current_yr);
   
   for ii = 1:12 %All months
       
       current_month = months(ii);
      
%        if i==17 && current_month == 5%%%%%% HERE %%%%%%
%            days=(5:5:15);
%            break 
%        end
       
       if ii==5 && i==17 %%%%%% HERE %%%%%%
           days=(5:5:15);
           break
       end
       
       %Different number of days depending on the month 
       %data in 5-day composites
   
       
       if current_month == 4 || current_month == 6 || current_month == 9 || current_month == 11
           days=(5:5:30);
       elseif leap_check && current_month == 2
           days=(5:5:29);
       elseif current_month == 2
           days=(5:5:28);
       else
           days=(5:5:31);
       end
       
       for iii = 1:length(days)
           current_days = days(iii);
           
           DATE(count,1) = current_yr;
           DATE(count,2) = current_month;
           DATE(count,3) = current_days;
       
           count=count+1; 
       
   end
   
end
end 

%Correcting for incomplete last month (May 2018)
if isnan(DATE(1160)) && isnan(DATE(count,2)) && isnan(DATE(count,3))
              DATE(1160) = 2018;
              DATE(1160,2) = 5;
              DATE(1160,3) = 5;
end 
     
cd('C:\Users\peacock\Desktop\Develop\OSCAR_script');
save('master_oscar.mat','DATE','oscar_matrix_u','oscar_matrix_v','lat','lon');

%% Find Monthly Means of OSCAR Surface Current Data 

clc
clear 
cd('C:\Users\peacock\Desktop\Develop\OSCAR_script');
load('oscar_matrix_u.mat');
load('oscar_matrix_v.mat');
load('lat_lon.mat');
load('master_oscar.mat');


DATE = DATE(1:1160,:,:);
[unique_yrmon] = unique(DATE(:,1:2),'rows'); %finds unique years and months from the year/month columns in input file
pts =(length(DATE)); 
new_ind = NaN(pts,1,'double'); %array that reindexes the current date points into monthly groups
NEW_DATES = NaN(1,2); %will contain a new date label for each month
ind = 1;
for ii = 1:length(unique_yrmon)
   days_in_month = find(DATE(:,1)==unique_yrmon(ii,1) & DATE(:,2)==unique_yrmon(ii,2));
   %reindex so that each month has 1 index (for ex. month 1 has
   %index 1 ; month 2 has index 2;)
   new_ind(days_in_month) = ii;
   %input new values for the dates for the final table
   NEW_DATES(ii,1) = unique_yrmon(ii,1);
   NEW_DATES(ii,2) = unique_yrmon(ii,2);
end    

%Finds unique monthly indices and means values 
indices = arrayfun(@(s) 1:s, size(oscar_matrix_u), 'UniformOutput', false);
indices{1} = new_ind;
[indices{:}] = ndgrid(indices{:});
indices = cell2mat(cellfun(@(v) v(:), indices, 'UniformOutput', false));
NEW_OSCAR_U = accumarray(indices, oscar_matrix_u(:),[],@nanmean);

indices = arrayfun(@(s) 1:s, size(oscar_matrix_v), 'UniformOutput', false);
indices{1} = new_ind;
[indices{:}] = ndgrid(indices{:});
indices = cell2mat(cellfun(@(v) v(:), indices, 'UniformOutput', false));
NEW_OSCAR_V = accumarray(indices, oscar_matrix_v(:),[],@nanmean);

save('master_monthly_oscar.mat','NEW_OSCAR_U','NEW_OSCAR_V','NEW_DATES','lat','lon');

%%
%%OSCAR Surface Current Monthly Video 
%Clear GUI
clc
clear

%Load lat and lon and Current Data
cd('C:\Users\peacock\Desktop\Develop\OSCAR_script');
load('master_monthly_oscar.mat');
load('lat_lon.mat');

%Set Date
year = 2002:1:2018; 
month = 1:1:12;

a = VideoWriter('oneyear.avi','Uncompressed AVI');
a.FrameRate = 4;
open(a);

%Set frame and axes 
lat_min=lat(end); lat_max=lat(1); lat_lim = [lat_min,lat_max];
lon_min=lon(end); lon_max=lon(1); lon_lim = [lon_max,lon_min];

axesm('mercator','frame','on','MapLatLimit',lat_lim,'MapLonLimit',...
   lon_lim,'MeridianLabel','off','MLabelLocation',1,...
   'ParallelLabel','off','PLabelLocation',1,'Grid','on','GLineStyle',':',...
   'mlinelocation',70);

figure(1)
axis tight manual % this ensures that getframe() returns a consistent size
% filename = 'output.gif';

%Set up xy grid for quiver plot
[x,y] = meshgrid(lat(:),lon(:));

for i = 1:17
    count = 1;
    current_yr = year(i);
        
    for ii = 12*(i-1)+1:i*12 %Running through date index 
    u = squeeze(NEW_OSCAR_U(ii,:,:));
    v = squeeze(NEW_OSCAR_V(ii,:,:));
    
    quiverm(x,y,u',v') 
    geoshow('landareas.shp','facecolor','none'); %Add in CA coastline
   
    %Title with Date
    if month(count) == 1
       months='January';   
    elseif month(count) == 2
       months='February';
    elseif month(count) == 3
       months='March';
    elseif month(count) == 4
       months ='April';
    elseif month(count) == 5
       months='May';
    elseif month(count) == 6
       months='June';
    elseif month(count) == 7
       months ='July';
    elseif month(count) == 8
       months ='August';
    elseif month(count) == 9
       months='September';
    elseif month(count) == 10
       months='October';
    elseif month(count) == 11
       months ='November';
    else
       months ='December';
    end
            
    tiHan = title(['Ocean Current Velocity',' ',months,' ',num2str(current_yr)], 'Interpreter', 'none','FontWeight','bold','FontSize',8);
    % Capture the plot as an image 
    %frame = getframe(); 
    %im = frame2im(frame); 
    %[imind,cm] = rgb2ind(im,256);
    
    if i == 17 && ii == 197 
        break
    end    
    
    %[imind(:,:,1,i),cm]=rgb2ind(im,256);
    writeVideo(a,getframe(gcf));

    count = count + 1;

    message = [num2str(ii),' out of 197'];
    disp(message)
    hold off;
    end
end 
%imwrite(imind,cm,filename,'gif','Loopcount',inf)
close(a)
disp('Done')