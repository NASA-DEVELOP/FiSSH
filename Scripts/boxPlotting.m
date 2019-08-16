%% Make box plots by Walker Value
%Info: The line in the middle of the dataset is the median, where the top
%and bottom lines are the 25th and 75th percentiles (aka the median of the 
%upper and lower halves). The ends of the 'whiskers' represent the minimum
%and maximum of the dataset, with additional points representing outliers.

clc
clear
clf
close all

currentDir = 'C:\Users\hknapp\Desktop\Boxplots'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

all_values = NaN();all_walkers = NaN();
for i = 1:length(fileList)
    file = fileList(i).name;
    csv = readtable(fullfile(currentDir,file));
    value = csv.MODIS_CHL; walker = csv.Walker;
    all_values = [all_values; value];
    all_walkers = [all_walkers; walker];
end

zz=figure;
dev_blue = [52/255 156/255 196/255]; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;

% scatter(walker_array,mean_value_array,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
% scatter(var1,var2,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
boxplot(all_values,all_walkers,'Symbol','.','Whisker',2,'Color',dgreen,'BoxStyle','filled'); 
xlabel('Walker Value','FontSize',12); xlim([0,7]);
% ylabel('in situ Water Temperature (C\circ)','FontSize',12); ylim([5,25]);
% ylabel('MUR SST (C\circ)','FontSize',12); ylim([5,25]);
% ylabel('In Situ Air Temperature (C\circ)','FontSize',12); ylim([0,25]);
% ylabel('Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
% ylabel('In Situ Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,1.5]);
ylabel('MODIS Aqua Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
% ylabel('MODIS Aqua Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,0.5]);
% ylabel('Upwelling Index (m^3/s/100 m)','FontSize',12); ylim([0,250]);
% ylabel('{\it{Pseudo-nitzschia}} (cells/10,000L)','FontSize',12); ylim([0,15]);

%% 
% PLOTLY CODE %
data = {...
  struct(...
    'y', all_values, ...
    'x', all_walkers, ...
    'name', 'testing', ...
    'marker', struct('color','#FF4136'), ...
    'type', 'box')...
};
response = plotly(data, struct('filename', 'box-grouped', 'fileopt', 'overwrite'));
plot_url = response.url;

% additional settings
%     'boxpoints', 'all', ...
%     'jitter', 0.3, ...
%     'pointpos', -1.8, ...
% notes
%     could do a structure for each factor

%%
% S U P E R  P L O T L Y  C O D E  B O I %

clc
clear
clf
close all

currentDir = 'C:\Users\hknapp\Desktop\Boxplots'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention
help = plotlyhelp;


% Loop to store values
all_walkers = NaN();
all_MODIS_CHL = NaN();
all_WTMPmean = NaN();
all_ATMPmean = NaN();
all_Upwelling = NaN();
all_SCCOOS_CHL = NaN();
all_MUR_SST = NaN();

for i = 1:length(fileList)
    file = fileList(i).name;
    csv = readtable(fullfile(currentDir,file));
    
    walker = csv.Walker;
    MODIS_CHL = csv.MODIS_CHL;
    WTMPmean = csv.WTMPmean;
    ATMPmean = csv.ATMPmean;
    Upwelling = csv.Upwelling;
    SCCOOS_CHL = csv.SCCOOS_CHL;
    MUR_SST = csv.MUR_SST;
    
    all_walkers = [all_walkers;walker];
    all_MODIS_CHL = [all_MODIS_CHL;MODIS_CHL];
    all_WTMPmean = [all_WTMPmean;WTMPmean];
    all_ATMPmean = [all_ATMPmean;ATMPmean];
    all_Upwelling = [all_Upwelling;Upwelling];
    all_SCCOOS_CHL = [all_SCCOOS_CHL;SCCOOS_CHL];
    all_MUR_SST = [all_MUR_SST;MUR_SST];
end


% Set up plots, store data
trace_MODIS_CHL = struct(...
    'y', all_MODIS_CHL, ...
    'x', all_walkers, ...
    'name', 'MODIS_CHL', ...
    'marker', struct('color', '#83ae51'), ...
    'type', 'box');

trace_WTMPmean = struct(...
    'y', all_WTMPmean, ...
    'x', all_walkers, ...
    'name', 'WTMPmean', ...
    'marker', struct('color', '#358caa'), ...
    'type', 'box');

trace_ATMPmean = struct(...
    'y', all_ATMPmean, ...
    'x', all_walkers, ...
    'name', 'ATMPmean', ...
    'marker', struct('color', '#dbd1ce'), ...
    'type', 'box');

trace_Upwelling = struct(...
    'y', all_Upwelling, ...
    'x', all_walkers, ...
    'name', 'Upwelling', ...
    'marker', struct('color', '#687377'), ...
    'type', 'box');

trace_SCCOOS_CHL = struct(...
    'y', all_SCCOOS_CHL, ...
    'x', all_walkers, ...
    'name', 'SCCOOS_CHL', ...
    'marker', struct('color', '#589613'), ...
    'type', 'box');

trace_MUR_SST = struct(...
    'y', all_MUR_SST, ...
    'x', all_walkers, ...
    'name', 'MUR_SST', ...
    'marker', struct('color', '#00829d'), ...
    'type', 'box');


% Generate plotly figure
layout = struct(...
    'yaxis', struct(...
        'title','AXIS LABEL', ...
        'zeroline',false), ...
    'xaxis', struct(...
        'title','Walker Value'), ...
    'boxmode','group');


% Establish items to display
data = {trace_MUR_SST,trace_WTMPmean};
response = plotly(data, struct('layout',layout,'filename', ...
    'OCEAN_TEMP','fileopt','overwrite'));

plot_url = response.url;
