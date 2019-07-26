%
%NASA DEVELOP 
%JPL Summer 2018 Southern California Water Resources II
%
%COMPONENTS
%PART 1: Reformat 15 day files
%PART 2: Adds NaN rows for months/days/years not present in 15day files
%PART 3: Reformat monthly files
%PART 4: Add NaN rows for months and years not present in monthly files
%PART 5: Calculate monthly climatologies & anomalies
%PART 6: Plot monthly anomalies
%PART 7: Plot max and mean Walker per year

%% PART 1: Reformat 15day files

clear
currentDir =  '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/Grunion_Greeters/GRUNNY_from_lael/Done_date/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/Grunion_Greeters/15day/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for j = 1:length(fileList)
    file = fileList(j).name; 
    name = file(13:end-4);
    csv = readtable(fullfile(currentDir,file));
    date = table2array(csv(:,2)); %date is read as a datetime variable
    years = date.Year; years = array2table(years,'VariableNames',{'YYYY'});
    months = date.Month; months = array2table(months,'VariableNames',{'MM'});
    days = date.Day; days = array2table(days,'VariableNames',{'DD'});
    walker = csv(:,3);

    %Concatenate to create one table 
    mastermat = [years,months,days,walker];
    writetable(mastermat,[newDir,name,'_15day.csv']); %saves file as a new '15day' csv
    
end

%% PART 2: Adds NaN rows for months/days/years not present in 15day files
%This fills in gaps when plotting 

clear
currentDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/Grunion_Greeters/15day/'; %directory containing the files
newDir = '/Users/aljones/Documents/Lexi_DEVELOP/Official_in_situ_Data_Folder/Grunion_Greeters/15day/15day_all_days/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Create arrays for the years, months, and days
years = (2003:2018); years = years(:); 
months = (1:12); months = months(:);
days = [1;16];

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-4);
    csv = readtable(fullfile(currentDir,file));
    walker = str2double(csv.MaxWalker); walker = array2table(walker,'VariableNames',{'MaxWalker'});
    table = [csv(:,1:3),walker];
    
    %Fill in rows that are missing
    count = 0; %counter for index in csv file
    for i = 1:length(years) %loop through years 
        for ii = 1:length(months) %loop through months
            if (i == 16 && ii == 7) %no data past 6/2018, fill in NaNs until end of 2018
                new_row = NaN(12,4);
                new_row(1:12,1) = years(i);
                new_row(1,2) = months(ii); new_row(2,2) = months(ii); 
                new_row(3,2) = months(ii+1);new_row(4,2) = months(ii+1); 
                new_row(5,2) = months(ii+2); new_row(6,2) = months(ii+2);
                new_row(7,2) = months(ii+3); new_row(8,2) = months(ii+3); 
                new_row(9,2) = months(ii+4);new_row(10,2) = months(ii+4); 
                new_row(11,2) = months(ii+5); new_row(12,2) = months(ii+5);
                [new_row(1,3),new_row(3,3),new_row(5,3),new_row(7,3),new_row(9,3),new_row(11,3)] = deal(1); %assigns all of these days 1
                [new_row(2,3),new_row(4,3),new_row(6,3),new_row(8,3),new_row(10,3),new_row(12,3)] = deal(16); %assigns all of these days 16
                new_row = array2table(new_row,'VariableNames',{'YYYY','MM','DD','MaxWalker'});
                table = [table(1:count,:);new_row];
                break
            else
                for iii = 1:2 %loop through the two 15day sets in each month
                    ind = find(csv.YYYY == years(i) & csv.MM == months(ii) & csv.DD == days(iii));      
                    if isempty(ind) %find missing rows
                        new_row = NaN(1,4);
                        new_row(1,1) = years(i);
                        new_row(1,2) = months(ii);
                        new_row(1,3) = days(iii);
                        new_row = array2table(new_row,'VariableNames',{'YYYY','MM','DD','MaxWalker'});
                        table = [table(1:count,:); new_row; table(count+1:height(table),:)];
                    end             
                    count = count + 1;
                end
            end  
        end
    end
    
    %concatenate to create one table 
    writetable(table,[newDir,name,'_all_days.csv']); %saves file as a new csv
end

%% PART 3: Reformat monthly files

clear
currentDir =  '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/GRUNNY_from_lael/Done_monthly/'; %directory containing the files
newDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for j = 1:length(fileList)
    file = fileList(j).name; 
    name = file(13:end-4);
    csv = readtable(fullfile(currentDir,file));
    date = table2array(csv(:,2));
    months = NaN(height(csv),1);
    years = NaN(height(csv),1);
    for i = 1:length(date)
        cell = date(i); str = cell{1};
        month_temp = str2double(str(1)); months(i,1)=month_temp;
        year_temp = str2double(str(5:8)); years(i,1)=year_temp;
    end    
    %date is read as a datetime variable
    years = array2table(years,'VariableNames',{'YYYY'});
    months = array2table(months,'VariableNames',{'MM'});
    walker = array2table(str2double(table2array(csv(:,3))),'VariableNames',{'Walker'});

    %concatenate to create on table 
    mastermat = [years,months,walker];
    writetable(mastermat,[newDir,name,'_monthly.csv']); %saves file as a new 'daily' csv
    
end

%% PART 4: Add NaN rows for months and years not present in monthly files
%This fills in gaps when plotting

clear
currentDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/'; %directory containing the files
newDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/monthly_all_months/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%create arrays of the years and months 
years = (2003:2018); years = years(:); 
months = (1:12); months = months(:);

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-12);
    csv = readtable(fullfile(currentDir,file));
    table = csv(:,1:3);
    count = 0; %counter for index in csv file
    for i = 1:length(years) %loop through years 
        for ii = 1:length(months) %loop through months
            ind = find(csv.YYYY == years(i) & csv.MM == months(ii));
            if (i == 16 && ii == 7)  %no data past 6/2018, fill in NaNs until end of 2018
                new_row = NaN(6,3);
                new_row(1:6,1) = years(i);
                new_row(1,2) = months(ii); new_row(2,2) = months(ii+1); new_row(3,2) = months(ii+2);
                new_row(4,2) = months(ii+3); new_row(5,2) = months(ii+4); new_row(6,2) = months(ii+5);
                new_row = array2table(new_row,'VariableNames',{'YYYY','MM','Walker'});
                table = [table(1:count,:);new_row];
                break
            else        
                if isempty(ind) %find missing months
                    new_row = NaN(1,3);
                    new_row(1,1) = years(i);
                    new_row(1,2) = months(ii);
                    new_row = array2table(new_row,'VariableNames',{'YYYY','MM','Walker'});
                    table = [table(1:count,:); new_row; table(count+1:height(table),:)];
                end             
                count = count + 1;
            end  
        end
    end
    
    %concatenate to create one table
    mastermat = [table];
    writetable(mastermat,[newDir,name,'_monthly_all_months.csv']); %saves file as a new csv
end

%% PART 5: Calculate monthly climatologies & anomalies

clear
currentDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/monthly_all_months/'; %directory containing the files
newDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/monthly_all_months/monthly_anomalies/'; %directory to put the new files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-15);
    csv = readtable(fullfile(currentDir,file));

    %grab columns with these specific titles from input file
    walker = csv.Walker;
    year = array2table(csv.YYYY,'VariableNames',{'YYYY'});  
    month = csv.MM;
    
    %Calculate climatologies
    climatologies = NaN(12,1);
    for ii = 1:12
        indeces_of_month = find(month==ii);
        walker_clim=nanmean(walker(indeces_of_month));
        climatologies(ii,1)=walker_clim; 
    end
    
    %Calculate anomalies
    anomalies = NaN(height(csv),1);
    for iii = 1:height(csv)
        mon = month(iii);
        anomalies(iii,1) = walker(iii)-climatologies(mon,1);
    end   
    
    anomalies = array2table(anomalies,'VariableNames',{'Walker'});
    month = array2table(month,'VariableNames',{'MM'});
    %concatenate to create on table 
    mastermat = [year,month,anomalies];
    writetable(mastermat,[newDir,name,'_anomalies.csv']); %saves file as a new 'monthly' csv
    
end
    
%% PART 6: Plot monthly anomalies

clear
currentDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/monthly_all_months/monthly_anomalies/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

%Loop through files to be plotted
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-22);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));
    
    %This loop manually assigns an order to the locations (North to South)
    if i==1 %Cabrillo
        subplot(length(fileList),1,6)
    elseif i==2 %Malibu
        subplot(length(fileList),1,5)
    elseif i==3 %Monterey
        subplot(length(fileList),1,2)
    elseif i==4 %Oceanside
        subplot(length(fileList),1,8)
    elseif i==5 %Orange
        subplot(length(fileList),1,7)
    elseif i==6 %San Diego
        subplot(length(fileList),1,9)
    elseif i==7 %SF
        subplot(length(fileList),1,1)
    elseif i==8 %Santa Barbara
        subplot(length(fileList),1,3)
    elseif i==9 %Ventura
        subplot(length(fileList),1,4)
    end

    %create red bars for a positive values and blue bars for negative values
    neg=csv.Walker;
    neg(neg>0)=nan;
    pos=csv.Walker;
    pos(pos<0)=nan;
    
    %%%Left Axis
    yyaxis left
    
    neg_chart = bar(neg,'FaceColor',dev_blue);
    hold on
    pos_chart=bar(pos,'FaceColor',dev_red);
    hold on
    
    ylim([-3.5 3.5]);
    axes = gca;
    axes.YColor = 'k';
    
    if i==2
        ylabel('Walker Value','Color','k');
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
    xticks(6:12:365); 
    xlim([0 190]);
    xticklabels({'2003','2004','2005','2006','2007','2008'...
         ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    ylabel(newName);
    axes = gca;
    axes.YColor = 'k';
    axes.TickLength = [0 0];
    
    %Title on first graph only
    if i == 7 %place title above SF, which should be the first plot
        title('Grunion Greeters Walker Scale Monthly Anomalies 2003-2018');
    end
end

%% PART 7: Plot max and mean Walker per year

clear
currentDir = '/Users/lexijones/Desktop/DEVELOP_work/Grunion_Greeters/monthly/'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

%Loop through files
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-12);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));

    %calculate mean & max per year
    walker = csv.Walker;
    years = csv.YYYY;
    all_yrs = (2003:2018);
    yr_avg = NaN(length(all_yrs),1);
    yr_max = NaN(length(all_yrs),1);
    for ii = 1:length(all_yrs)
        ind = find(years == all_yrs(ii));
        if isempty(ind)
            yr_avg(ii,1) = NaN;
            yr_max(ii,1) = NaN;
        else
            yr_avg(ii,1) = nanmean(walker(ind));
            yr_max(ii,1) = nanmax(walker(ind));
        end
    end

    %%%Left Axis
    yyaxis left
    
    %This loop manually assigns an order to the locations (North to South)
    if i==1 %Cabrillo
        subplot(length(fileList),1,6)
    elseif i==2 %Malibu
        subplot(length(fileList),1,5)
    elseif i==3 %Monterey
        subplot(length(fileList),1,2)
    elseif i==4 %Oceanside
        subplot(length(fileList),1,8)
    elseif i==5 %Orange
        subplot(length(fileList),1,7)
    elseif i==6 %San Diego
        subplot(length(fileList),1,9)
    elseif i==7 %SF
        subplot(length(fileList),1,1)
    elseif i==8 %Santa Barbara
        subplot(length(fileList),1,3)
    elseif i==9 %Ventura
        subplot(length(fileList),1,4)
    end

    mean_chart = bar(yr_avg,'FaceColor',dev_blue);
    hold on
%     max_chart=bar(yr_max,'FaceColor',dev_red);
%     hold on

    ylim([0 5]);
    axes = gca;
    axes.YColor = 'k';
    if i==2
        ylabel('Walker Value','Color','k');
    end
    
    %%%Right Axis
    yyaxis right

    %Add labels and format axis
    xticks(1:1:17); 
    xlim([0 17]);
    xticklabels({'2003','2004','2005','2006','2007','2008'...
         ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    ylabel(newName);
    axes = gca;
    axes.YColor = 'k';
    axes.TickLength = [0 0];

    %Title on first graph only
    if i == 7 %place title above SF, which should be the first plot
        title('Grunion Greeters Yearly Average Walker Value 2003-2018');
    end
end
