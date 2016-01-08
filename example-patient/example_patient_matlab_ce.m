
lbl_plot = {'Arterial Blood Pressure mean','Heart Rate','O2 saturation pulseoxymetry','Respiratory Rate'};
% plot the values
for k=1:numel(lbl_plot)
    idxPlot = ismember(data_ce_str(:,3), lbl_plot{k});
    plot(data_ce(idxPlot,2), data_ce(idxPlot,4),marker{k},...
        'Color',col(k,:), 'MarkerFaceColor',col(k,:), 'markersize',ms(k), 'linewidth',2);
end


set(gca,'XLim',[0,72],'YLim',[0,150]);
set(gca,'YTick',0:25:150);

xlabel('Hours since admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

%=== add in the legend
legend_str = {'Mean arterial blood pressure','Heart Rate','Peripheral oxygen saturation','Respiratory Rate'};

% dummy figure to provide the legend
hleg=legend(legend_str,'Location','NorthEast');
set(gca,'FontSize',16);
grid on;

%% add in GCS
lbl_keep = {'GCS - Eye Opening';'GCS - Motor Response';'GCS - Verbal Response'};
lbl_plot = (135:20:175)+2;

% plot the values
for k=1:numel(lbl_keep)
    idxPlot = ismember(data_ce_str(:,3), lbl_keep{k});
    data_plot = data_ce_str(idxPlot,1);
    time_plot = data_ce(idxPlot,2);

    idxM = find(time_plot < 72);
%     idxM = idxM(1:4:end);
    idxM = idxM(:)';
    for m=idxM
    text(time_plot(m),...
        lbl_plot(k),... % y-axis location, defined above
        data_plot{m},...
        'FontName','Helvetica','FontSize',14);
    end
end
lbl_keep = strrep(lbl_keep,'GCS - ','');

% add the GCS stuff to the y-axis
set(gca,'YLim',[0,200],'YTick',[0:50:100,135,155,175,200],...
     'YTickLabel',{'0','50','100',lbl_keep{1},lbl_keep{2},lbl_keep{3},'200'});
if savefigflag==1
export_fig(1,'exampledata3.png','-transparent');
end
%% add in labs
le_lbl = unique(data_le_str(:,3));

lbl_keep = {'CREATININE';
    'HEMOGLOBIN'};


% plot the values
for k=1:numel(lbl_keep)
    idxPlot = ismember(data_le_str(:,3), lbl_keep{k});
    plot(data_le(idxPlot,2), data_le(idxPlot,4),marker{k+4},...
        'Color',[0,0,0], 'markerfacecolor',col(k+4,:),...
        'markersize',12,'linewidth',2);
end

legend_str = legend_str(:)';
legend_str = [legend_str,lbl_keep'];
legend(legend_str,'Location','NorthEast');

if savefigflag==1
export_fig(1,'exampledata4.png','-transparent');
end