
%%%%%%%%%%%% PART 1 %%%%%%%%%%%%
%  FIND BOUNDING CA LAT, LON   %
%         CHECK DATA           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

cd('C:\Users\hknapp\Desktop\OSCAR_script');

%Bounding Box of CA Coast
bounding_box.lat = [32 39];
bounding_box.lon = [236 243];

%Beginning URL
url = 'https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/oscar/preview/L4/oscar_third_deg/oscar_vel2002.nc.gz';
url2 = 'https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/oscar/preview/L4/oscar_third_deg/oscar_vel2002.nc.gz?latitude[124:1:144],longitude[648:1:668],u[0:1:0][0:1:0][124:1:144][648:1:668],v[0:1:0][0:1:0][124:1:144][648:1:668]';

%Pull out lat and lon vectors
lat = ncread(url,'latitude');
lon = ncread(url,'longitude');

%Find the lat and lon indices in the CA Coast bounding box
ilat = find(lat >= bounding_box.lat(1) & lat < bounding_box.lat(2));
ilon = find(lon >= bounding_box.lon(1) & lon < bounding_box.lon(2));

%Reduce lat and lon to bounding box and make double
lat = double(lat(ilat));
lon = double(lon(ilon));

%Define subset to cover bounding box [lon lat depth time]
stride = [1 1 1 1];
start = [min(ilon) min(ilat) 1 1];
count = [length(ilon) length(ilat) 1 1];

%Pull subsetted data to test
oscar_u = ncread(url,'u',start,count,stride);
oscar_v = ncread(url,'v',start,count,stride);
oscar_u = squeeze(oscar_u); %Turn 2d
oscar_v = squeeze(oscar_v); %Turn 2d

%Display lat and lon bounds
disp(['Lat: ',num2str(lat(1)),' to ',num2str(lat(end))])
disp(['Lat index: ',num2str(ilat(1)-1),' to ',num2str(ilat(end)-1)])
disp(['Lon: ',num2str(lon(1)),' to ',num2str(lon(end))])
disp(['Lon index: ',num2str(ilon(1)-1),' to ',num2str(ilon(end)-1)])
%NOTE: These indices are 1 index too far when entered directly in the
%OPeNDAP URL due to OPeNDAP indexing starting at 0 compared to MATLAB's
%indexing starting at 1. Must subtract 1 as done above.

%Save lat and lon to data directory
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
cd('C:\Users\hknapp\Desktop\OSCAR_script');
load('lat_lon.mat');

%URL components
years = 2002:1:2018;

%https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/oscar/preview/L4/oscar_third_deg/oscar_vel2002.nc.gz?time[0:1:71],depth[0:1:0],latitude[124:1:144],longitude[648:1:668],u[0:1:0][0:1:0][124:1:144][648:1:668],v[0:1:0][0:1:0][124:1:144][648:1:668]
%https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/oscar/preview/L4/oscar_third_deg/oscar_vel2002.nc.gz?time[0:1:71],latitude[124:1:144],longitude[648:1:668],u[0:1:71][0:1:0][124:1:144][648:1:668],v[0:1:71][0:1:0][124:1:144][648:1:668]
base_url = 'https://podaac-opendap.jpl.nasa.gov:443/opendap/allData/oscar/preview/L4/oscar_third_deg/oscar_vel';
tail_url = '.nc.gz?latitude[124:1:144],longitude[648:1:668],u[0:1:71][0:1:0][124:1:144][648:1:668],v[0:1:71][0:1:0][124:1:144][648:1:668]';
tail_url_2016 = '.nc.gz?latitude[124:1:144],longitude[648:1:668],u[0:1:59][0:1:0][124:1:144][648:1:668],v[0:1:59][0:1:0][124:1:144][648:1:668]';
tail_url_2018 = '.nc.gz?latitude[124:1:144],longitude[648:1:668],u[0:1:7][0:1:0][124:1:144][648:1:668],v[0:1:7][0:1:0][124:1:144][648:1:668]';


%Master data matrix
%15 yrs * (72 data points per year)
%2016 is incomplete with 60 datapoints
%2018 currently only has 8 datapoints
%21 elements in lat and lon
oscar_matrix_u = nan(1160,21,21);
oscar_matrix_v = nan(1160,21,21);

%Empty pentad data frame
NaN_matrix = nan(21,21);

%Count to index master data matrix
count_u = 1;
count_v = 1;

%Loop through all the data and create a master .mat file
for i = 1:17 %2002 - 2018 has 17 years
    
    current_yr = years(i);
    disp([num2str(current_yr),' is processing...'])
    
    %Construct the OPeNDAP URL with the required components
    if current_yr == 2016
        current_url =([base_url, num2str(current_yr),tail_url_2016]);
    elseif current_yr == 2018
        current_url =([base_url, num2str(current_yr),tail_url_2018]);
    else
        current_url =([base_url, num2str(current_yr),tail_url]);
    end
    
    %Pull 'u' data from OPeNDAP URL
    current_oscar_u_raw = ncread(current_url,'u');    
    current_oscar_u_squeeze = squeeze(current_oscar_u_raw);
    current_oscar_u_refined = permute(current_oscar_u_squeeze,[3 2 1]);
        
    %Pull 'v' data from OPeNDAP URL
    current_oscar_v_raw = ncread(current_url,'v');
    current_oscar_v_squeeze = squeeze(current_oscar_v_raw);
    current_oscar_v_refined = permute(current_oscar_v_squeeze,[3 2 1]);
    
    if current_yr == 2016
        for ii = 1:60 % number of pentads with data
            oscar_matrix_u(count_u,:,:) = current_oscar_u_refined(ii,:,:);
            oscar_matrix_v(count_v,:,:) = current_oscar_v_refined(ii,:,:);
            count_u = count_u+1;
            count_v = count_v +1;
        end
        for ii = 61:72 % fill missing pentads with null data frame
            oscar_matrix_u(count_u,:,:) = NaN_matrix(:,:);
            oscar_matrix_v(count_v,:,:) = NaN_matrix(:,:);
            count_u = count_u+1;
            count_v = count_v +1;
        end
        
    elseif current_yr == 2018
        for ii = 1:8 % number of pentads
            oscar_matrix_u(count_u,:,:) = current_oscar_u_refined(ii,:,:);
            oscar_matrix_v(count_v,:,:) = current_oscar_v_refined(ii,:,:);
            count_u = count_u+1;
            count_v = count_v +1;
        end
        
    else
        for ii = 1:72 % number of pentads
            oscar_matrix_u(count_u,:,:) = current_oscar_u_refined(ii,:,:);
            oscar_matrix_v(count_v,:,:) = current_oscar_v_refined(ii,:,:);
            count_u = count_u+1;
            count_v = count_v +1;
        end
    end
    
end

save('oscar_matrix_u.mat','oscar_matrix_u','lat','lon','-v7.3');
save('oscar_matrix_v.mat','oscar_matrix_v','lat','lon','-v7.3');
disp('Done')

%%

%%%%%%%%%%%% PART 3 %%%%%%%%%%%%
%   CREATE CSVs OF U/V POINT   %
%   DATA PER PENTAD (OPTIONAL) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

%Load lat and lon
cd('C:\Users\hknapp\Desktop\OSCAR_script');
load('oscar_matrix_u.mat');
load('oscar_matrix_v.mat');
load('lat_lon.mat');


%Create CSVs with points

for i = 1:1160 % number of pentads in analysis (size of master matrix)
    
    %Flatten one frame of the array into a 2D matrix
    df_u = oscar_matrix_u(i,:,:);
    df_v = oscar_matrix_v(i,:,:);
    df_u = squeeze(df_u);
    df_v = squeeze(df_v);
    
    %File creation
    filename = ['C:\Users\hknapp\Desktop\OSCAR_script\csv_files\',num2str(i),'_pentad_points.csv'];
    temp = nan(1,4);
    
    %Header set-up (writes over temp)
    csvwrite(filename,temp);
    fid = fopen(filename,'wt');
    fprintf(fid,'%s,%s,%s,%s\n','lat','lon','u','v');
    fclose(fid);
    
    %Read through matrix to write CSV
    for col = 1:21
        result_u = df_u(:,col);       
        result_v = df_v(:,col);
        
        for row = 1:21
            if ~isnan(result_u(row)) && ~isnan(result_v(row))
                line = [lat(row) -360+lon(col) result_u(row) result_v(row)];
                dlmwrite(filename,line,'delimiter',',','-append');
            end
        end
        
    end
    
    %When completed...
    disp(['Finished frame ',num2str(i)])
    
end

%%

%%%%%%%%%%%% PART 4 %%%%%%%%%%%%
%   SUBSET BOXES FOR BEACHES   %
%     STORE IN CELL ARRAY      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear GUI
clc
clear

%Load lat and lon
cd('C:\Users\hknapp\Desktop\OSCAR_script')
load('lat_lon.mat');

%Master Bounding Box
%Master Bounding Box Indices (stores start and end index)
%Format: 15 rows of beachs
%4 columns: minlat, maxlat, minlon, maxlon
bounding_boxes = nan(6,4);
bounding_indices = nan(6,4);
big_bounding_boxes = nan(3,4);
big_bounding_indices = nan(3,4);

%Beach names
beach_names={'SAN FRANCISCO','MONTEREY',...
    'SANTA BARBARA', 'MALIBU','NEWPORT','SAN DIEGO'};

%Beach bounding boxes
%San Francisco
bounding_boxes(1,1:2) = [37.39 38.22];
bounding_boxes(1,3:4) = [236.86 238.14];

%Monterey
bounding_boxes(2,1:2) = [36.54 37.05];
bounding_boxes(2,3:4) = [237.61 238.27];

%Santa Barbara
bounding_boxes(3,1:2) = [34.044 34.54];
bounding_boxes(3,3:4) = [239.61 240.63];

%Malibu
bounding_boxes(4,1:2) = [33.56 34.22];
bounding_boxes(4,3:4) = [240.84 241.75];

%Newport
bounding_boxes(5,1:2) = [32.88 33.72];
bounding_boxes(5,3:4) = [241.75 242.56];

%San Diego
bounding_boxes(6,1:2) = [32.20 32.84];
bounding_boxes(6,3:4) = [242.24 242.96];

%Big bounding boxes
%North

%Central

%South
big_bounding_boxes(1,1:2) = [32.201 34.562];
big_bounding_boxes(1,3:4) = [240.455 243.000];

%Loop through each beach bounding box // FOUND AN ERRROR
for i = 1:6
    
    %Bounding Boxes Limits
    bounding_box.lat = bounding_boxes(i,1:2);
    bounding_box.lon = bounding_boxes(i,3:4);
    
    %Find the lat and lon indices in the CA Coast bounding box
    ilat = find(lat >= bounding_box.lat(1) & lat < bounding_box.lat(2));
    ilon = find(lon >= bounding_box.lon(1) & lon < bounding_box.lon(2));
    
    %Add to Bounding Indices
    bounding_indices(i,1:2) = [min(ilat) max(ilat)];
    bounding_indices(i,3:4) = [min(ilon) max(ilon)];
    
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
    big_bounding_indices(i,1:2) = [min(ilat) max(ilat)];
    big_bounding_indices(i,3:4) = [min(ilon) max(ilon)];
    
end

save('bounding_boxes.mat','bounding_boxes','bounding_indices',...
    'big_bounding_boxes','big_bounding_indices','beach_names');
disp('Done')

%%

%%%%%%%%%%%% PART 5 %%%%%%%%%%%%
%   OCEAN CURRENT QUIVER PLOT  %
%      USE STORED MATRICES     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






