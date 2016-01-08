%=== BEFORE STARTING THE LAB ===%
% Download PhysionetChallenge2012.mat from this URL:
% www.robots.ox.ac.uk/~davidc/teaching.php
% and place it in your path in Matlab
% (At the bottom of the link, click 'Physionet')

%============ IMPORTANT ============%
% Please download LIBSVM package from:
% http://www.csie.ntu.edu.tw/~cjlin/libsvm/#download
% Under "Download LIBSVM", click on the zip file link
% Extract the zip file into your MATLAB path
%========= STILL IMPORTANT =========%
% The files you need are in a SUBDIRECTORY: libsvm-3.20/windows/
% MAKE SURE YOU ADD THE SUBDIRECTORY !!!

% Load the sample data
load fisheriris

% The data is Fisher's iris data
% 4 measurements on a sample of 150 irises

% The three types of irises (flowers)
species_type={'setosa','versicolor','virginica'};

% Exercise 1 - Create a target vector for all flowers that match virginica.
% This should have 1s for virginica, and 0s otherwise.
target = double(strcmp(species,'virginica'));

% Exercise 2 - Use the following generated indices (Thanks Alistair!) to
% split your data into training and test sets.
idxTrain = [true(30,1);
    false(20,1); % setosa
    true(30,1);
    false(20,1); % versicolor
    true(30,1);
    false(20,1)]; % virginica

idxTest = ~idxTrain;

% MATLAB Fu note: these are logical indices. They work similarly to
% numerical indices. In a logical index, there is one flag per row in your
% matrix, and this flag says "include me" (if it's 1) or "exclude me"
% (if it's 0). Above, we have idxTrain being a 150x1 logical vector. So we
% can say "only give me rows where idxTrain == 1" by:
%   train_data = meas(idxTrain,:);


train_data = meas(idxTrain,:); 
train_target = double(strcmp(species(idxTrain,:),'virginica'));

test_data = meas(idxTest,:); 
test_target = double(strcmp(species(idxTest,:),'virginica')); 


% Exercise 3 - Let's only look at petal width/height for now.
% Only use the first and second columns of your training and testing data
%   e.g. train_data = train_data(:,1:2); 
% Don't forget about the test data :)
train_data = train_data(:,1:2);
test_data = test_data(:,1:2);

% Exercise 4 - Using LIBSVM, train an SVM classifier.
% Typing the command:
%       svmtrain
% Into MATLAB will give you help in training the SVM.
% The command format is:
%   model = svmtrain(TRAINING_TARGET, TRAINING_DATA, LIBSVM_OPTIONS);
% Atypically, LIBSVM receives options as a single string in the third input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'
%       ... sets the 'v' option to 1, the 'b' option to 1, and so on..
% To save you some effort, here are the default options for a linear SVM:
libsvm_options = '-t 0';


model = svmtrain(train_target, train_data, libsvm_options);

% Exercise 4
% Apply the classifier to the test set, and evaluate the performance in 
% terms of mean square error AND accuracy.
% Similarly, type 'svmpredict' into the command window to get help on it.

[pred,acc,prob] = svmpredict(test_target, test_data, model);
pred_linear = pred;


%=== some visualisation ...
col = [0.363921568627451,0.575529411764706,0.748392156862745;0.915294117647059,0.281568627450980,0.287843137254902;0.441568627450980,0.749019607843137,0.432156862745098;1,0.598431372549020,0.200000000000000;0.676862745098039,0.444705882352941,0.711372549019608];

figure(1); clf; hold all;
plot(test_data(test_target==0 & pred==0,1),test_data(test_target==0 & pred==0,2),'Linestyle','none','Color',col(1,:),'Marker','d','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==0 & pred==1,1),test_data(test_target==0 & pred==1,2),'Linestyle','none','Color',col(1,:),'Marker','x','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==1 & pred==1,1),test_data(test_target==1 & pred==1,2),'Linestyle','none','Color',col(2,:),'Marker','d','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==1 & pred==0,1),test_data(test_target==1 & pred==0,2),'Linestyle','none','Color',col(2,:),'Marker','x','MarkerSize',12,'LineWidth',3);
% plot(test_data(test_target==0,1),test_data(test_target==0,2),'Linestyle','none','Color',col(1,:),'Marker','o','MarkerSize',12,'LineWidth',3);
% plot(test_data(test_target==1,1),test_data(test_target==1,2),'Linestyle','none','Color',col(2,:),'Marker','+','MarkerSize',12,'LineWidth',3);
grid on;
xlabel('Petal Width (Column 1)','FontSize',14); ylabel('Petal Length (Column 2)','FontSize',14);

%=== generate corners of the separating hyperplane (a line)
w = model.SVs' * model.sv_coef;
b = model.rho;
X=6.3:0.1:6.6;
Z=(b - w(1) * X )/w(2);
plot(X,Z,'k-','linewidth',3);
%=== -1 and +1 sides
X=7:0.1:7.3;
Z=(b - w(1) * X - 1)/w(2);
plot(X,Z,'k:','linewidth',3);
X=5.6:0.1:5.9;
Z=(b - w(1) * X + 1)/w(2);
plot(X,Z,'k:','linewidth',3);

%=== overlay support vectors
sv = full(model.SVs);
plot(sv(:,1),sv(:,2),'LineStyle','none','color',col(3,:),'marker','o','linewidth',2,'markerfacecolor',col(3,:));

% %% visualize this for 3 dimensions
% col = linspecer(5);
% figure(1); clf; hold all;
% plot3(train_data(train_target==0,1),train_data(train_target==0,2),train_data(train_target==0,3),'Linestyle','none','Color',col(1,:),'Marker','o','LineWidth',3);
% plot3(train_data(train_target==1,1),train_data(train_target==1,2),train_data(train_target==1,3),'Linestyle','none','Color',col(1,:),'Marker','+','LineWidth',3);
% plot3(test_data(test_target==0,1),test_data(test_target==0,2),test_data(test_target==0,3),'Linestyle','none','Color',col(2,:),'Marker','o','LineWidth',3);
% plot3(test_data(test_target==1,1),test_data(test_target==1,2),test_data(test_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','+','LineWidth',3);
% grid on;
% 
% %=== generate corners of the plane
% w = model.SVs' * model.sv_coef;
% b = model.rho;
% 
% % if model.Label(1) == 0
% %   w = -w;
% %   b = -b;
% % end
% 
% %%
% x=-10:0.1:10;
% [X,Y] = meshgrid(x);
% Z=(b - w(1) * X - w(2) * Y)/w(3);
% surf(X,Y,Z,'edgecolor','none')

%%
% Exercise 5
% Now train an SVM classifier with an RBF kernel using only the training
% set. Evaluate it on the test set in terms of accuracy.
% Note: there are two parameters for the RBF kernel - gamma and capacity.
% You should read about these in the help! Start with their default values.

model = svmtrain(train_target, train_data, '-t 2 -g 15 -c 15');
[pred,acc,prob] = svmpredict(test_target, test_data, model);
pred_rbf = pred;

%=== clever plot
figure(1); clf; hold all;
plot(test_data(test_target==0 & pred==0,1),test_data(test_target==0 & pred==0,2),'Linestyle','none','Color',col(5,:),'Marker','d','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==0 & pred==1,1),test_data(test_target==0 & pred==1,2),'Linestyle','none','Color',col(5,:),'Marker','x','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==1 & pred==1,1),test_data(test_target==1 & pred==1,2),'Linestyle','none','Color',col(1,:),'Marker','d','MarkerSize',12,'LineWidth',3);
plot(test_data(test_target==1 & pred==0,1),test_data(test_target==1 & pred==0,2),'Linestyle','none','Color',col(1,:),'Marker','x','MarkerSize',12,'LineWidth',3);
% plot(test_data(test_target==0,1),test_data(test_target==0,2),'Linestyle','none','Color',col(1,:),'Marker','o','MarkerSize',12,'LineWidth',3);
% plot(test_data(test_target==1,1),test_data(test_target==1,2),'Linestyle','none','Color',col(2,:),'Marker','+','MarkerSize',12,'LineWidth',3);
grid on;
xlabel('Petal Width (Column 1)','FontSize',14); ylabel('Petal Length (Column 2)','FontSize',14);

x=4:0.01:8; y = 2:0.01:4;
[X,Y] = meshgrid(x,y);
tmpdat = [X(:),Y(:)];
[~,~,boundary] = svmpredict(zeros(numel(X),1), tmpdat, model, '-q');
boundary = reshape(boundary,length(y),length(x));
contour(X,Y,boundary,-1:1:1);
colormap(col);

% %% in 3 dimensions
% x=4:0.1:8; y = 2:0.1:4; z = 1:0.1:7;
% [X,Y,Z] = meshgrid(x,y,z);
% tmpdat = [X(:),Y(:),Z(:)];
% [~,~,prob] = svmpredict(zeros(numel(X),1), tmpdat, model);
% prob = reshape(prob,length(y),length(x),length(z));
% col = linspecer(5);
% 
% figure(2); clf; hold all;
% plot3(train_data(train_target==0,1),train_data(train_target==0,2),train_data(train_target==0,3),'Linestyle','none','Color',col(1,:),'Marker','o','LineWidth',3);
% plot3(train_data(train_target==1,1),train_data(train_target==1,2),train_data(train_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','o','LineWidth',3);
% plot3(test_data(test_target==0,1),test_data(test_target==0,2),test_data(test_target==0,3),'Linestyle','none','Color',col(1,:),'Marker','+','LineWidth',3);
% plot3(test_data(test_target==1,1),test_data(test_target==1,2),test_data(test_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','+','LineWidth',3);
% xlabel(curr_header{1}); ylabel(curr_header{2}); zlabel(curr_header{3});
% grid on;
% h=patch(isosurface(X,Y,Z,prob,-0.5)); set(h,'facecolor','none','edgecolor',col(3,:));
% h=patch(isosurface(X,Y,Z,prob,0.5)); set(h,'facecolor','none','edgecolor',col(4,:));
% h=patch(isosurface(X,Y,Z,prob,0)); set(h,'facecolor','none','edgecolor',col(5,:));
% set(gca,'view',[-39,16]);

%%
% Exercise 6
% Compare the accuracy in exercise 5 and exercise 3.
% Note: the 2nd output of 'svmpredict' is accuracy.
fprintf('Performance of linear SVM: \t%2.2f%%.\n',mean(pred_linear == test_target)*100);
fprintf('Performance of RBF SVM: \t%2.2f%%.\n',mean(pred_rbf == test_target)*100);

% Exercise 7
% Did you normalise your data?
% Chances are you didn't! Let's test if it could make a difference.
% Multiple the 2nd column of your data by 100. 

train_data = meas(idxTrain,1:2);
test_data = meas(idxTest,1:2);

train_data(:,2) = train_data(:,2)*100;
test_data(:,2) = test_data(:,2)*100;

% Execise 8
% Training a linear SVM with the new 'poorly' normalised data
% (i.e., repeat exercise 3).
model = svmtrain(train_target, train_data, '-t 0');
[pred,acc,prob] = svmpredict(test_target, test_data, model);
pred_linear_norm = pred;


% Exercise 9
% Training an RBF SVM with the new 'poorly' normalised data
%  (i.e., repeat exercise 5).
model = svmtrain(train_target, train_data, '-t 2 -g 15 -c 15');
[pred,acc,prob] = svmpredict(test_target, test_data, model);
pred_rbf_norm = pred;


% Exercise 10
% Comment on your results in exercises 8 and 9.
% Did the larger scale of the second column in any way affect your model
% for the linear SVM? And for the RBF SVM?
fprintf('Performance of linear SVM: \t%2.2f%%, changes to %2.2f%% with normalisation.\n',...
    mean(pred_linear == test_target)*100,mean(pred_linear_norm == test_target)*100);
fprintf('Performance of RBF SVM: \t%2.2f%%, changes to %2.2f%% with normalisation.\n',...
    mean(pred_rbf == test_target)*100,mean(pred_rbf_norm == test_target)*100);

%%
% Exercise 11
% Load in the Physionet Challenge data and subselect the following features
load PhysionetChallenge2012;
idxFeatures = [63,64,65,70,72,88,90,131,133,168,170,174,176];
idxFeatures = idxFeatures([3,7,13]);
rng(777,'twister');

% X = X(:,idxFeatures);
% header = header(idxFeatures);

% NOTE: We should actually do this with idxFeatures
% But since everyone's answer will vary, based on parameters, we do this
% with SAPS-I and SOFA
X = [X_other(:,2:3),X(:,65)];
curr_header = [header_other(2:3),'GCS'];

% Exercise 12
% Split the data into training and test sets, using 20% of the data for
% the test set.
idxTrain = rand(size(X,1),1) > 0.5;
train_data = X(idxTrain,:); train_target = double(y(idxTrain,:));
test_data = X(~idxTrain,:); test_target = double(y(~idxTrain,:));

mu = nanmean(train_data); sigma = nanstd(train_data);
train_data = bsxfun(@minus, train_data, mu);
train_data = bsxfun(@rdivide, train_data, sigma);
train_data(isnan(train_data)) = 0;
test_data = bsxfun(@minus, test_data, mu);
test_data = bsxfun(@rdivide, test_data, sigma);
test_data(isnan(test_data)) = 0;

% Exercise 13
% Train an SVM using the training data, and evaluate it's performance using
% the test set.


%% LINEAR SVM
model = svmtrain(train_target, train_data, '-w0 1 -w1 5 -t 0 -c 1 -q');
[pred,acc,prob] = svmpredict(test_target, test_data, model,'-q');
[~,~,~,cstat] = perfcurve(test_target,prob,0);
fprintf('Linear SVM, AUROC = %2.2f\n',cstat);

%=== visualize this
col = linspecer(5);
figure(1); clf; hold all;

idxSubsample = rand(size(train_target,1),1) < mean(y) & train_target==0;
% X(idxSubsample > mean(y) & y == 0,:) = [];
% y(idxSubsample > mean(y) & y == 0,:) = [];

plot3(train_data(idxSubsample,1),train_data(idxSubsample,2),train_data(idxSubsample,3),'Linestyle','none','Color',col(1,:),'Marker','o','LineWidth',3);
plot3(train_data(train_target==1,1),train_data(train_target==1,2),train_data(train_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','o','LineWidth',3);


idxSubsample = rand(size(test_target,1),1) > mean(y) & test_target==0;
plot3(test_data(idxSubsample,1),test_data(idxSubsample,2),test_data(idxSubsample,3),'Linestyle','none','Color',col(1,:),'Marker','+','LineWidth',3);
plot3(test_data(test_target==1,1),test_data(test_target==1,2),test_data(test_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','+','LineWidth',3);
xlabel(curr_header{1}); ylabel(curr_header{2}); zlabel(curr_header{3});
grid on;

%=== generate corners of the plane
w = model.SVs' * model.sv_coef;
b = model.rho;
% pause;
x=-3:0.1:3; y = -3:0.1:3;
[X,Y] = meshgrid(x,y);
Z=(b - w(1) * X - w(2) * Y)/w(3);
surf(X,Y,Z,'edgecolor','none')
colormap(jet(128));
set(gca,'XTick',-3:1:3, 'XTickLabel', arrayfun(@(x) num2str(x,'%3.1f'), (-3:1:3)*sigma(1)+mu(1), 'UniformOutput', false));
set(gca,'XTick',-3:1:3, 'XTickLabel', arrayfun(@(x) num2str(x,'%3.1f'), (-3:1:3)*sigma(2)+mu(2), 'UniformOutput', false));
set(gca,'XTick',-3:1:3, 'XTickLabel', arrayfun(@(x) num2str(x,'%3.1f'), (-3:1:3)*sigma(3)+mu(3), 'UniformOutput', false));
set(gca,'view',[-39,16]);

%% RBF SVM
model2 = svmtrain(train_target, train_data, '-t 2 -w0 1 -w1 7 -g 0.05 -c 1 -q');
[pred,acc,prob] = svmpredict(test_target, test_data, model2,'-q');
[~,~,~,cstat] = perfcurve(test_target,prob,0);
fprintf('RBF SVM, AUROC = %2.2f\n',cstat);

x=-5:1:5; y = -5:1:5; z = -5:1:5;
[X,Y,Z] = meshgrid(x,y,z);
tmpdat = [X(:),Y(:),Z(:)];
[pred,acc,prob] = svmpredict(zeros(numel(X),1), tmpdat, model2,'-q');
prob = reshape(prob,length(y),length(x),length(z));

%=== visualisation
col = linspecer(5);
figure(2); clf; hold all;
idxSubsample = rand(size(train_target,1),1) < mean(train_target) & train_target==0;
plot3(train_data(idxSubsample,1),train_data(idxSubsample,2),train_data(idxSubsample,3),'Linestyle','none','Color',col(1,:),'Marker','o','LineWidth',3);
plot3(train_data(train_target==1,1),train_data(train_target==1,2),train_data(train_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','o','LineWidth',3);

idxSubsample = rand(size(test_target,1),1) < mean(test_target) & test_target==0;
plot3(test_data(idxSubsample,1),test_data(idxSubsample,2),test_data(idxSubsample,3),'Linestyle','none','Color',col(1,:),'Marker','+','LineWidth',3);
plot3(test_data(test_target==1,1),test_data(test_target==1,2),test_data(test_target==1,3),'Linestyle','none','Color',col(2,:),'Marker','+','LineWidth',3);
xlabel(curr_header{1}); ylabel(curr_header{2}); zlabel(curr_header{3});
grid on;

h=patch(isosurface(X,Y,Z,prob,-1)); set(h,'facecolor','none','edgecolor',col(4,:));
h=patch(isosurface(X,Y,Z,prob,1)); set(h,'facecolor','none','edgecolor',col(3,:));
set(gca,'view',[  -119    16]);
% Exercise 14
% Assign each observation in the training set an index [1,2,3,4], i.e.,
% prepare the indices for 4-fold cross-validation using ONLY the training
% set.
% Hint: Indices = crossvalind('Kfold', N, K)


% Exercise 15
% Train the SVM using cross-validation on the training set.


% Exercise 16
% Change the hyperparameters of the SVM using '-g # -c #' as input options,
% replacing # with reasonable alternatives. The default -g is 1/num_feat. 
% The default -c is 1. If you are unsure what to set, change them slightly
% and experiment. Continue experimenting until you improve your accuracy by
% at least 1%.


% Exercise 17
% Loop over a range of -g and -c values, calculating the cross-validation
% performance of the SVM model for each combination of -g and -c values.
% Retain the -g and -c values which give you the best cross-validation
% performance.


% Exercise 18
% Using the -g and -c values found in exercise 11, train the SVM using
% all of the training data, and evaluate it on the test data.


% Exercise 19
% Comment on your performance in exercise 18 as opposed to exercise 13.
