%% Plot pain/sedation medication
lbl1 = {'Midazolam (Versed)','Propofol','Fentanyl'};
for k=1:numel(lbl1)
    idxPlot = ismember(data_ie_str(:,3), lbl1{k});

    % time start/stop
    time_plot = data_ie(idxPlot,2:3);

    % rate start/stop
    data_plot = data_ie(idxPlot,5:6);
    
    idxPlot = find(time_plot(:,1) < 72); % only plot drug infusions in first 24 hr
    idxPlot = idxPlot(:)'; % ensure it is a row vector for "for" loop
    for m=idxPlot
    % starting marker
    plot(time_plot(m,1), data_plot(m,2), '<',...
        'color',col(k,:), 'markerfacecolor',col(k,:),...
        'linewidth',3,'markersize',8,...
        'HandleVisibility', 'off');

    % ending marker
    plot(time_plot(m,2), data_plot(m,2), '>',...
        'color',col(k,:), 'markerfacecolor',col(k,:),...
        'linewidth',3,'markersize',8,...
        'HandleVisibility', 'off');
    
    % ensure the plot line only appears in the legend once
    if m==idxPlot(end)
        visib='on';
    else
        visib='off';
    end
    
    % connecting line
    plot(time_plot(m,1:2), repmat(data_plot(m,2),1,2), '-',...
        'color',col(k,:), 'markerfacecolor',col(k,:),...
        'linewidth',3,'markersize',8,...
        'HandleVisibility', visib);
    end
end

legend_str = lbl1(:)';
legend(legend_str,'Location','NorthEast');

set(gca,'XLim',[0,72],'YLim',[0,200]);

xlabel('Hours since admission','FontSize',16);
ylabel('Value of measurement','FontSize',16);

P_PrettyFigure(1);
if savefigflag==1
export_fig(1,'exampledata6.png','-transparent');
end

% %% OR data
% idxKeep = data_ie(:,2)<72;
% ie_lbl = unique(data_ie_str(idxKeep,3));
% 
% lbl1 = {'OR Cryoprecipitate Intake';
%     'OR Crystalloid Intake';'OR FFP Intake';
%     'OR Packed RBC Intake';'OR Platelet Intake'};
% for k=1:numel(lbl1)
%     idxPlot = ismember(data_ie_str(:,3), lbl1{k});
% 
%     % time start/stop
%     time_plot = data_ie(idxPlot,2:3);
% 
%     % rate start/stop
%     data_plot = data_ie(idxPlot,5:6);
% 
%     % for OR volumes, it's always a bolus over 1 minute
%     plot(time_plot(1,1), data_plot(1,1)/100, 's',...
%         'color',[0,0,0], 'markerfacecolor',col(k+1,:),...
%         'linewidth',3,'markersize',10);
% end
% 
% ylabel('OR blood (mL/100)');
% legend_str = [legend_str,lbl1(:)'];
% legend(legend_str,'Location','NorthEast');
% 
% if savefigflag==1
% export_fig(1,'exampledata7.png','-transparent');
% end
%%
lbl1 = {'LR'};
for k=1:numel(lbl1)
    idxPlot = ismember(data_ie_str(:,3), lbl1{k});
    
    
    % time start/stop
    time_plot = data_ie(idxPlot,2:3);
    
    % rate start/stop
    data_plot = data_ie(idxPlot,5:6);
    
    M=3;
    for m=1:M
            % starting marker
            plot(time_plot(m,1), data_plot(m,2), '<',...
                'color',col(k+7,:), 'markerfacecolor',col(k+7,:),...
                'linewidth',3,'markersize',8,...
                'HandleVisibility', 'off');
            
            
            % ending marker
            plot(time_plot(m,2), data_plot(m,2), '>',...
                'color',col(k+7,:), 'markerfacecolor',col(k+7,:),...
                'linewidth',3,'markersize',8,...
                'HandleVisibility', 'off');
            
            % ensure the plot line only appears in the legend once
            if m==M
                visib='on';
            else
                visib='off';
            end
            
            % connecting line
            plot(time_plot(m,1:2), repmat(data_plot(m,2),1,2), '-',...
                'color',col(k+7,:), 'markerfacecolor',col(k+7,:),...
                'linewidth',3,'markersize',8,...
                'HandleVisibility', visib);
    end
    
    %=== plot bolus at M=4
    m=4;
    plot(time_plot(m,1), data_plot(m,1)/10, 's',...
        'color',col(k+7,:), 'markerfacecolor',col(k+7,:),...
        'linewidth',3,'markersize',10);
end

legend_str = [legend_str,lbl1(:)',strcat(lbl1(:)',' Bolus')];
legend(legend_str,'Location','NorthEast');


if savefigflag==1
export_fig(1,'exampledata8.png','-transparent');
end