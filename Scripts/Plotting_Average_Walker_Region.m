%% Plot Average Walker Per Region
clc
clear
currentDir = 'C:\Users\peacock\Desktop\Develop\Grunion\monthly_region'; %directory containing the files
fileList = dir(fullfile(currentDir,'*.csv')); %finds all of the files in the current directory with .csv extention

%Figure window
zz=figure;
set(zz,'Position',[0,0,1920,1920]);
dev_blue = [52/255 156/255 196/255];

set(gca, 'FontName', 'Garamond')
for i = 1:length(fileList)
    file = fileList(i).name; 
    name = file(1:end-8);
    newName = strrep(name,'_',' ');
    csv = readtable(fullfile(currentDir,file));

    %calculate mean & max per year
    walker = csv.Walker;
    years = csv(:,1);
    all_yrs = (2004:2018)';
	yr_avg = NaN(length(all_yrs),1);
% %     yr_max = NaN(length(all_yrs),1);
    for ii = 1:length(all_yrs)
        ind = find(years{:,1} == all_yrs(ii));
        if isempty(ind)
            yr_avg(ii,1) = NaN;
%             yr_max(ii,1) = NaN;
        else
            yr_avg(ii,1) = nanmean(walker(ind));

%             yr_max(ii,1) = nanmax(walker(ind));
        end
    end

    %%%Left Axis
    yyaxis left

    %This loop manually assigns an order to the locations (North to South)
    if i==1 %Central
        subplot(length(fileList),1,2)
    elseif i==2 %Northern
        subplot(length(fileList),1,1)
    elseif i==3 %Southern
        subplot(length(fileList),1,3)
    end
    
    mean_chart = bar(yr_avg,'FaceColor',dev_blue);

%     max_chart=bar(yr_max,'FaceColor',dev_red);
%     hold on

    ylim([0 5]);
    axes = gca;
    axes.YColor = 'k';
    if i==1
        ylabel('Walker Value','Color','k');
    end

    %Add labels and format axis
    xticks(1:1:16); 
    xlim([0 16]);
    xticklabels({'2004','2005','2006','2007','2008'...
         ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});
    

    %%%Right Axis
    yyaxis right
    ylabel(newName);
    axes = gca;
    axes.YColor = 'k';
    axes.TickLength = [0 0];

    %Title on first graph only
    if i == 2 %place title above SF, which should be the first plot
        title('Grunion Greeters Annual Average Walker Value 2004-2018');
    end
end

% saveas(zz,'annual_mean_walker_regional.svg')
% export_fig test2.png