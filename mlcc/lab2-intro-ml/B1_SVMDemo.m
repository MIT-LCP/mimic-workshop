%B1_SVMDEMO	Pretty plots of SVM using Fisher Iris data and LIBSVM
%	Copyright 2014 Alistair Johnson

%============ IMPORTANT ============%
% Please download LIBSVM package from:
% http://www.csie.ntu.edu.tw/~cjlin/libsvm/
% Scroll down to "Download LIBSVM" and click on the zip file link
% Extract the zip file and add libsvm-3.17./matlab it into your MATLAB path
%========= STILL IMPORTANT =========%
% The files you need are in a SUBDIRECTORY: libsvm-3.17/windows/
% MAKE SURE YOU ADD THE SUBDIRECTORY !!!
% Note: if you are on Linux/Mac, add the other appropriate subdirectory
% containing pre-compiled binaries, or compile libsvm from source.


rng(777,'twister');
col = [0.363921568627451,0.575529411764706,0.748392156862745;0.915294117647059,0.281568627450980,0.287843137254902;0.441568627450980,0.749019607843137,0.432156862745098;1,0.598431372549020,0.200000000000000;0.676862745098039,0.444705882352941,0.711372549019608];

%% Load the data and separate it into train/test
% Load the sample data - Fisher's iris data
load fisheriris
header = {'Sepal length','Sepal width','Petal length','Petal width'};
% The data is 4 measurements on a sample of 150 irises

% The three types of irises (flowers)
species_type={'setosa','versicolor','virginica'};

% Remove all 'versicolor' species from the data
X = meas(~strcmp(species,'versicolor'),:);
y = species(~strcmp(species,'versicolor'));
y = double(strcmp(y,'virginica'));

% Using the hold-out technique, create a training and test set.
idxTrain = rand(size(X,1),1) > 0.3;
tr_data = X(idxTrain,1:3); tr_tar = y(idxTrain,:);
t_data = X(~idxTrain,1:3); t_tar = y(~idxTrain,:); 


% Using LIBSVM, train an SVM classifier with a linear kernel
model = svmtrain(tr_tar, tr_data, '-t 0');
% Atypically, LIBSVM receives options as a single string in the fourth input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'

% Apply the classifier to the test set, and evaluate the performance in 
% terms of mean square error AND accuracy.
[pred,acc,prob] = svmpredict(t_tar, t_data, model);

%% Plot the linear SVM hyperplane
figure(1); clf; hold all;

plot3(tr_data(tr_tar==0,1),tr_data(tr_tar==0,2),tr_data(tr_tar==0,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==0,1),t_data(t_tar==0,2),t_data(t_tar==0,3),'Linestyle','none','MarkerFaceColor',col(3,:),'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);

plot3(tr_data(tr_tar==1,1),tr_data(tr_tar==1,2),tr_data(tr_tar==1,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==1,1),t_data(t_tar==1,2),t_data(t_tar==1,3),'Linestyle','none','MarkerFaceColor',col(4,:),'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);

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

xlabel(header{1},'FontSize',14);
ylabel(header{2},'FontSize',14);
zlabel(header{3},'FontSize',14);
legend('Class 0 - Train', 'Class 0 - Test','Class 1 - Train', 'Class 1 - Test', 'Location','Best');

%% now try the harder problem, with setosa removed

% Remove all 'versicolor' species from the data
X = meas(~strcmp(species,'setosa'),:);
y = species(~strcmp(species,'setosa'));
y = double(strcmp(y,'virginica')==1);

% Using the hold-out technique, create a training and test set.
idxTrain = rand(size(X,1),1) > 0.3;
tr_data = X(idxTrain,1:3); tr_tar = y(idxTrain,:);
t_data = X(~idxTrain,1:3); t_tar = y(~idxTrain,:); 


% Using LIBSVM, train an SVM classifier with a linear kernel
model = svmtrain(tr_tar, tr_data, '-t 0');
% Atypically, LIBSVM receives options as a single string in the fourth input
% e.g. '-v 1 -b 1 -g 0.5 -c 1'

% Apply the classifier to the test set, and evaluate the performance in 
% terms of mean square error AND accuracy.
[pred,acc,prob] = svmpredict(t_tar, t_data, model);

figure(1); clf; hold all;

plot3(tr_data(tr_tar==0,1),tr_data(tr_tar==0,2),tr_data(tr_tar==0,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==0,1),t_data(t_tar==0,2),t_data(t_tar==0,3),'Linestyle','none','MarkerFaceColor',col(3,:),'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);

plot3(tr_data(tr_tar==1,1),tr_data(tr_tar==1,2),tr_data(tr_tar==1,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==1,1),t_data(t_tar==1,2),t_data(t_tar==1,3),'Linestyle','none','MarkerFaceColor',col(4,:),'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);
grid on;

%=== generate the normal vector of the plane from the SVs
w = model.SVs' * model.sv_coef;
b = model.rho;

% use equation of a plane to plot the separating hyperplane
x=-10:1:10;
[X,Y] = meshgrid(x);
Z=(b - w(1) * X - w(2) * Y)/w(3);
mesh(X,Y,Z,'EdgeColor',col(5,:),'FaceColor','none');
set(gca,'view',[-127    10]);

xlabel(header{1},'FontSize',14);
ylabel(header{2},'FontSize',14);
zlabel(header{3},'FontSize',14);
legend('Class 0 - Train', 'Class 0 - Test','Class 1 - Train', 'Class 1 - Test', 'Location','Best');


%% now try an RBF with default params
[ model, V ] = TrainSVMAndPlot(tr_data,tr_tar, t_data, t_tar, header, '-t 2 -g 1 -c 1 -q');
set(gca,'view',[-135    14]);

%% vary the isosurface of the SVM

figure(1); clf; hold all;
plot3(tr_data(tr_tar==0,1),tr_data(tr_tar==0,2),tr_data(tr_tar==0,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==0,1),t_data(t_tar==0,2),t_data(t_tar==0,3),'Linestyle','none','MarkerFaceColor',col(3,:),'MarkerEdgeColor',col(3,:),'Marker','o','MarkerSize',10,'LineWidth',3);

plot3(tr_data(tr_tar==1,1),tr_data(tr_tar==1,2),tr_data(tr_tar==1,3),'Linestyle','none','MarkerFaceColor',[1,1,1],'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);
plot3(t_data(t_tar==1,1),t_data(t_tar==1,2),t_data(t_tar==1,3),'Linestyle','none','MarkerFaceColor',col(4,:),'MarkerEdgeColor',col(4,:),'Marker','d','MarkerSize',10,'LineWidth',3);

%=== plot support vectors in black
SVs = full(model.SVs);
plot3(SVs(model.sv_coef>0,1),SVs(model.sv_coef>0,2),SVs(model.sv_coef>0,3),'Linestyle','none','MarkerFaceColor',col(3,:),'MarkerEdgeColor','k','Marker','o','MarkerSize',10,'LineWidth',3);
plot3(SVs(model.sv_coef<0,1),SVs(model.sv_coef<0,2),SVs(model.sv_coef<0,3),'Linestyle','none','MarkerFaceColor',col(4,:),'MarkerEdgeColor','k','Marker','d','MarkerSize',10,'LineWidth',3);

xlabel(header{1},'FontSize',14);
ylabel(header{2},'FontSize',14);
zlabel(header{3},'FontSize',14);

x=floor(min(tr_data(:,1))):0.1:ceil(max(tr_data(:,1))); 
y=floor(min(tr_data(:,2))):0.1:ceil(max(tr_data(:,2))); 
z=floor(min(tr_data(:,3))):0.1:ceil(max(tr_data(:,3))); 

[X,Y,Z] = meshgrid(x,y,z);
clear x y z;

h1=patch(isosurface(X,Y,Z,V,1)); set(h1,'facecolor','none','edgecolor',min(col(3,:)*1.1,1));
h2=patch(isosurface(X,Y,Z,V,-1)); set(h2,'facecolor','none','edgecolor',min(col(4,:)*1.1,1));
h3=patch(isosurface(X,Y,Z,V,0)); set(h3,'facecolor','none','edgecolor',col(5,:));
grid on;
set(gca,'view',[-39,16]);

legend('Class 0 - Train', 'Class 0 - Test','Class 1 - Train', 'Class 1 - Test', 'Support Vectors Class 0', 'Support Vecotrs Class 1',...
    'Location','Best');

delete(h1); delete(h2); delete(h3);
h=patch(isosurface(X,Y,Z,V,-1)); set(h,'facecolor','none','edgecolor',col(4,:));

%% vary the value at which we plot the hyperplane
%=== generate a color transition matrix for the hyperplane
iso = [linspace(-1,-0.1,5),...
    -0.05, -0.01, -0.001, 0, 0.001, 0.01, 0.05,...
    linspace(.1,1,5)];
colchange = nan(numel(iso),3);
colchange(1,:) = min(col(4,:)*1.1,1);
colchange(end,:) = min(col(3,:)*1.1,1);
for n=1:3
colchange(:,n) = linspace(colchange(1,n),colchange(end,1),numel(iso));
end

for n=1:numel(iso)
    delete(h);
    
    if iso(n)==0 % longer delay for the separating hyperplane
        h=patch(isosurface(X,Y,Z,V,iso(n))); set(h,'facecolor','none','edgecolor',col(5,:));
        pause(4);
        
    else
        h=patch(isosurface(X,Y,Z,V,iso(n))); set(h,'facecolor','none','edgecolor',colchange(n,:));
        pause(1);
    end
    
    
end


%% RBF varying capacity
for c=2.^(0:6)
[ model ] = TrainSVMAndPlot(tr_data,tr_tar, t_data, t_tar, header, ['-t 2 -g 1 -c ' num2str(c) ' -q']);
legend('Versicolor','Virginica','Location','Best');
title('o = train, + = test');
set(gca,'view',[-39,16]);
pause(2);

end

%% RBF varying gamma
for g=2.^(6:-1:-5)
[ model ] = TrainSVMAndPlot(tr_data,tr_tar, t_data, t_tar, header, ['-t 2 -g ' num2str(g) ' -c 1 -q']);
legend('Versicolor','Virginica','Location','Best');
title('o = train, + = test');
set(gca,'view',[-39,16]);
pause(2);
end