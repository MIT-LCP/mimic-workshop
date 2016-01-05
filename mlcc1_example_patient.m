%%  Plot data for an example patient

%% 1 - Initialize some plotting variables
% Some variables used to make pretty plots
col = [0.9047    0.1918    0.1988
    0.2941    0.5447    0.7494
    0.3718    0.7176    0.3612
    1.0000    0.5482    0.1000
    0.4550    0.4946    0.4722
    0.6859    0.4035    0.2412
    0.9718    0.5553    0.7741
    0.5313    0.3359    0.6523];

col = repmat(col,2,1);
col_fill = col;
col(9:end,:) = 0; % when plotting > 8 items, we make the outline black

marker = {'d','+','o','x','>','s','<','+','^'};
marker = repmat(marker,1,2);
ms = 12;
savefigflag=0;

%% 2 - SQLite instructions
% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimicdata.sqlite']);


% Note: Amazon RDS instructions - will be slower as it is the full database
% % STEP 1: Tell Matlab where the driver is
% javaclasspath('postgresql-9.4.1207.jre6.jar') % use this for Amazon
% 
% % STEP 2: Connect to the Database
% conn = database('MIMIC','testuser','mitmlcctu','Vendor','sqlite',...
%                 'Server','mimic3-1.coh8b3jmul4y.us-west-2.rds.amazonaws.com',...
%                 'PortNumber',5432);


%% 3 - Run the query to extract chartevents data
query = makeQuery('expt-query-1.sql');
data_ce = fetch(conn,query);

%% 4 - Plot patient vital signs
figure(1); clf; hold all;

lbl_plot = {'Non Invasive Blood Pressure mean',...
    'Heart Rate',...
    'O2 saturation pulseoxymetry',...
    'Respiratory Rate'};

% loop through the above list of labels
for k=1:numel(lbl_plot)
    % create an index for only the label we are interested in
    idxPlot = ismember(data_ce(:,6), lbl_plot{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_ce(idxPlot,5));
    time_plot = cell2mat(data_ce(idxPlot,2));
    
    % plot the data for this label
    plot(time_plot, data_plot, marker{k},...
        'Color', col(k,:), 'MarkerFaceColor', col_fill(k,:),...
        'markersize', ms, 'linewidth',2);
end

set(gca,'XLim',[0,24],'YLim',[0,150]);
set(gca,'YTick',0:25:150);

xlabel('Hours since ICU admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

% dummy figure to provide the legend
hleg=legend(lbl_plot,'Location','NorthEast');
set(gca,'FontSize',16);
grid on;

%% 5 - What else could you add to the above plot? Add labels to lbl_plot.

% here is a list of the available labels:
unique(data_ce(:,6))


%% 6 - Extract lab values
query = makeQuery('expt-query-2.sql');
data_le = fetch(conn,query);

%% 7 - Plot lab values
figure(1); clf; hold all;
marker = {'d','+','o','x','>','d','<','+','^'};
lbl_plot = {'CREATININE';
    'HEMOGLOBIN';
    'LACTATE'};

% plot the values
for k=1:numel(lbl_plot)
    
    % create an index for only the label we are interested in
    idxPlot = ismember(data_le(:,6), lbl_plot{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_le(idxPlot,5));
    time_plot = cell2mat(data_le(idxPlot,2));
    
    % plot the data for this label
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'Color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'markersize',ms,'linewidth',2);
end
legend(lbl_plot,'Location','NorthEast');
set(gca,'XLim',[0,24],'YLim',[0,25]);
grid on;

xlabel('Hours since ICU admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);


%% 8 - What else could you add to the above plot? Add labels to lbl_plot.

% here is a list of the available labels:
unique(data_le(:,6))

%% 9 - Extract output values
query = makeQuery('expt-query-3.sql');
data_oe = fetch(conn,query);

%% 10 - Plot the outputs
lbl_plot = {'Urine Output'};
for k=1:numel(lbl_plot)
    
    % create an index for only the label we are interested in
    idxPlot = ismember(data_oe(:,6), lbl_plot{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_oe(idxPlot,5));
    time_plot = cell2mat(data_oe(idxPlot,2));
    
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'linewidth',2,'markersize',ms);
end

legend(lbl_plot,'Location','NorthEast');
set(gca,'XLim',[0,24],'YLim',[0,200]);

xlabel('Hours since ICU admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

%% 11 - What else could you add to the above plot? Add labels to lbl_plot.

% here is a list of the available labels:
unique(data_ie(:,6))


%% 12 - Extract input values
query = makeQuery('expt-query-4.sql');
data_ie = fetch(conn,query);

%% 13 - Plot the inputs
lbl_plot = {};
for k=1:numel(lbl_plot)
    
    % create an index for only the label we are interested in
    idxPlot = ismember(data_ie(:,6), lbl_plot{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_ie(idxPlot,5));
    time_plot = cell2mat(data_ie(idxPlot,2));
    
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'linewidth',2,'markersize',ms);
end

legend(lbl_plot,'Location','NorthEast');
set(gca,'XLim',[0,24],'YLim',[0,200]);

xlabel('Hours since ICU admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);


%% 14 - What else could you add to the above plot? Add labels to lbl_plot.

% here is a list of the available labels:
unique(data_ie(:,6))


%% 15 - Bring it all together

lbl_ce = {};
lbl_le = {};
lbl_oe = {};
lbl_ie = {};

% Plot the chart values
for k=1:numel(lbl_ce)
    % create an index for only the label we are interested in
    idxPlot = ismember(data_ce(:,6), lbl_ce{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_ce(idxPlot,5));
    time_plot = cell2mat(data_ce(idxPlot,2));
    
    % plot the data for this label
    plot(time_plot, data_plot, marker{k},...
        'Color', col(k,:), 'MarkerFaceColor', col_fill(k,:),...
        'markersize', ms, 'linewidth',2);
end


% Plot the lab values
for k=1:numel(lbl_le)
    
    % create an index for only the label we are interested in
    idxPlot = ismember(data_le(:,6), lbl_le{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_le(idxPlot,5));
    time_plot = cell2mat(data_le(idxPlot,2));
    
    % plot the data for this label
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'Color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'markersize',ms,'linewidth',2);
end

% Plot the outputs
for k=1:numel(lbl_oe)
    
    % create an index for only the label we are interested in
    idxPlot = ismember(data_oe(:,6), lbl_oe{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_oe(idxPlot,5));
    time_plot = cell2mat(data_oe(idxPlot,2));
    
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'linewidth',2,'markersize',ms);
end

% Plot the inputs
for k=1:numel(lbl_ie)
    % create an index for only the label we are interested in
    idxPlot = ismember(data_ie(:,6), lbl_ie{k});
    
    % the 2nd column is the time, and the 5th column is VALUENUM, the numeric value
    data_plot = cell2mat(data_ie(idxPlot,5));
    time_plot = cell2mat(data_ie(idxPlot,2));
    
    plot(time_plot, data_plot,...
        'LineStyle','--','Marker',marker{k},...
        'color',col(k,:), 'markerfacecolor',col_fill(k,:),...
        'linewidth',2,'markersize',ms);
end



legend([lbl_ce, lbl_le, lbl_oe, lbl_ie],'Location','Best');
xlabel('Hours since ICU admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

