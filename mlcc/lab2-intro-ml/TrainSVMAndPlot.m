function [ model, V, t_pred,t_acc,t_prob ] = TrainSVMAndPlot(tr_data,tr_tar, t_data, t_tar, header, options)
%TRAINSVMANDPLOT	Train SVM and plot it using the given data
%[ model, V, t_pred,t_acc,t_prob ] = TrainSVMAndPlot(tr_data,tr_tar, t_data, t_tar, header, options)
%
%   IMPORTANT: Make sure the data has at least 3 dimensions
%	
%	See also B1_SVMDEMO

%	Copyright 2014 Alistair Johnson

%	$LastChangedBy$
%	$LastChangedDate$
%	$Revision$
%	Originally written on GLNXA64 by Alistair Johnson, 18-Feb-2014 12:28:30
%	Contact: alistairewj@gmail.com

if size(tr_data,2)<3
    error('3 dimensions required for this function.');
end
if size(tr_data,2)>3
    tr_data = tr_data(:,1:3);
    t_data = t_data(:,1:3);
    fprintf('Only using first 3 dimensions.\n');
end

model = svmtrain(tr_tar, tr_data, options);
[t_pred,t_acc,t_prob] = svmpredict(t_tar, t_data, model);

x=floor(min(tr_data(:,1))):0.1:ceil(max(tr_data(:,1))); 
y=floor(min(tr_data(:,2))):0.1:ceil(max(tr_data(:,2))); 
z=floor(min(tr_data(:,3))):0.1:ceil(max(tr_data(:,3))); 

[X,Y,Z] = meshgrid(x,y,z);
tmpdat = [X(:),Y(:),Z(:)];
[pred,acc,V] = svmpredict(zeros(numel(X),1), tmpdat, model, '-q');
V = reshape(V,length(y),length(x),length(z));
col = [0.363921568627451,0.575529411764706,0.748392156862745;0.915294117647059,0.281568627450980,0.287843137254902;0.441568627450980,0.749019607843137,0.432156862745098;1,0.598431372549020,0.200000000000000;0.676862745098039,0.444705882352941,0.711372549019608];

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
end