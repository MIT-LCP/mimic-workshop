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

%% Now, check that we have access to the LIBSVM toolbox
svm_path = which('svmtrain');

fprintf('\n');
if strfind(lower(svm_path),'.mex') > 0
    fprintf('The path for svmtrain is: %s\n',svm_path);
    fprintf('libsvm is loaded properly! Carry on!\n');
else
    fprintf('Could not find LIBSVM. Make sure it''s added to the path.\n');
end

%% Run the following to connect to the database

% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimiciii_v1_3_demo.sqlite']);

%% Option 1. Extract the patient data using the query from your assignment
% At the moment this query is long, and takes ~5 minutes
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

% %% (Optional) This loads fisher iris instead of the ICU data
% load fisheriris;
% X = meas(:,1:3);
% X_header = {'Sepal length','Sepal width','Petal length'};
% y = double(strcmp(species,'virginica')==1);
% clear meas species;

%% First, let's choose the data we'd like to work with

[idxData,idxOrder] = ismember(header,{'HeartRateMin','MeanBPMin','Age'});

X = data(:,idxData);
X_header = header(idxData);

y = double(data(:,2)==1);

%% Before we train a model - let's inspect the data
idxTarget = y == 1; % note: '=' defines a number, '==' compares two variables

figure(1); clf; hold all;
plot3(X(idxTarget,1),X(idxTarget,2),X(idxTarget,3),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:)...
    ,'MarkerSize',10,'LineWidth',2);
plot3(X(~idxTarget,1),X(~idxTarget,2),X(~idxTarget,3),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:)...
    ,'MarkerSize',10,'LineWidth',2);
grid on;

xlabel(X_header{1},'FontSize',16);
ylabel(X_header{2},'FontSize',16);
zlabel(X_header{3},'FontSize',16);
legend({'Died in hospital','Survived'},'FontSize',14);
set(gca,'view',[45 25]); % a nice isometric view

clear tmp; % delete the 'tmp' variable now that we don't need it


% 1) What do you note that is unusual?
%   ages are 300
%   ages are 0
%   heart rates are 0 - usually people die with a heart rate of 0 (quelle surprise!)


%% Pre-process the data!
% "Center" the data
mu = nanmean(X, 1);
sigma = nanstd(X, [], 1);

X = bsxfun(@minus, X, mu);
X = bsxfun(@rdivide, X, sigma);


% Impute values for the mean

% Why do we impute 0?
% Because we've set the mean to (practically) 0! Check yourself:
nanmean(X) % note "1.0e-14" implies 14 zeros before the number
X(isnan(X)) = 0;

% For the purpose of plotting, it can be helpful to keep the original units
X_orig = bsxfun(@times, X, sigma);
X_orig = bsxfun(@plus, X_orig, mu);
% note that we X_orig is identical to the original data, *except* it has
% missing values imputed

%% Using LIBSVM, train an SVM classifier with a linear kernel
model = svmtrain(y, X, '-t 0');
% Atypically, LIBSVM receives options as a single string in the fourth input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'

% Apply the classifier to the data set
[pred,acc,prob] = svmpredict(y, X, model);

%% Evaluate the model
% Plot a confusion matrix of the model's performance
confusionmat(y,pred)

%% Plot the linear SVM hyperplane
figure(1); clf; hold all;
plot3(X_orig(idxTarget,1),X_orig(idxTarget,2),X_orig(idxTarget,3),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:)...
    ,'MarkerSize',10,'LineWidth',2);
plot3(X_orig(~idxTarget,1),X_orig(~idxTarget,2),X_orig(~idxTarget,3),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:)...
    ,'MarkerSize',10,'LineWidth',2);
grid on;

%=== generate the normal vector of the plane from the SVs
w = model.SVs' * model.sv_coef;
b = model.rho;

 % use equation of a plane to create the separating hyperplane
xi = -3:0.25:3;
yi = -3:0.25:0;
[XX,YY] = meshgrid(xi,yi);
ZZ=(b - w(1) * XX - w(2) * YY)/w(3);

% convert the coordinates to original units
XX = XX*sigma(1) + mu(1);
YY = YY*sigma(2) + mu(2);
ZZ = ZZ*sigma(3) + mu(3);

% add the hyperplane to the plot using "mesh"
mesh(XX,YY,ZZ,'EdgeColor',col(5,:),'FaceColor','none');
set(gca,'view',[-127    10]);

legend({'Died in hospital','Survived'},'FontSize',16);
xlabel(X_header{1},'FontSize',16);
ylabel(X_header{2},'FontSize',16);
zlabel(X_header{3},'FontSize',16);


%% Now let's try it with corrected ages
X = data(:,idxData);
X_header = header(idxData);
y = double(data(:,2)==1);

% find which column has the 'Age' variable
idxAge = strcmp(X_header,'Age');

% find which data elements have been anonymized
idxFix = X(:,idxAge) > 89;

% imput the median age for these older patients
X(idxFix,idxAge) = 91.4;

% preprocess the data
mu = nanmean(X, 1);
sigma = nanstd(X, [], 1);
X = bsxfun(@minus, X, mu);
X = bsxfun(@rdivide, X, sigma);
X(isnan(X)) = 0;

% train the model
model_fix = svmtrain(y, X, '-t 0');

% Apply the classifier to the data set
[pred,acc,prob] = svmpredict(y, X, model_fix);

X_orig = bsxfun(@times, X, sigma);
X_orig = bsxfun(@plus, X_orig, mu);

% plot the model and the data
figure(1); clf; hold all;
idxTarget = y == 1; % note: '=' defines a number, '==' compares two variables

plot3(X_orig(idxTarget,1),X_orig(idxTarget,2),X_orig(idxTarget,3),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:),...
    'MarkerSize',10,'LineWidth',2);
plot3(X_orig(~idxTarget,1),X_orig(~idxTarget,2),X_orig(~idxTarget,3),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:),...
    'MarkerSize',10,'LineWidth',2);
plot3(X_orig(pred==1,1),X_orig(pred==1,2),X_orig(pred==1,3),...
    'Linestyle','none','Marker','o',...
    'MarkerFaceColor','none','MarkerEdgeColor',col(1,:),...
    'MarkerSize',10,'LineWidth',2,...
    'HandleVisibility','off');
grid on;

xi = -3:0.25:3;
yi = -3:0.25:0;


% plot the new hyperplane
w = model_fix.SVs' * model_fix.sv_coef;
b = model_fix.rho;
[XX,YY] = meshgrid(xi,yi);
ZZ=(b - w(1) * XX - w(2) * YY)/w(3);
XX = XX*sigma(1) + mu(1);
YY = YY*sigma(2) + mu(2);
ZZ = ZZ*sigma(3) + mu(3);
mesh(XX,YY,ZZ,'EdgeColor',col(6,:),'FaceColor','none');

% add in the older hyperplane with the older color
w = model.SVs' * model.sv_coef;
b = model.rho;
[XX,YY] = meshgrid(xi,yi);
ZZ=(b - w(1) * XX - w(2) * YY)/w(3);
XX = XX*sigma(1) + mu(1);
YY = YY*sigma(2) + mu(2);
ZZ = ZZ*sigma(3) + mu(3);
mesh(XX,YY,ZZ,'EdgeColor',col(5,:),'FaceColor','none');

legend({'Died in hospital','Survived'},'FontSize',16);
xlabel(X_header{1},'FontSize',16);
ylabel(X_header{2},'FontSize',16);
zlabel(X_header{3},'FontSize',16);
set(gca,'view',[-127    10]);
% 
% %% Ignore the other axis and *just* look at age
% figure(2); clf; hold all;
% idxTarget = y == 1; % note: '=' defines a number, '==' compares two variables
% 
% plot(X_orig(idxTarget,1),X_orig(idxTarget,2),...
%     'Linestyle','none','Marker','x',...
%     'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:)...
%     ,'MarkerSize',10,'LineWidth',2);
% plot(X_orig(~idxTarget,1),X_orig(~idxTarget,2),...
%     'Linestyle','none','Marker','+',...
%     'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:)...
%     ,'MarkerSize',10,'LineWidth',2);
% plot(X_orig(pred==1,1),X_orig(pred==1,2),...
%     'Linestyle','none','Marker','o',...
%     'MarkerFaceColor','none','MarkerEdgeColor',col(1,:),...
%     'MarkerSize',10,'LineWidth',2,...
%     'HandleVisibility','off');
% grid on;
% 
% % plot a slice of the new hyperplane
% w = model_fix.SVs' * model_fix.sv_coef;
% b = model_fix.rho;
% X = xi;
% 
% YY = (b - w(1) * XX - w(3) * ( (0-mu(3))/sigma(3) ) ) / w(2);
% XX = XX*sigma(1) + mu(1);
% YY = YY*sigma(2) + mu(2);
% plot(XX,YY,'-','Color',col(6,:),'LineWidth',3);
% 
% % add in the older hyperplane with the older color
% w = model.SVs' * model.sv_coef;
% b = model.rho;
% XX = xi;
% YY = (b - w(1) * XX - w(3) * ( (0-mu(3))/sigma(3) )) / w(2);
% XX = XX*sigma(1) + mu(1);
% YY = YY*sigma(2) + mu(2);
% plot(XX,YY,'-','Color',col(5,:),'LineWidth',3);
% % set(gca,'view',[-127    10]);
% 
% legend({'Died in hospital','Survived'},'FontSize',16);
% xlabel(X_header{1},'FontSize',16);
% ylabel(X_header{2},'FontSize',16);
% zlabel(X_header{3},'FontSize',16);

%% Now let's try with an RBF kernel
% This is LIBSVM's most flexible kernel

X = data(:,idxData);
X_header = header(idxData);
y = double(data(:,2)==1);

% find which column has the 'Age' variable
idxAge = strcmp(X_header,'Age');

% find which data elements have been anonymized
idxFix = X(:,idxAge) > 89;

% imput the median age for these older patients
X(idxFix,idxAge) = 91.4;

% preprocess the data
mu = nanmean(X, 1);
sigma = nanstd(X, [], 1);
X = bsxfun(@minus, X, mu);
X = bsxfun(@rdivide, X, sigma);
X(isnan(X)) = 0;

% train the model
model_rbf = svmtrain(y, X, '-t 2');

% Apply the classifier to the data set
[pred,acc,prob] = svmpredict(y, X, model_rbf);

X_orig = bsxfun(@times, X, sigma);
X_orig = bsxfun(@plus, X_orig, mu);

% plot the model and the data
figure(1); clf; hold all;
idxTarget = y == 1; % note: '=' defines a number, '==' compares two variables

plot3(X_orig(idxTarget,1),X_orig(idxTarget,2),X_orig(idxTarget,3),...
    'Linestyle','none','Marker','x',...
    'MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:),...
    'MarkerSize',10,'LineWidth',2);
plot3(X_orig(~idxTarget,1),X_orig(~idxTarget,2),X_orig(~idxTarget,3),...
    'Linestyle','none','Marker','+',...
    'MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:),...
    'MarkerSize',10,'LineWidth',2);
plot3(X_orig(pred==1,1),X_orig(pred==1,2),X_orig(pred==1,3),...
    'Linestyle','none','Marker','o',...
    'MarkerFaceColor','none','MarkerEdgeColor',col(1,:),...
    'MarkerSize',10,'LineWidth',2,...
    'HandleVisibility','off');
grid on;

% reapply the SVM to a grid of all possible values
xi=-5:0.25:5;
yi=-5:0.25:5;
zi=-5:0.25:5;
[XX,YY,ZZ] = meshgrid(xi,yi,zi);
tmpdat = [XX(:),YY(:),ZZ(:)];

[pred,acc,VV] = svmpredict(zeros(size(tmpdat,1),1), tmpdat, model_rbf, '-q');
VV = reshape(VV,length(yi),length(xi),length(zi));
XX = XX*sigma(1) + mu(1);
YY = YY*sigma(2) + mu(2);
ZZ = ZZ*sigma(3) + mu(3);

% plot the new hyperplane
h3=patch(isosurface(X,YY,ZZ,VV,0)); 
set(h3,'facecolor','none','edgecolor',col(5,:));

% plot the old hyperplane
w = model_fix.SVs' * model_fix.sv_coef;
b = model_fix.rho;
xi = -3:0.25:3;
yi = -3:0.25:0;
[XX,YY] = meshgrid(xi,yi);
ZZ=(b - w(1) * XX - w(2) * YY)/w(3);
XX = XX*sigma(1) + mu(1);
YY = YY*sigma(2) + mu(2);
ZZ = ZZ*sigma(3) + mu(3);
mesh(XX,YY,ZZ,'EdgeColor',col(6,:),'FaceColor','none');

% standard info for the plot
legend({'Died in hospital','Survived'},'FontSize',16);
xlabel(X_header{1},'FontSize',16);
ylabel(X_header{2},'FontSize',16);
zlabel(X_header{3},'FontSize',16);
set(gca,'view',[-127    10]);