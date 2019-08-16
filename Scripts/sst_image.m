% File: sst_image.m
% Date: August 8, 2018
% contact: laelwakamatsu@gmail.com

% pulls down data from erddap matrix and creates image

% parameters:
%   in: matrix downloaded from web


%% CALC MEAN // CREATE IMAGE


load mur.mat

sst_june = squeeze(nanmean(jplMURSST41.analysed_sst(:,:,:)));

lat = jplMURSST41.latitude;
lon = jplMURSST41.longitude;
lat = double(lat);
lon = double(lon);

%Bounding Box of CA Coast
bounding_box_big.lat = [32 39];
bounding_box_big.lon = [-134 -117];

%Set up figure
zz=figure;

set(zz,'Position',[0,0,1920,1080]);
axesm('mercator','frame','on','MapLatLimit',bounding_box_big.lat,'MapLonLimit',...
    bounding_box_big.lon,'MeridianLabel','on','MLabelLocation',1,...
    'ParallelLabel','on','PLabelLocation',1,'Grid','off','GLineStyle',':');

% display june mean for 2018
surfm(lat,lon,sst_june);

%Create colorbar
cb=colorbar('horiz');
cb.FontSize = 14;
newmap = jet(256);
caxis([10 22]);
colormap(newmap);
cb_title.Position = [349.7917 32.9000 0];
cb_title.FontSize=14;

set(sst_june,'AlphaData',~isnan(zz))


%export_fig('june_2018_sst.png','png','-r100');


