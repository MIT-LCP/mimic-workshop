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

%% Load the data

%% (Option 1) If you finished the assignment, load your data here

% STEP 1: Tell Matlab where the driver is
javaclasspath('sqlite-jdbc-3.8.11.2.jar') % use this for SQLite

% STEP 2: Connect to the Database
conn = database('','','',...
    'org.sqlite.JDBC',['jdbc:sqlite:' pwd filesep 'data' filesep 'mimiciii_v1_3_demo.sqlite']);


%% (Option 2) Load the data from the .mat file provided

% Loads in 'X', 'X_header', and 'y' variables
load('MLCCData.mat'); 

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

% 1) What do you see that is notable?


%% Correct the erroneous ages
% Hint: the median age of patients > 89 is 91.6.


%% Normalize the data!
% First get the column wise mean and the column wise standard deviation
mu = nanmean(X, 1);
sigma = nanstd(X, [], 1);

% Now subtract each element of mu from each column of X
X = bsxfun(@minus, X, mu);
X = bsxfun(@rdivide, X, sigma);


% Missing data:
% Our data has missing values. How should we pre-process these?

%% We will be using libsvm. If you call svmtrain on its own, it lists the options
svmtrain;

%% Using LIBSVM, train an SVM classifier with a linear kernel
model = svmtrain(y, X, '-t 0');
% Atypically, LIBSVM receives options as a single string in the fourth input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'

% Apply the classifier to the data set
pred = svmpredict(y, X, model);

%% Evaluate the model - plot a confusion matrix
figure(1); % this tells MATLAB to plot in figure 1
clf; % this clears any information currently on the figure


%% Now let's try with an RBF kernel
% This is LIBSVM's most flexible kernel
% We specify it as '-t 2'

% train the model
model_rbf = svmtrain(y, X, '-t 2');

% Apply the classifier to the data set
pred = svmpredict(y, X, model_rbf);

%% Evaluate the RBF model - plot a confusion matrix
% How does it compare to the linear model?
figure(2); % this tells MATLAB to plot in figure 2
clf; % this clears any information currently on the figure

confmat(pred,y)
%% Specify parameters in the RBF kernel
% The RBF kernel has some parameters of its own: gamma and capacity
% Let's set these to a different value then their defaults

gamma = 2;
capacity = -1;

% train the model
model_rbf = svmtrain(y, X, ['-t 2 -c ' num2str(2^(capacity)) ' -g ' num2str(2^(gamma))]);
pred = svmpredict(y, X, model_rbf);

%% Evaluate the RBF model with custom parameters
% How much better did our classifier do?
% Apply the classifier to the data set


%% Optimize the RBF kernel
% Let's see how much better we can make our model!
% change gamma and capacity below to try and improve your performance
% Keep them as integers, 

gamma = ?;
capacity = ?;

% train the model
model_rbf = svmtrain(y, X, ['-t 2 -c ' num2str(2^(capacity)) ' -g ' num2str(2^(gamma))]);
pred = svmpredict(y, X, model_rbf);


% evaluate the model