%% Plot the labs
le_lbl = unique(data_le_str(:,3));
marker = {'d','+','o','x','>','d','<','+','^'};
lbl_keep = {'CREATININE';
    'HEMOGLOBIN';
    'PCO2';
    'PO2';
    'LACTATE'};


% plot the values
for k=1:numel(lbl_keep)
    idxPlot = ismember(data_le_str(:,3), lbl_keep{k});
    data_plot = data_le(idxPlot,4);
    if ismember(lbl_keep{k},{'PO2','PCO2'})==1
        % convert to kPa
        data_plot = data_plot / 7.500617;
    end
    plot(data_le(idxPlot,2), data_plot, ['--' marker{k}],...
        'Color',col(k,:), 'markerfacecolor',col(k,:),...
        'markersize',12,'linewidth',2);
end

legend_str = lbl_keep(:)';
legend(lbl_keep,'Location','NorthEast');

set(gca,'XLim',[0,72],'YLim',[0,25]);

xlabel('Hours since admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

P_PrettyFigure(1);
if savefigflag==1
    
legend(lbl_keep,'Location','NorthWest');
export_fig(1,'exampledata5.png','-transparent');
end