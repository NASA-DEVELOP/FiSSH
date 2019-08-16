%
%Lexi Jones - NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%COMPONENTS
%PART 1: Correlation scatter plots
%PART 2: Plot histogram distribution of data based on walker category
%PART 3: Plot histogram distribution of data based on walker category (FOR POSTER)
%PART 4: Plot mean value by Walker
%PART 5: Plot mean value by Walker  (FOR POSTER)
%PART 6: Plot histogram distribution of data based on walker category by
%major beach region (--UNFINISHED--)

%% PART 1: Correlation scatter plots
clc
clear
clf
close all

%Read 15 day data files
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/';
%Find all of the files in the current directory with .csv extention
fileList = dir(fullfile(currentDir,'*.csv')); 

%Set up figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255]; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;

for i = 1:length(fileList) %Loop through the files
    file = fileList(i).name;
    name = file(1:end-10);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    
    %Define the variable vectors to compare, this calls the title of the
    %data column from the csv file
    var1 = csv.WTMPmean; var2 = csv.MUR_SST; 
    
    %Find stats for each beach, including r^2, and plot in subplot by
    %north, central, and south
    if i == 1 
        fit_cabrillo = fitlm(var1,var2);
        rsq = fit_cabrillo.Rsquared.Ordinary;
        subplot(3,4,3);
    elseif i == 2
        fit_malibu = fitlm(var1,var2);
        rsq = fit_malibu.Rsquared.Ordinary;
        subplot(3,4,7);
    elseif i == 3
        fit_monterey = fitlm(var1,var2);
        rsq = fit_monterey.Rsquared.Ordinary;
        subplot(3,4,5);
    elseif i == 4
        fit_oceanside = fitlm(var1,var2);
        rsq = fit_oceanside.Rsquared.Ordinary;
        subplot(3,4,8);
    elseif i == 5
        fit_orange = fitlm(var1,var2);
        rsq = fit_orange.Rsquared.Ordinary;
        subplot(3,4,11);
    elseif i == 6
        fit_san_diego = fitlm(var1,var2);
        rsq = fit_san_diego.Rsquared.Ordinary;
        subplot(3,4,4);
    elseif i == 7
        fit_san_francisco = fitlm(var1,var2);
        rsq = fit_san_francisco.Rsquared.Ordinary;
        subplot(3,4,1);
    elseif i == 8
        fit_santa_barbara = fitlm(var1,var2);
        rsq = fit_santa_barbara.Rsquared.Ordinary;
        subplot(3,4,2);
    elseif i == 9
        fit_ventura = fitlm(var1,var2);
        rsq = fit_ventura.Rsquared.Ordinary;
        subplot(3,4,6);
    end

%%%%%% Choose the correct title, and x/y labels %%%%%% 

%     scatter(var1,var2,50,'MarkerFaceColor',green,'MarkerEdgeColor',dgreen); 
    scatter(var1,var2,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
%     scatter(var1,log10(var2),50,'MarkerFaceColor',green,'MarkerEdgeColor',dgreen); 

%     xlabel('Walker Value','FontSize',12); xlim([-1,6]);
    xlabel('MUR SST (C\circ)','FontSize',12); xlim([5,25]);
%     xlabel('MODIS Chlorophyll-a (mg/m^3)','FontSize',12); xlim([0,15]);

    ylabel('in situ Water Temperature (C\circ)','FontSize',12); ylim([5,25]);
%     ylabel('MUR SST (C\circ)','FontSize',12); ylim([5,25]);
%     ylabel('In Situ Air Temperature (C\circ)','FontSize',12); ylim([0,25]);
%     ylabel('in situ Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,15]);
%     ylabel('In Situ Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,1.5]);
%     ylabel('MODIS Aqua Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
%     ylabel('MODIS Aqua Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,1.5]);
%     ylabel('Upwelling Index (m^3/s/100 m)','FontSize',12); ylim([0,250]);
%     ylabel('Pseudo-nitzschia (cells/10,000L)','FontSize',12); ylim([0,50]);

    rsq_text = ['r^2 = ',num2str(rsq)];
    text(10,22,rsq_text,'FontSize',12); %define coordinates on plot where 
    %r^2 value is to be plotted
    
    %Create trendline is not wanted comment this line out
    h=lsline; set(h,'color','k','LineWidth',0.5);
    
    %Label each major beach region
    if i == 1
        title({'Southern California';newName},'FontSize',14);
    elseif i == 7
        title({'Northern California';newName},'FontSize',14);
    elseif i == 8
        title({'Central California';newName},'FontSize',14);
    else
        title(newName,'FontSize',14);
    end
end

%% PART 2: Plot histogram distribution of data based on walker category
clc
clear
clf
close all

%Read 15 day data files
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/'; 
%Find all of the files in the current directory with .csv extention
fileList = dir(fullfile(currentDir,'*.csv')); 

%Predefine empty matrices to store data for each Walker Value range: 0-1 is
%considered low, 2-3 medium, 4-5 high
value_at_high_walker = NaN();
value_at_med_walker = NaN();
value_at_low_walker = NaN();

for i = 1:length(fileList) %Loop through files
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    value = csv.MUR_SST; %call the variable to study
    walker = csv.Walker; %call the walker values
    %Find indeces of data points with high walker values
    high_ind = find(walker(:,1)>=4); 
    %Find indeces of data points with medium walker values
    med_ind = find(walker(:,1)>=2 & walker(:,1)<=3);
    %Find indeces of data points with low walker values
    low_ind = find(walker(:,1)<=1);
    %Pull the values of the variable associated with each of these indeces
    value_high = value(high_ind); 
    value_med = value(med_ind); 
    value_low = value(low_ind);
    %Append the value to the array containing all of the values in the same
    %walker scale range
    value_at_high_walker = [value_at_high_walker; value_high];
    value_at_med_walker = [value_at_med_walker; value_med];
    value_at_low_walker = [value_at_low_walker; value_low];
end

%Remove nan values from the arrays
value_at_high_walker_no_nan = sort(value_at_high_walker(~isnan(value_at_high_walker)));   
value_at_med_walker_no_nan = sort(value_at_med_walker(~isnan(value_at_med_walker)));
value_at_low_walker_no_nan = sort(value_at_low_walker(~isnan(value_at_low_walker))); 

%%%%%%% Stats %%%%%%%%%
%muHat is the mean, sigmaHat is the standard deviation
%mode finds the most common rounded integer temperature
mode_high = mode(round(value_at_high_walker_no_nan));
mode_med = mode(round(value_at_med_walker_no_nan));
mode_low = mode(round(value_at_low_walker_no_nan));
[muHat_high,sigmaHat_high] = normfit(value_at_high_walker_no_nan);
[muHat_med,sigmaHat_med] = normfit(value_at_med_walker_no_nan);
[muHat_low,sigmaHat_low] = normfit(value_at_low_walker_no_nan);

zz=figure; %Set up figure
dev_blue = [52/255 156/255 196/255]; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;

%%%%%%%%%%%%%%%%%%%%%%%PLOT 1%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,1);
h1 = histogram(value_at_low_walker_no_nan,'FaceColor',dev_blue);
h1.NumBins = 30; %Number of bings in the histogram
%%%% Choose correct labels for plot %%%%
xlim([5,25]); xlabel('Sea Surface Temperature (C\circ)');
% xlim([5,25]); xlabel('Mean Water Temperature (C\circ)');
% xlim([-1,2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
% xlim([-5,60]); xlabel('Pseudo-nitzschia (cells/10,000L)');
% xlim([0,25]); xlabel('Minimum Air Temperature (C\circ)');
% xlim([0,250]); xlabel('Upwelling Index (m^3/s/100m)');
ylim([0,30]); ylabel('Frequency');
title({'MUR Sea Surface Temperature';...
    'During Small Runs (Walker Scale 0-1)'})
% title({'Frequency of In Situ Water Temperature';...
%     'During Small Runs (Walker Scale 0-1)'})
% title({'In Situ Log10 Chlorophyl-a During';...
%     'Small Runs (Walker Scale 0-1)'})
% title({'MODIS Aqua Log10 Chlorophyl-a During';...
%     'Small Runs (Walker Scale 0-1)'})
% title({'{\it{Pseudo-nitzschia}} Blooms During';...
%     'Small Runs (Walker Scale 0-1)'})
% title({'In Situ Air Temperature During';...
%     'Small Runs (Walker Scale 0-1)'})
% title({'Upwelling Index During';...
%     'Small Runs (Walker Scale 0-1)'})
hold on;
%Plot dotted lines labeling the mean and mode 
x = line([muHat_low muHat_low],[0 30]);
y = line([mode_low mode_low],[0 30]);
set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
set(y,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
%Add labels for the lines
line1_low = ['\leftarrow mean = ',num2str(muHat_low),' C\circ'];
% line1_low = ['\leftarrow mean = ',num2str(muHat_low),' mg/m^3'];
% line1_low = ['\leftarrow mean = ',num2str(muHat_low),' cells/10,000L'];
% line1_low = ['\leftarrow mean = ',num2str(muHat_low),' m^3/s/100m'];
line2_low = ['standard deviation = ',num2str(sigmaHat_low)];
line3_low = ['\leftarrow mode = ',num2str(mode_low),' C\circ'];
% line3_low = ['\leftarrow mode = ',num2str(mode_low),' mg/m^3'];
% line3_low = ['\leftarrow mode = ',num2str(mode_low),' cells/10,000L'];
% line3_low = ['\leftarrow mode = ',num2str(mode_low),' m^3/s/100m'];
text(muHat_low+0.01,24,{line1_low;line2_low});
text(mode_low+0.01,22.5,{line3_low});

%%%%%%%%%%%%%%%%%%%%%%%PLOT 2%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,2);
h2 = histogram(value_at_med_walker_no_nan,'FaceColor',dev_blue);
h2.NumBins = 30;
xlim([5,25]); xlabel('Sea Surface Temperature (C\circ)');
% xlim([5,25]); xlabel('Mean Water Temperature (C\circ)');
% xlim([-1,2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
% xlim([-5,60]); xlabel('Pseudo-nitzschia (cells/10,000L)');
% xlim([0,25]); xlabel('Minimum Air Temperature (C\circ)');
% xlim([0,250]); xlabel('Upwelling Index (m^3/s/100m)');
ylim([0,30]); ylabel('Frequency');
title({'MUR Sea Surface Temperature';...
    'During Medium Runs (Walker Scale 2-3)'})
% title({'Frequency of In Situ Water Temperature';...
%     'During Medium Runs (Walker Scale 2-3)'})
% title({'In Situ Log10 Chlorophyl-a During';...
%     'Medium Runs (Walker Scale 2-3)'})
% title({'MODIS Aqua Log10 Chlorophyl-a During';...
%     'Medium Runs (Walker Scale 2-3)'})
% title({'{\it{Pseudo-nitzschia}} Blooms During';...
%     'Medium Runs (Walker Scale 2-3)'})
% title({'In Situ Air Temperature During';...
%     'Medium Runs (Walker Scale 2-3)'})
% title({'Upwelling Index During';...
%     'Medium Runs (Walker Scale 2-3)'})
hold on;
x = line([muHat_med muHat_med],[0 30]);
y = line([mode_med mode_med],[0 30]);
set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
set(y,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
line1_med = ['\leftarrow mean = ',num2str(muHat_med),' C\circ'];
% line1_med = ['\leftarrow mean = ',num2str(muHat_med),' m^3/s/100m'];
% line1_med = ['\leftarrow mean = ',num2str(muHat_med),' mg/m^3'];
% line1_med = ['\leftarrow mean = ',num2str(muHat_med),' cells/10,000L'];
line2_med = ['standard deviation = ',num2str(sigmaHat_med)];
line3_med = ['\leftarrow mode = ',num2str(mode_med),' C\circ'];
% line3_med = ['\leftarrow mode = ',num2str(mode_med),' mg/m^3'];
% line3_med = ['\leftarrow mode = ',num2str(mode_med),' cells/10,000L'];
% line3_med = ['\leftarrow mode = ',num2str(mode_med),' m^3/s/100m'];
text(muHat_med+0.01,24,{line1_med;line2_med});
text(mode_med+0.01,22.5,{line3_med});

%%%%%%%%%%%%%%%%%%%%%%%PLOT 3%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,3);
h3 = histogram(value_at_high_walker_no_nan,'FaceColor',dev_blue);
h3.NumBins = 30;
xlim([5,25]); xlabel('Sea Surface Temperature (C\circ)');
% xlim([5,25]); xlabel('Mean Water Temperature (C\circ)');
% xlim([-1,2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
% xlim([-5,60]); xlabel('Pseudo-nitzschia (cells/10,000L)');
% xlim([0,25]); xlabel('Minimum Air Temperature (C\circ)');
% xlim([0,250]); xlabel('Upwelling Index (m^3/s/100m)');
ylim([0,30]); ylabel('Frequency');
title({'MUR Sea Surface Temperature';...
    'During Large Runs (Walker Scale 4-5)'})
% title({'Frequency of In Situ Water Temperature';...
%     'During Large Runs (Walker Scale 4-5)'})
% title({'In Situ Log10 Chlorophyl-a During';...
%     'Large Runs (Walker Scale 4-5)'})
% title({'MODIS Aqua Log10 Chlorophyl-a During';...
%     'Large Runs (Walker Scale 4-5)'})
% title({'{\it{Pseudo-nitzschia}} Blooms During';...
%     'Large Runs (Walker Scale 4-5)'})
% title({'In Situ Air Temperature During';...
%     'Large Runs (Walker Scale 4-5)'})
% title({'Upwelling Index During';...
%     'Large Runs (Walker Scale 4-5)'})
hold on;
x = line([muHat_high muHat_high],[0 30]);
y = line([mode_high mode_high],[0 30]);
set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
set(y,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5);
line1_high = ['\leftarrow mean = ',num2str(muHat_high),' C\circ'];
% line1_high = ['\leftarrow mean = ',num2str(muHat_high),' mg/m^3'];
% line1_high = ['\leftarrow mean = ',num2str(muHat_high),' cells/10,000L'];
% line1_high = ['\leftarrow mean = ',num2str(muHat_high),' m^3/s/100m'];
line2_high = ['standard deviation = ',num2str(sigmaHat_high)];
line3_high = ['\leftarrow mode = ',num2str(mode_high),' C\circ'];
% line3_high = ['\leftarrow mode = ',num2str(mode_high),' mg/m^3'];
% line3_high = ['\leftarrow mode = ',num2str(mode_high),' cells/10,000L'];
% line3_high = ['\leftarrow mode = ',num2str(mode_high),' m^3/s/100m'];
text(muHat_high+0.01,24,{line1_high;line2_high});
text(mode_high+0.01,22.5,{line3_high});

set(findall(zz,'-property','FontSize'),'FontSize',14);

%% PART 3: Plot histogram distribution of data based on walker category
%FOR POSTER with two variables sharing a plot, we plotted in situ WTMP/
%satellite SST together and in situ chl/satellite chl together

%SEE PART 2 for comments

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

value_at_high_walker = NaN();
value_at_med_walker = NaN();
value_at_low_walker = NaN();

for i = 1:length(fileList)
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    value = log10(csv.MODIS_CHL); walker = csv.Walker;
    high_ind = find(walker(:,1)>=4); 
    med_ind = find(walker(:,1)>=2 & walker(:,1)<=3);
    low_ind = find(walker(:,1)<=1);
    value_high = value(high_ind); 
    value_med = value(med_ind); 
    value_low = value(low_ind);
    value_at_high_walker = [value_at_high_walker; value_high];
    value_at_med_walker = [value_at_med_walker; value_med];
    value_at_low_walker = [value_at_low_walker; value_low];
end

SST_at_high_walker_no_nan = sort(value_at_high_walker(~isnan(value_at_high_walker)));   
SST_at_med_walker_no_nan = sort(value_at_med_walker(~isnan(value_at_med_walker)));
SST_at_low_walker_no_nan = sort(value_at_low_walker(~isnan(value_at_low_walker))); 

[SST_muHat_high,SST_sigmaHat_high] = normfit(SST_at_high_walker_no_nan);
[SST_muHat_med,SST_sigmaHat_med] = normfit(SST_at_med_walker_no_nan);
[SST_muHat_low,SST_sigmaHat_low] = normfit(SST_at_low_walker_no_nan);

clear value high_ind med_ind low_ind value_high value_med value_low

value_at_high_walker = NaN();
value_at_med_walker = NaN();
value_at_low_walker = NaN();

for i = 1:length(fileList)
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    value = log10(csv.SCCOOS_CHL); walker = csv.Walker;
    high_ind = find(walker(:,1)>=4); 
    med_ind = find(walker(:,1)>=2 & walker(:,1)<=3);
    low_ind = find(walker(:,1)<=1);
    value_high = value(high_ind); 
    value_med = value(med_ind); 
    value_low = value(low_ind);
    value_at_high_walker = [value_at_high_walker; value_high];
    value_at_med_walker = [value_at_med_walker; value_med];
    value_at_low_walker = [value_at_low_walker; value_low];
end

WTMP_at_high_walker_no_nan = sort(value_at_high_walker(~isnan(value_at_high_walker)));   
WTMP_at_med_walker_no_nan = sort(value_at_med_walker(~isnan(value_at_med_walker)));
WTMP_at_low_walker_no_nan = sort(value_at_low_walker(~isnan(value_at_low_walker))); 

%muHat is the mean, sigmaHat is the standard deviation
[WTMP_muHat_high,WTMP_sigmaHat_high] = normfit(WTMP_at_high_walker_no_nan);
[WTMP_muHat_med,WTMP_sigmaHat_med] = normfit(WTMP_at_med_walker_no_nan);
[WTMP_muHat_low,WTMP_sigmaHat_low] = normfit(WTMP_at_low_walker_no_nan);

%%%%%%%%%%%%%%%%%%%%%% MAKE FIGURE %%%%%%%%%%%%%%%%%%%%%
zz=figure;
dev_blue = [52/255 156/255 196/255]; dev_med_blue = [109 180 208]/255;
dev_lt_blue = [158 205 225]/255; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_med_red = [192 100 100]/255;
dev_lt_red = [192 135 135]/255; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;
purple=[0.4940 0.1840 0.5560]; yellow = [0.9290 0.6940 0.1250];

%%%%%%%%%%%%%%%%%%%%%% PLOT 1 %%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,1);
h1a = histogram(SST_at_low_walker_no_nan,'FaceColor',yellow);
h1a.NumBins = 30; h1a.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

h1b = histogram(WTMP_at_low_walker_no_nan,'FaceColor',green);
h1b.NumBins = 30; h1b.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

title({'Small Runs (Walker Scale 0-1)'})
x = line([SST_muHat_low SST_muHat_low],[0 30]);
y = line([WTMP_muHat_low WTMP_muHat_low],[0 30]);
set(x,'LineStyle',':','Color',yellow,'linewidth',3); 
set(y,'LineStyle',':','Color',dgreen,'linewidth',3); 

SST_line1_low = ['\leftarrow mean = ',num2str(SST_muHat_low),' C\circ'];
SST_line2_low = ['standard deviation = ',num2str(SST_sigmaHat_low),' C\circ'];
text(SST_muHat_low+0.01,23,{SST_line1_low;SST_line2_low},'Color',yellow);

WTMP_line1_low = ['\leftarrow mean = ',num2str(WTMP_muHat_low),' C\circ'];
WTMP_line2_low = ['standard deviation = ',num2str(WTMP_sigmaHat_low),' C\circ'];
text(WTMP_muHat_low+0.01,20,{WTMP_line1_low;WTMP_line2_low},'Color',dgreen);

legend([h1a h1b],{'Satellite SST','{\it{in situ}} Water Temp'})

%%%%%%%%%%%%%%%%%%%%%%% PLOT 2 %%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,2);
h2a = histogram(SST_at_med_walker_no_nan,'FaceColor',yellow);
h2a.NumBins = 30; h2a.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

h2b = histogram(WTMP_at_med_walker_no_nan,'FaceColor',green);
h2b.NumBins = 30; h2b.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

title({'Medium Runs (Walker Scale 2-3)'})
x = line([SST_muHat_med SST_muHat_med],[0 30]);
y = line([WTMP_muHat_med WTMP_muHat_med],[0 30]);
set(x,'LineStyle',':','Color',yellow,'linewidth',3); 
set(y,'LineStyle',':','Color',dgreen,'linewidth',3); 

SST_line1_med = ['\leftarrow mean = ',num2str(SST_muHat_med),' C\circ'];
SST_line2_med = ['standard deviation = ',num2str(SST_sigmaHat_med),' C\circ'];
text(SST_muHat_med+0.01,23,{SST_line1_med;SST_line2_med},'Color',yellow);

WTMP_line1_med = ['\leftarrow mean = ',num2str(WTMP_muHat_med),' C\circ'];
WTMP_line2_med = ['standard deviation = ',num2str(WTMP_sigmaHat_med),' C\circ'];
text(WTMP_muHat_med+0.01,20,{WTMP_line1_med;WTMP_line2_med},'Color',dgreen);

legend([h1a h1b],{'Satellite SST','{\it{in situ}} Water Temp'})

%%%%%%%%%%%%%%%%%%%%%%% PLOT 3 %%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,3);
h3a = histogram(SST_at_high_walker_no_nan,'FaceColor',yellow);
h3a.NumBins = 30; h3a.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

h3b = histogram(WTMP_at_high_walker_no_nan,'FaceColor',green);
h3b.NumBins = 30; h3b.BinWidth = 0.07;
% xlim([5 25]); xlabel('Temperature (C\circ)');
xlim([-1 2]); xlabel('Log10 Chlorophyll-a (mg/m^3)');
ylim([0,25]); ylabel('Frequency');
hold on;

title({'Large Runs (Walker Scale 4-5)'})
x = line([SST_muHat_high SST_muHat_high],[0 30]);
y = line([WTMP_muHat_high WTMP_muHat_high],[0 30]);
set(x,'LineStyle',':','Color',yellow,'linewidth',3); 
set(y,'LineStyle',':','Color',dgreen,'linewidth',3); 

SST_line1_high = ['\leftarrow mean = ',num2str(SST_muHat_high),' C\circ'];
SST_line2_high = ['standard deviation = ',num2str(SST_sigmaHat_high),' C\circ'];
text(SST_muHat_high+0.01,23,{SST_line1_high;SST_line2_high},'Color',yellow);

WTMP_line1_high = ['\leftarrow mean = ',num2str(WTMP_muHat_high),' C\circ'];
WTMP_line2_high = ['standard deviation = ',num2str(WTMP_sigmaHat_high),' C\circ'];
text(WTMP_muHat_high+0.01,20,{WTMP_line1_high;WTMP_line2_high},'Color',dgreen);

legend([h1a h1b],{'Satellite SST','{\it{in situ}} Water Temp'})

set(findall(zz,'-property','FontSize'),'FontSize',14);

saveas(zz,'temp_hists.pdf')


%% PART 4: Plot mean value by Walker

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

walker_array = [0;1;2;3;4;5]; %Array with each possible Walker value
%Predefine empty arrays to hold the value of given variable at each 
%coorespoinding walker value
value_at_walker0 = NaN();value_at_walker1 = NaN();
value_at_walker2 = NaN();value_at_walker3 = NaN();
value_at_walker4 = NaN();value_at_walker5 = NaN();

for i = 1:length(fileList) %loop through files
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    value = csv.PDO_Index; %define variable to study
    walker = csv.Walker;
    %Find indeces of data points at each walker value
    ind0 = find(walker(:,1)==0); ind1 = find(walker(:,1)==1);
    ind2 = find(walker(:,1)==2); ind3 = find(walker(:,1)==3);
    ind4 = find(walker(:,1)==4); ind5 = find(walker(:,1)==5);
    %Find value of variable at given indeces
    value0 = value(ind0); value1 = value(ind1);
    value2 = value(ind2); value3 = value(ind3);
    value4 = value(ind4); value5 = value(ind5);
    %Append value associated with each walker value to array
    value_at_walker0 = [value_at_walker0; value0];
    value_at_walker1 = [value_at_walker1; value1];
    value_at_walker2 = [value_at_walker2; value2];
    value_at_walker3 = [value_at_walker3; value3];
    value_at_walker4 = [value_at_walker4; value4];
    value_at_walker5 = [value_at_walker5; value5];
end

%Remove nan values from arrays
value_at_walker0_no_nan = value_at_walker0(~isnan(value_at_walker0));   
value_at_walker1_no_nan = value_at_walker1(~isnan(value_at_walker1));
value_at_walker2_no_nan = value_at_walker2(~isnan(value_at_walker2));
value_at_walker3_no_nan = value_at_walker3(~isnan(value_at_walker3));
value_at_walker4_no_nan = value_at_walker4(~isnan(value_at_walker4));
value_at_walker5_no_nan = value_at_walker5(~isnan(value_at_walker5));

%Calculate mean of values associated with each walker value
mean_value0 = nanmean(value_at_walker0_no_nan);
mean_value1 = nanmean(value_at_walker1_no_nan);
mean_value2 = nanmean(value_at_walker2_no_nan);
mean_value3 = nanmean(value_at_walker3_no_nan);
mean_value4 = nanmean(value_at_walker4_no_nan);
mean_value5 = nanmean(value_at_walker5_no_nan);
mean_value_array = [mean_value0; mean_value1; mean_value2; mean_value3; mean_value4; mean_value5];

%Calculate statistics
stats = fitlm(walker_array,mean_value_array);
rsq = stats.Rsquared.Ordinary;

zz=figure; %Set up figure
dev_blue = [52/255 156/255 196/255]; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;

%%%%%%% PLOT %%%%%%%
scatter(walker_array,mean_value_array,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
%     scatter(var1,var2,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
% scatter(walker_array,log10(mean_value_array),50,'MarkerFaceColor',green,'MarkerEdgeColor',dgreen); 
xlabel('Walker Value','FontSize',12); xlim([-1,6]);
% ylabel('in situ Water Temperature (C\circ)','FontSize',12); ylim([5,25]);
% ylabel('MUR SST (C\circ)','FontSize',12); ylim([5,25]);
% ylabel('{\it{In Situ}} Air Temperature (C\circ)','FontSize',12); ylim([10,16]);
% ylabel('Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,1]);
% ylabel('In Situ Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,1.5]);
% ylabel('MODIS Aqua Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
% ylabel('MODIS Aqua Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,0.5]);
% ylabel('Upwelling Index (m^3/s/100 m)','FontSize',12); ylim([50,200]);
% ylabel('{\it{Pseudo-nitzschia}} (cells/10,000L)','FontSize',12); ylim([0,15]);
% ylabel('ENSO Index','FontSize',12); ylim([-0.2,0.2]);
ylabel('PDO Index','FontSize',12); ylim([-1,0]);

h=lsline; set(h,'color','k','LineWidth',0.5);
rsq_text = ['r^2 = ',num2str(rsq)];
text(3.5,-0.15,rsq_text,'FontSize',12);

%% PART 5: Plot mean value by Walker 
%Figure FOR POSTER -- WTMP/SST & in situ CHL/satellite CHL in one plot
%
%See PART 4 for comments 

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

walker_array = [0;1;2;3;4;5];

SST_at_walker0 = NaN();SST_at_walker1 = NaN();
SST_at_walker2 = NaN();SST_at_walker3 = NaN();
SST_at_walker4 = NaN();SST_at_walker5 = NaN();

WTMP_at_walker0 = NaN();WTMP_at_walker1 = NaN();
WTMP_at_walker2 = NaN();WTMP_at_walker3 = NaN();
WTMP_at_walker4 = NaN();WTMP_at_walker5 = NaN();

CHL_at_walker0 = NaN();CHL_at_walker1 = NaN();
CHL_at_walker2 = NaN();CHL_at_walker3 = NaN();
CHL_at_walker4 = NaN();CHL_at_walker5 = NaN();

insituCHL_at_walker0 = NaN();insituCHL_at_walker1 = NaN();
insituCHL_at_walker2 = NaN();insituCHL_at_walker3 = NaN();
insituCHL_at_walker4 = NaN();insituCHL_at_walker5 = NaN();

for i = 1:length(fileList)
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    walker = csv.Walker;
    SST = csv.MUR_SST; WTMP = csv.WTMPmean;
    CHL = log10(csv.MODIS_CHL); insituCHL = log10(csv.SCCOOS_CHL);
    
    ind0 = find(walker(:,1)==0); ind1 = find(walker(:,1)==1);
    ind2 = find(walker(:,1)==2); ind3 = find(walker(:,1)==3);
    ind4 = find(walker(:,1)==4); ind5 = find(walker(:,1)==5);
    
    SST0 = SST(ind0); SST1 = SST(ind1);
    SST2 = SST(ind2); SST3 = SST(ind3);
    SST4 = SST(ind4); SST5 = SST(ind5);
    
    WTMP0 = WTMP(ind0); WTMP1 = WTMP(ind1);
    WTMP2 = WTMP(ind2); WTMP3 = WTMP(ind3);
    WTMP4 = WTMP(ind4); WTMP5 = WTMP(ind5);
    
    CHL0 = CHL(ind0); CHL1 = CHL(ind1);
    CHL2 = CHL(ind2); CHL3 = CHL(ind3);
    CHL4 = CHL(ind4); CHL5 = CHL(ind5);
    
    insituCHL0 = insituCHL(ind0); insituCHL1 = insituCHL(ind1);
    insituCHL2 = insituCHL(ind2); insituCHL3 = insituCHL(ind3);
    insituCHL4 = insituCHL(ind4); insituCHL5 = insituCHL(ind5);
    
    SST_at_walker0 = [SST_at_walker0; SST0];
    SST_at_walker1 = [SST_at_walker1; SST1];
    SST_at_walker2 = [SST_at_walker2; SST2];
    SST_at_walker3 = [SST_at_walker3; SST3];
    SST_at_walker4 = [SST_at_walker4; SST4];
    SST_at_walker5 = [SST_at_walker5; SST5];
    
    WTMP_at_walker0 = [WTMP_at_walker0; WTMP0];
    WTMP_at_walker1 = [WTMP_at_walker1; WTMP1];
    WTMP_at_walker2 = [WTMP_at_walker2; WTMP2];
    WTMP_at_walker3 = [WTMP_at_walker3; WTMP3];
    WTMP_at_walker4 = [WTMP_at_walker4; WTMP4];
    WTMP_at_walker5 = [WTMP_at_walker5; WTMP5];
    
    CHL_at_walker0 = [CHL_at_walker0; CHL0];
    CHL_at_walker1 = [CHL_at_walker1; CHL1];
    CHL_at_walker2 = [CHL_at_walker2; CHL2];
    CHL_at_walker3 = [CHL_at_walker3; CHL3];
    CHL_at_walker4 = [CHL_at_walker4; CHL4];
    CHL_at_walker5 = [CHL_at_walker5; CHL5];
    
    insituCHL_at_walker0 = [insituCHL_at_walker0; insituCHL0];
    insituCHL_at_walker1 = [insituCHL_at_walker1; insituCHL1];
    insituCHL_at_walker2 = [insituCHL_at_walker2; insituCHL2];
    insituCHL_at_walker3 = [insituCHL_at_walker3; insituCHL3];
    insituCHL_at_walker4 = [insituCHL_at_walker4; insituCHL4];
    insituCHL_at_walker5 = [insituCHL_at_walker5; insituCHL5];
end

SST_at_walker0_no_nan = SST_at_walker0(~isnan(SST_at_walker0));   
SST_at_walker1_no_nan = SST_at_walker1(~isnan(SST_at_walker1));
SST_at_walker2_no_nan = SST_at_walker2(~isnan(SST_at_walker2));
SST_at_walker3_no_nan = SST_at_walker3(~isnan(SST_at_walker3));
SST_at_walker4_no_nan = SST_at_walker4(~isnan(SST_at_walker4));
SST_at_walker5_no_nan = SST_at_walker5(~isnan(SST_at_walker5));

WTMP_at_walker0_no_nan = WTMP_at_walker0(~isnan(WTMP_at_walker0));   
WTMP_at_walker1_no_nan = WTMP_at_walker1(~isnan(WTMP_at_walker1));
WTMP_at_walker2_no_nan = WTMP_at_walker2(~isnan(WTMP_at_walker2));
WTMP_at_walker3_no_nan = WTMP_at_walker3(~isnan(WTMP_at_walker3));
WTMP_at_walker4_no_nan = WTMP_at_walker4(~isnan(WTMP_at_walker4));
WTMP_at_walker5_no_nan = WTMP_at_walker5(~isnan(WTMP_at_walker5));

CHL_at_walker0_no_nan = CHL_at_walker0(~isnan(CHL_at_walker0));   
CHL_at_walker1_no_nan = CHL_at_walker1(~isnan(CHL_at_walker1));
CHL_at_walker2_no_nan = CHL_at_walker2(~isnan(CHL_at_walker2));
CHL_at_walker3_no_nan = CHL_at_walker3(~isnan(CHL_at_walker3));
CHL_at_walker4_no_nan = CHL_at_walker4(~isnan(CHL_at_walker4));
CHL_at_walker5_no_nan = CHL_at_walker5(~isnan(CHL_at_walker5));

insituCHL_at_walker0_no_nan = insituCHL_at_walker0(~isnan(insituCHL_at_walker0));   
insituCHL_at_walker1_no_nan = insituCHL_at_walker1(~isnan(insituCHL_at_walker1));
insituCHL_at_walker2_no_nan = insituCHL_at_walker2(~isnan(insituCHL_at_walker2));
insituCHL_at_walker3_no_nan = insituCHL_at_walker3(~isnan(insituCHL_at_walker3));
insituCHL_at_walker4_no_nan = insituCHL_at_walker4(~isnan(insituCHL_at_walker4));
insituCHL_at_walker5_no_nan = insituCHL_at_walker5(~isnan(insituCHL_at_walker5));

mean_SST0 = nanmean(SST_at_walker0_no_nan);
mean_SST1 = nanmean(SST_at_walker1_no_nan);
mean_SST2 = nanmean(SST_at_walker2_no_nan);
mean_SST3 = nanmean(SST_at_walker3_no_nan);
mean_SST4 = nanmean(SST_at_walker4_no_nan);
mean_SST5 = nanmean(SST_at_walker5_no_nan);

mean_WTMP0 = nanmean(WTMP_at_walker0_no_nan);
mean_WTMP1 = nanmean(WTMP_at_walker1_no_nan);
mean_WTMP2 = nanmean(WTMP_at_walker2_no_nan);
mean_WTMP3 = nanmean(WTMP_at_walker3_no_nan);
mean_WTMP4 = nanmean(WTMP_at_walker4_no_nan);
mean_WTMP5 = nanmean(WTMP_at_walker5_no_nan);

mean_CHL0 = nanmean(CHL_at_walker0_no_nan);
mean_CHL1 = nanmean(CHL_at_walker1_no_nan);
mean_CHL2 = nanmean(CHL_at_walker2_no_nan);
mean_CHL3 = nanmean(CHL_at_walker3_no_nan);
mean_CHL4 = nanmean(CHL_at_walker4_no_nan);
mean_CHL5 = nanmean(CHL_at_walker5_no_nan);

mean_insituCHL0 = nanmean(insituCHL_at_walker0_no_nan);
mean_insituCHL1 = nanmean(insituCHL_at_walker1_no_nan);
mean_insituCHL2 = nanmean(insituCHL_at_walker2_no_nan);
mean_insituCHL3 = nanmean(insituCHL_at_walker3_no_nan);
mean_insituCHL4 = nanmean(insituCHL_at_walker4_no_nan);
mean_insituCHL5 = nanmean(insituCHL_at_walker5_no_nan);

SST_mean_value_array = [mean_SST0; mean_SST1; mean_SST2; mean_SST3; mean_SST4; mean_SST5];
SST_stats = fitlm(walker_array,SST_mean_value_array);
SST_rsq = SST_stats.Rsquared.Ordinary;

WTMP_mean_value_array = [mean_WTMP0; mean_WTMP1; mean_WTMP2; mean_WTMP3; mean_WTMP4; mean_WTMP5];
WTMP_stats = fitlm(walker_array,WTMP_mean_value_array);
WTMP_rsq = WTMP_stats.Rsquared.Ordinary;

CHL_mean_value_array = [mean_CHL0; mean_CHL1; mean_CHL2; mean_CHL3; mean_CHL4; mean_CHL5];
CHL_stats = fitlm(walker_array,CHL_mean_value_array);
CHL_rsq = CHL_stats.Rsquared.Ordinary;

insituCHL_mean_value_array = [mean_insituCHL0; mean_insituCHL1; mean_insituCHL2; mean_insituCHL3; mean_insituCHL4; mean_insituCHL5];
insituCHL_stats = fitlm(walker_array,insituCHL_mean_value_array);
insituCHL_rsq = insituCHL_stats.Rsquared.Ordinary;


%%%%%%%%%%%%%% MAKE PLOT %%%%%%%%%%%%%%%%%%%%%%%
zz=figure;
dev_blue = [52/255 156/255 196/255]; dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255]; dev_dred = [127/255 37/255 37/255];
green=[0 205 102]/255; dgreen=[46 139 87]/255;
left_color = [0 0 0];
right_color = [0 0 0];
set(zz,'defaultAxesColorOrder',[left_color;right_color])
yyaxis left;
f1=scatter(walker_array,SST_mean_value_array,50,'MarkerFaceColor',dev_dblue,'MarkerEdgeColor',dev_blue); 
xlabel('Walker Value','FontSize',12); xlim([-1,6]);
ylabel('Temperature (C\circ)','FontSize',12); ylim([10,20]); ax.YAxis.Color = 'k';
h1=lsline; set(h1,'Color',dev_dblue,'LineWidth',0.5);
SST_rsq_text = ['r^2 = ',num2str(SST_rsq)];
text(1.5,18,SST_rsq_text,'FontSize',12,'Color',dev_dblue);
hold on;

f2=scatter(walker_array,WTMP_mean_value_array,50,'MarkerFaceColor',dev_blue,'MarkerEdgeColor',dev_dblue); 
xlabel('Walker Value','FontSize',12); xlim([-1,6]);
ylabel('Temperature (C\circ)','FontSize',12); ylim([10,20]); 
h2=lsline; set(h2,'Color',dev_blue,'LineWidth',0.5);
WTMP_rsq_text = ['r^2 = ',num2str(WTMP_rsq)];
text(2,15.5,WTMP_rsq_text,'FontSize',12,'Color',dev_blue);
hold on;

yyaxis right;
f3=scatter(walker_array,CHL_mean_value_array,50,'MarkerFaceColor',dgreen,'MarkerEdgeColor',green); 
xlabel('Walker Value','FontSize',12); xlim([-1,6]);
ylabel('Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,1.5]); ax.YAxis.Color = 'k';
h2=lsline; set(h2,'Color',dgreen,'LineWidth',0.5);
CHL_rsq_text = ['r^2 = ',num2str(CHL_rsq)];
text(0,0.2,CHL_rsq_text,'FontSize',12,'Color',dgreen);
hold on;

f4=scatter(walker_array,insituCHL_mean_value_array,50,'MarkerFaceColor',green,'MarkerEdgeColor',dgreen); 
xlabel('Walker Value','FontSize',12); xlim([-1,6]);
ylabel('Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,1.5]); ax.YAxis.Color = 'k';
h2=lsline; set(h2,'Color',green,'LineWidth',0.5);
insituCHL_rsq_text = ['r^2 = ',num2str(insituCHL_rsq)];
text(-0.5,0.55,insituCHL_rsq_text,'FontSize',12,'Color',green);

legend([f1,f2,f3,f4],{'Satellite SST','{\it{in situ}} Water Temp','Satellite Log10 Chl-a','{\it{in situ}} Log10 Chl-a'});
% export_fig(zz,'poster.svg')

%% Plot histogram distribution of data based on walker category AND by region (UNFINISHED)
clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%NORTH
value_at_high_walker_north = NaN();
value_at_med_walker_north = NaN();
value_at_low_walker_north = NaN();
%CENTRAL
value_at_high_walker_central = NaN();
value_at_med_walker_central = NaN();
value_at_low_walker_central = NaN();
%SOUTH
value_at_high_walker_south = NaN();
value_at_med_walker_south = NaN();
value_at_low_walker_south = NaN();


for i = 1:length(fileList)
    file = fileList(i).name;
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    value = csv.MUR_SST; walker = csv.Walker;
    high_ind = find(walker(:,1)>=4); 
    med_ind = find(walker(:,1)>=2 & walker(:,1)<=3);
    low_ind = find(walker(:,1)<=1);
    value_high = value(high_ind);
    value_med = value(med_ind);
    value_low = value(low_ind);
    if i == 3 || i == 7 %Monterey or SF (North)
        value_at_high_walker_north = [value_at_high_walker_north; value_high];
        value_at_med_walker_north = [value_at_med_walker_north; value_med];
        value_at_low_walker_north = [value_at_low_walker_north; value_low];
    elseif i == 8 || i == 9 %Santa Barbara or Ventura (Central)
        value_at_high_walker_central = [value_at_high_walker_central; value_high];
        value_at_med_walker_central = [value_at_med_walker_central; value_med];
        value_at_low_walker_central = [value_at_low_walker_central; value_low];
    else %South
        value_at_high_walker_south = [value_at_high_walker_south; value_high];
        value_at_med_walker_south = [value_at_med_walker_south; value_med];
        value_at_low_walker_south = [value_at_low_walker_south; value_low];
    end
end

%NORTH
value_at_high_walker_no_nan_north = sort(value_at_high_walker_north(~isnan(value_at_high_walker_north)));   
value_at_med_walker_no_nan_north = sort(value_at_med_walker_north(~isnan(value_at_med_walker_north)));
value_at_low_walker_no_nan_north = sort(value_at_low_walker_north(~isnan(value_at_low_walker_north))); 
%CENTRAL
value_at_high_walker_no_nan_central = sort(value_at_high_walker_central(~isnan(value_at_high_walker_central)));   
value_at_med_walker_no_nan_central = sort(value_at_med_walker_central(~isnan(value_at_med_walker_central)));
value_at_low_walker_no_nan_central = sort(value_at_low_walker_central(~isnan(value_at_low_walker_central))); 
%SOUTH
value_at_high_walker_no_nan_south = sort(value_at_high_walker_south(~isnan(value_at_high_walker_south)));   
value_at_med_walker_no_nan_south = sort(value_at_med_walker_south(~isnan(value_at_med_walker_south)));
value_at_low_walker_no_nan_south = sort(value_at_low_walker_south(~isnan(value_at_low_walker_south))); 

%muHat is the mean, sigmaHat is the standard deviation
%NORTH
mode_high_north = mode(value_at_high_walker_no_nan_north);
mode_med_north = mode(value_at_med_walker_no_nan_north);
mode_low_north = mode(value_at_low_walker_no_nan_north);
[muHat_high_north,sigmaHat_high_north] = normfit(value_at_high_walker_no_nan_north);
[muHat_med_north,sigmaHat_med_north] = normfit(value_at_med_walker_no_nan_north);
[muHat_low_north,sigmaHat_low_north] = normfit(value_at_low_walker_no_nan_north);
%CENTRAL
mode_high_central = mode(value_at_high_walker_no_nan_central);
mode_med_central = mode(value_at_med_walker_no_nan_central);
mode_low_central = mode(value_at_low_walker_no_nan_central);
[muHat_high_central,sigmaHat_high_central] = normfit(value_at_high_walker_no_nan_central);
[muHat_med_central,sigmaHat_med_central] = normfit(value_at_med_walker_no_nan_central);
[muHat_low_central,sigmaHat_low_central] = normfit(value_at_low_walker_no_nan_central);
%SOUTH
mode_high_south = mode(value_at_high_walker_no_nan_south);
mode_med_south = mode(value_at_med_walker_no_nan_south);
mode_low_south = mode(value_at_low_walker_no_nan_south);
[muHat_high_south,sigmaHat_high_south] = normfit(value_at_high_walker_no_nan_south);
[muHat_med_south,sigmaHat_med_south] = normfit(value_at_med_walker_no_nan_south);
[muHat_low_south,sigmaHat_low_south] = normfit(value_at_low_walker_no_nan_south);

HIST_DATA = [value_at_high_walker_no_nan_north;value_at_med_walker_no_nan_north;...
    value_at_low_walker_no_nan_north;value_at_high_walker_no_nan_central;...
    value_at_med_walker_no_nan_central;value_at_low_walker_no_nan_central;...
    value_at_high_walker_no_nan_south;value_at_med_walker_no_nan_south;...
    value_at_low_walker_no_nan_south];
ALL_MEANS = [muHat_high_north;muHat_med_north;muHat_low_north;...
    muHat_high_central;muHat_med_central;muHat_low_central;...
    muHat_high_south;muHat_med_south;muHat_low_south];
ALL_STD = [sigmaHat_high_north;sigmaHat_med_north;sigmaHat_low_north;...
    sigmaHat_high_central;sigmaHat_med_central;sigmaHat_low_central;...
    sigmaHat_high_south;sigmaHat_med_south;sigmaHat_low_south];
ALL_MODES = [];

zz=figure;
dev_blue = [52/255 156/255 196/255];
dev_dblue = [16/255 82/255 111/255];
dev_red = [192/255 74/255 74/255];

%%%%%%%%% LOOP THROUGH DATA TO PLOT %%%%%%%%%%%%%

%plot 1
subplot(1,3,1);
h1 = histogram(value_at_low_walker_no_nan,'FaceColor',dev_blue);
h1.NumBins = 30;
xlim([5,25]); xlabel('Sea Surface Temperature (C\circ)');
ylim([0,22]); ylabel('Frequency');
title({'Frequency of MUR Sea Surface Temperature Measurements';...
    'During Small Runs (Walker Scale 0-1)'})
hold on;
x = line([muHat_low muHat_low],[0 22]);
set(x,'LineStyle',':','Color',[.6 .6 .6],'linewidth',1.5); 
line1_low = ['\leftarrow mean = ',num2str(muHat_low),' mg/m^3'];
line2_low = ['standard deviation = ',num2str(sigmaHat_low)];
line3_low = ['mode = ',num2str(mode_low)];
text(muHat_low+0.5,20,{line1_low;line2_low;line3_low});

set(findall(zz,'-property','FontSize'),'FontSize',14);

%% Make box plots by Walker Value
%Info: The line in the middle of the dataset is the median, where the top
%and bottom lines are the 25th and 75th percentiles (aka the median of the 
%upper and lower halves). The ends of the 'whiskers' represent the minimum
%and maximum of the dataset, with additional points representing outliers.

clc
clear
clf
close all

currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/FULL_SPREADSHEETS_DONE_small_boxes/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

all_values = NaN();all_walkers = NaN();
for i = 1:length(fileList)
    file = fileList(i).name;
    csv = readtable(fullfile(currentDir,file));
    value = csv.SCCOOS_CHL; walker = csv.Walker;
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
ylabel('Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
% ylabel('In Situ Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,1.5]);
%     ylabel('MODIS Aqua Chlorophyll-a (mg/m^3)','FontSize',12); ylim([0,20]);
% ylabel('MODIS Aqua Log10 Chl-a (mg/m^3)','FontSize',12); ylim([0,0.5]);
% ylabel('Upwelling Index (m^3/s/100 m)','FontSize',12); ylim([0,250]);
% ylabel('{\it{Pseudo-nitzschia}} (cells/10,000L)','FontSize',12); ylim([0,15]);
