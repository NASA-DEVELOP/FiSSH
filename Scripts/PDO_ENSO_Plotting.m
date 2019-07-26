%% Plot PDO index
%Clear GUI
clc
clear
%load the PDO data into a cell 
cd('C:\Users\peacock\Desktop\Develop\index');

dev_blue = [52/255 156/255 196/255];
dev_red = [192/255 74/255 74/255];

%load data in cell 
D = readtable('PDO_index.csv');
PDO_data = table2cell(D);

%create variables
date = D.date;
value = D.value;

%create plot
subplot(2,1,1)

%plot red bars for a positive values and blue bars for negative values
neg=value;
neg(neg>0)=nan;
pos=value;
pos(pos<0)=nan;

neg_chart = bar(neg);
neg_chart.FaceColor=dev_blue;
hold on
pos_chart=bar(pos);
pos_chart.FaceColor=dev_red;

hold on
%plot dotted lines between years
for i= 12.5:12:365
    x = line([i i],[-3.5 3.5]);
    set(x,'LineStyle',':');
end

%Format axes and set tick marks
xticks(6.5:12:365);
yticks(-3:1:3)
axis([0.5 190 -3.5 3.5]);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});

%Add labels to axes
ylabel('PDO');
yticklabels({'-3','-2','-1','0','1','2','3'});
xticklabels({'2003','2004','2005','2006','2007','2008'...
    ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});

saveas(gcf, 'test.png');
export_fig test2.png
%% Plot ENSO index
%load the ENSO data into a cell 
cd('C:\Users\peacock\Desktop\Develop\index');

%Set colors
D = readtable('enso_nino3.4_index.csv');
ENSO_data = table2cell(D);

%create variables
date = D.date;
%value = D.Value;
value = D.anom;
%create plot
subplot(2,1,2)

%plot red bars for a positive values and blue bars for negative values
neg=value;
neg(neg>0)=nan;
pos=value;
pos(pos<0)=nan;

neg_chart = bar(neg);
neg_chart.FaceColor=dev_blue;
hold on
pos_chart=bar(pos);
pos_chart.FaceColor=dev_red;

hold on
%plot dotted lines between years 
for i= 12.5:12:365
    x = line([i i],[-3.5 3.5]);
    set(x,'LineStyle',':');
end

%Format axis and add tick marks
xticks(6.5:12:365);
yticks(-3:1:3)
axis([0.5 190 -3.5 3.5]);
set(gca,'xticklabel',{[]});
set(gca,'yticklabel',{[]});

%Add axis labels
ylabel('ENSO');
yticklabels({'-3','-2','-1','0','1','2','3'});
xticklabels({'2003','2004','2005','2006','2007','2008'...
    ,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018'});