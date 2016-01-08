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

%% Run the following to connect to the database

% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimiciii_v1_3_demo.sqlite']);

%% Option 1. Extract the patient data using the query from your assignment
setdbprefs('DataReturnFormat','dataset')
query = makeQuery('mlcc1-problem-set-solutions.sql');
data = fetch(conn,query);

% now convert data to a cell array
data = dataset2cell(data);

% we can get the column names from the first row of the 'data' variable
header = data(1,:);
header{2} = 'OUTCOME';
header = regexprep(header,'_',''); % remove underscores
data = data(2:end,:);

% MATLAB sometimes reads 'null' instead of NaN
data(cellfun(@isstr, data) & cellfun(@(x) strcmp(x,'null'), data)) = {NaN};

% MATLAB sometimes has blank cells which should be NaN
data(cellfun(@isempty, data)) = {NaN};

% Convert the data into a matrix of numbers
% This is a MATLAB data type thing - we can't do math with cell arrays
data = cell2mat(data);

%%
% Data will have at least three columns: 
%   ICUSTAY_ID, OUTCOME, AGE

fprintf('%12s\t',header{:});
fprintf('\n');
for n=1:5
    for m=1:size(data,2)
        fprintf('%12g\t',data(n,m));
    end
    fprintf('\n');
end

%% Option 2. Load fisher iris
load fisheriris;
data = [(1:size(meas,1))',double(strcmp(species,'virginica')==1),meas(:,1:3)];
header = {'id','virginica','Sepal length','Sepal width','Petal length'};
clear meas species;
%% Plot the data
idxTarget = data(:,2) == 1;

figure(1); clf; hold all;
plot3(data(idxTarget,3),data(idxTarget,4),data(idxTarget,5),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:)...
    ,'MarkerSize',10,'LineWidth',2);
plot3(data(~idxTarget,3),data(~idxTarget,4),data(~idxTarget,5),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:)...
    ,'MarkerSize',10,'LineWidth',2);
grid on;

xlabel(header{3},'FontSize',16);
ylabel(header{4},'FontSize',16);
zlabel(header{5},'FontSize',16);
legend({'Positive targets','Negative targets'},'FontSize',14);
set(gca,'view',[45 25]); % a nice isometric view


%% Using LIBSVM, train an SVM classifier with a linear kernel
model = svmtrain(double(idxTarget), data(:,3:5), '-t 0');
% Atypically, LIBSVM receives options as a single string in the fourth input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'

% Apply the classifier to the test set, and evaluate the performance in 
% terms of mean square error AND accuracy.
[pred,acc,prob] = svmpredict(double(idxTarget), data(:,3:5), model);


%% Plot the linear SVM hyperplane
figure(1); clf; hold all;
plot3(data(idxTarget,3),data(idxTarget,4),data(idxTarget,5),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:)...
    ,'MarkerSize',10,'LineWidth',2);
plot3(data(~idxTarget,3),data(~idxTarget,4),data(~idxTarget,5),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:)...
    ,'MarkerSize',10,'LineWidth',2);
grid on;

%=== generate the normal vector of the plane from the SVs
w = model.SVs' * model.sv_coef;
b = model.rho;

 % use equation of a plane to create the separating hyperplane
x=-10:1:10;
[X,Y] = meshgrid(x);
Z=(b - w(1) * X - w(2) * Y)/w(3);
mesh(X,Y,Z,'EdgeColor',col(5,:),'FaceColor','none');
set(gca,'view',[-127    10]);

xlabel(header{3},'FontSize',16);
ylabel(header{4},'FontSize',16);
zlabel(header{5},'FontSize',16);


%%