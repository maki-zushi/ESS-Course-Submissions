function ess_week2_figures(W,root)
% 任务四结果：白底600dpi PNG、矢量PDF及FIG图源。
P=W.Parameters; t=1:P.T; ids=find(W.Build>0.5);
palette=[0.12 0.34 0.62;0.85 0.37 0.13;0.13 0.57 0.40;0.53 0.34 0.66];
f=new_figure([1200 1040]);
tl=tiledlayout(f,3,2,'TileSpacing','compact','Padding','compact');
nexttile(tl); b=bar(P.Candidate_Buses(:),[W.PowerRating_MW,W.EnergyRating_MWh],0.72);
b(1).FaceColor=palette(1,:); b(2).FaceColor=palette(2,:);
xticks(P.Candidate_Buses); xlabel('候选母线编号'); ylabel('功率 / MW；容量 / MWh');
title('储能选址与额定配置'); legend({'额定功率','额定能量容量'},'Location','northwest');
nexttile(tl); cost=[W.AnnualInvestment_Yuan,W.AnnualOM_Yuan,W.AnnualGridCostLin_Yuan]/1e4;
b=bar(1:3,cost,0.6,'FaceColor','flat'); b.CData=palette(1:3,:);
xticks(1:3);xticklabels({'年化投资','年运维','年购电'});ylabel('费用 / 万元·年^{-1}');
title(sprintf('规划年综合费用 %.2f 万元',W.AnnualTotalCost_Yuan/1e4));
text(1:3,cost,string(round(cost,2)),'HorizontalAlignment','center','VerticalAlignment','bottom');
ylim([0,max(cost)*1.18]);
nexttile(tl); stairs(t,sum(W.Pch_MW,1),'--','LineWidth',1.7,'Color',palette(1,:));hold on;
stairs(t,sum(W.Pdis_MW,1),'-','LineWidth',1.7,'Color',palette(2,:));
xlabel('时段 / h');ylabel('功率 / MW');title('已配置储能总充放电功率');
xlim([1 P.T]);xticks([1 6 12 18 24]);
legend({'充电','放电'},'Location','best');
nexttile(tl); hold on;
for k=1:numel(ids)
    i=ids(k);plot(0:P.T,W.SoC(i,:),'-o','LineWidth',1.6,'MarkerSize',3,...
        'Color',palette(k,:),'DisplayName',sprintf('节点%d',P.Candidate_Buses(i)));
end
yline(P.SoCmin,':','HandleVisibility','off');yline(P.SoCmax,':','HandleVisibility','off');
xlabel('时段 / h');ylabel('SoC');title('已配置储能荷电状态');ylim([0.1 0.9]);
xlim([0 P.T]);xticks(0:4:P.T);
if ~isempty(ids),legend('Location','best');end
nexttile(tl); yyaxis left;
plot(t,W.Baseline.Grid_MW,'--','LineWidth',1.5);hold on;
plot(t,W.AC.Grid_MW,'-','LineWidth',1.7);ylabel('交流主网购电功率 / MW');
yyaxis right;stairs(t,P.Price/1000,':','LineWidth',1.5);ylabel('电价 / 元·kWh^{-1}');
xlabel('时段 / h');title('主网购电与分时电价');
xlim([1 P.T]);xticks([1 6 12 18 24]);
legend({'配置前','配置后','分时电价'},'Location','best');
nexttile(tl); node=W.Baseline.MinBus;
plot(t,W.Baseline.Voltage_pu(node,:),'--','LineWidth',1.6,'Color',palette(1,:));hold on;
plot(t,W.VoltageLin_pu(node,:),':','LineWidth',1.7,'Color',palette(2,:));
plot(t,W.AC.Voltage_pu(node,:),'-','LineWidth',1.8,'Color',palette(3,:));yline(P.VminAC,'-.','0.95 p.u.');
xlabel('时段 / h');ylabel('电压 / p.u.');title(sprintf('基准薄弱节点%d的时序电压',node));
xlim([1 P.T]);xticks([1 6 12 18 24]);
legend({'配置前交流','配置后线性','配置后交流'},'Location','best');
style_and_export(f,root,'Fig_Week2_206221321');

f=new_figure([1200 880]);tl=tiledlayout(f,2,2,'TileSpacing','compact','Padding','compact');
vrange=[min([W.Baseline.Voltage_pu(:);W.AC.Voltage_pu(:)]),1.001];
nexttile(tl);surf(t,1:size(W.AC.Voltage_pu,1),W.Baseline.Voltage_pu,'EdgeColor','none');
view(-42,28);clim(vrange);zlim(vrange);colorbar;xlabel('时段 / h');ylabel('节点编号');zlabel('电压 / p.u.');title('配置前：全网交流电压');
xlim([1 P.T]);ylim([1 49]);xticks([1 6 12 18 24]);yticks([1 13 25 37 49]);
nexttile(tl);surf(t,1:size(W.AC.Voltage_pu,1),W.AC.Voltage_pu,'EdgeColor','none');
view(-42,28);clim(vrange);zlim(vrange);colorbar;xlabel('时段 / h');ylabel('节点编号');zlabel('电压 / p.u.');title('配置后：全网交流电压');
xlim([1 P.T]);ylim([1 49]);xticks([1 6 12 18 24]);yticks([1 13 25 37 49]);
nexttile(tl);imagesc(t,1:size(W.AC.Voltage_pu,1),W.VoltageLin_pu-W.AC.Voltage_pu);axis xy;colorbar;
xlabel('时段 / h');ylabel('节点编号');title('线性模型电压减交流电压 / p.u.');
nexttile(tl);c=loadcase(P.Case);g=digraph(c.branch(:,1),c.branch(:,2));
h=plot(g,'Layout','layered','Sources',1,'NodeLabel',string(c.bus(:,1)),...
    'MarkerSize',4,'NodeColor',[0.4 0.48 0.57],'EdgeColor',[0.68 0.72 0.76],'ArrowSize',4);
highlight(h,P.Candidate_Buses,'NodeColor',palette(2,:),'MarkerSize',7);
if ~isempty(ids),highlight(h,P.Candidate_Buses(ids),'NodeColor',palette(3,:),'MarkerSize',10);end
title('49节点拓扑：橙色候选点，绿色已配置点');axis off;
style_and_export(f,root,'Fig_Week2_Voltage_206221321');

f=new_figure([1200 500]);tl=tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');
S=W.Sensitivity; nexttile(tl);
q=S.Experiment=="EnergyCost"; ss=sortrows(S(q,:),'EnergyUnitCost_YuanPerMWh');
plot(ss.EnergyUnitCost_YuanPerMWh/1e4,ss.AnnualTotalCost_Yuan/1e4,'-o',...
    'LineWidth',1.8,'Color',palette(1,:));
xlabel('单位容量投资 / 万元·MWh^{-1}');ylabel('规划年综合费用 / 万元·年^{-1}');
title('单位能量投资成本灵敏度');
for k=1:height(ss)
    alignment='left';if k==height(ss),alignment='right';end
    text(ss.EnergyUnitCost_YuanPerMWh(k)/1e4,ss.AnnualTotalCost_Yuan(k)/1e4,...
        sprintf('  %.0f MW / %.0f MWh',ss.TotalPower_MW(k),ss.TotalEnergy_MWh(k)),...
        'FontSize',9,'VerticalAlignment','bottom','HorizontalAlignment',alignment);
end
nexttile(tl); q=S.Experiment=="VoltageMargin";ss=sortrows(S(q,:),'VminLin_pu');
plot(ss.VminLin_pu,ss.MinACVoltage_pu,'-o','LineWidth',1.8,'Color',palette(3,:));hold on;
yline(P.VminAC,'--','交流下限0.95');xlabel('线性模型电压下限 / p.u.');ylabel('交流最低电压 / p.u.');
title('线性电压下限裕度与交流校核');
for k=1:height(ss)
    alignment='left';if k==height(ss),alignment='right';end
    text(ss.VminLin_pu(k),ss.MinACVoltage_pu(k),sprintf('  %.0f MW / %.0f MWh',...
        ss.TotalPower_MW(k),ss.TotalEnergy_MWh(k)),'FontSize',9,'VerticalAlignment','bottom',...
        'HorizontalAlignment',alignment);
end
style_and_export(f,root,'Fig_Week2_Sensitivity_206221321');
end

function f=new_figure(sz)
f=figure('Color','w','NumberTitle','off','Visible','on','Position',[60 60 sz]);
if isprop(f,'Theme'),theme(f,'light');end
end

function style_and_export(f,root,name)
set(findall(f,'Type','axes'),'FontName','Times New Roman','FontSize',11,...
    'LineWidth',0.8,'Box','on','GridAlpha',0.12);
axes_all=findall(f,'Type','axes');
for k=1:numel(axes_all)
    ax=axes_all(k);if strcmp(ax.Visible,'on'),grid(ax,'on');end
    set([ax.XLabel ax.YLabel ax.ZLabel ax.Title],'FontName','Songti SC');
    ax.Title.FontSize=12;ax.Title.FontWeight='normal';
end
set(findall(f,'Type','legend'),'FontName','Songti SC','FontSize',10,'Box','off');
set(findall(f,'Type','text'),'FontName','Songti SC');
drawnow;
exportgraphics(f,fullfile(root,[name '.png']),'Resolution',600,'BackgroundColor','white');
exportgraphics(f,fullfile(root,[name '.pdf']),'ContentType','vector','BackgroundColor','white');
savefig(f,fullfile(root,[name '.fig']));
end
