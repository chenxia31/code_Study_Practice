load('resource_data.mat');
ZH3605(4320,:)=ZH3605(4319,:);
%%
%绘制图 plot(ZH3304{:,2},ZH3304{:,4})
%%
%故障数据检测,ZHwx33(1)-1105为例
%%
%独立判断法（设置流量范围【0，3060】，速度范围【0，80*1.4】，占有率范围【0，95】
logic=zeros(size(ZH3305,1),3);
logic(:,1)=(ZH3305{:,4}>17);
logic(:,2)=(ZH3305{:,5}>112);
logic(:,3)=(ZH3305{:,6}>95);
Index_3305=(sum(logic,2)>0);
Error_independent_3305=ZH3305(Index_3305,:);  %提取错误数据
%绘制小时有效性
%%
%联合判断法,如果流量、速度、占有率中出现0值，其他必为0值，否则出错
logic=zeros(size(ZH3305,1),3);
logic(:,1)=(ZH3305{:,4}>0);
logic(:,2)=(ZH3305{:,5}>0);
logic(:,3)=(ZH3305{:,6}>0);
logic=sum(logic,2);
Index_3305=(((logic==3)+(logic==0))+(ZH3305{:,6}>95))==0;
Error_combine_3305=ZH3305(Index_3305,:);  %提取错误数据
%绘制小时有效性

%%
%有效车长判断 
aveL_3305=10*ZH3305{:,5}.*ZH3305{:,6}./ZH3305{:,4}/180;
Index_3305=((aveL_3305>12)+(aveL_3305<3))==1;
Error_aveL_3305=ZH3305(Index_3305,:);  %提取错误数据
%%
%绘制小时有效性
Error=[Error_aveL_3305;Error_combine_3305;Error_independent_3305];
Error=unique(Error);
Error_time=datevec(Error{:,2});
[a,b]=hist(Error_time(:,4),unique(Error_time(:,4)));
%%
pie3([size(Error_independent_3305,1),size(Error_combine_3305,1),size(Error_aveL_3305,1)]);
legend('独立判断','联合判断','有效长度判断')
%%
Error_rate=ones(1,24);
for i=1:length(b)
    Error_rate(b(i)+1)=(Error_rate(b(i)+1)*180-a(i))/(Error_rate(b(i)+1)*180);
end
%%
bar([0.5:1:23.5],Error_rate);
set(gca,'ylim',[0.9,1]);
title('ZHWX33(1)-1105交通流数据20s有效性')
%%
%ZH3305和上述程序会有重复
day_rate=zeros(2,6);
[day_rate(1),Error1,ZH3304]=data_check(ZH3304);
[day_rate(2),Error2,ZH3305]=data_check(ZH3305);
[day_rate(3),Error3,ZH3404]=data_check(ZH3404);
[day_rate(4),Error4,ZH3405]=data_check(ZH3405);
[day_rate(5),Error5,ZH3504]=data_check(ZH3504);
[day_rate(6),Error6,ZH3505]=data_check(ZH3505);
[day_rate(7),Error7,ZH3604]=data_check(ZH3604);
[day_rate(8),Error8,ZH3605]=data_check(ZH3605);
[day_rate(9),Error9,ZH3704]=data_check(ZH3704);
[day_rate(10),Error10,ZH3705]=data_check(ZH3705);
[day_rate(11),Error11,ZH3804]=data_check(ZH3804);
[day_rate(12),Error12,ZH3805]=data_check(ZH3805);
%%
%
bar(day_rate');
set(gca,'ylim',[0.9,1]);
legend('第四日','第五日');
title('各检测器4日和5日检测日有效性');
set(gca,'xticklabel',{'ZHWX33(1)','ZHWX34(1)','ZHWX35(1)','ZHWX36(1)','ZHWX37(1)','ZHWX38(1)'});
%%
%数据修复，ZHwx33(1)-1105为例,利用该数据点之前和之后数据平均值
delete_Index=(sort(randperm(size(ZH3305,1)-5,100))+5);
ZH3305_deletion=ZH3305;
for i=1:length(delete_Index)
    ZH3305_deletion{delete_Index(i),4:6}=1/2*((ZH3305{delete_Index(i)-1,4:6}+ZH3305{delete_Index(i)+1,4:6}));
end
%%
%流量、速度、密度
figure,
plot(1:100,ZH3304{delete_Index,4},'b*',1:100,ZH3305_deletion{delete_Index,4},'r.')
legend('真实值','估计值');
title('ZHWX33(1)-1105流量（pcu/20s)真实值与估计值的对比');
figure,
plot(1:100,ZH3304{delete_Index,5},'b*',1:100,ZH3305_deletion{delete_Index,5},'r.')
legend('真实值','估计值');
title('ZHWX33(1)-1105速度(km/h)真实值与估计值的对比');
figure,
plot(1:100,ZH3304{delete_Index,6},'b*',1:100,ZH3305_deletion{delete_Index,6},'r.')
legend('真实值','估计值');
title('ZHWX33(1)-1105占有率(%)真实值与估计值的对比');
%%
%量化误差
Delta=sum(abs(ZH3305_deletion{delete_Index,4:6}-ZH3304{delete_Index,4:6}))./sum(ZH3305{delete_Index,4:6});
b=bar(Delta');
title('数据修复之后的量化误差');
xtips2 = b.XEndPoints;
ytips2 = b.YEndPoints;
labels2 = string(b.YData);
text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
set(gca,'xTicklabel',{'流量','速度','占有率'});
%%
[temp,bug_Index]=ismember(Error,ZH3305);
ZH3305_bug=ZH3305;
for i=1:length(bug_Index)
    ZH3305_bug{bug_Index(i),4:6}=1/2*((ZH3305{bug_Index(i)-1,4:6}+ZH3305{bug_Index(i)+1,4:6}));
end
Error_correct=ZH3305_bug{bug_Index,4:6};
%%
%移动平均法
%流量
figure,
ZH3305_3smoothyidong=yidongpingjun(ZH3305_bug{:,4:6},3);
ZH3305_10smoothyidong=yidongpingjun(ZH3305_bug{:,4:6},10);
ZH3305_30smoothyidong=yidongpingjun(ZH3305_bug{:,4:6},30);

subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,4},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothyidong(:,1),'b'),legend('windows=3');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothyidong(:,1),'y'),legend('windows=10');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothyidong(:,1),'g'),legend('windows=30');
suptitle('ZHWX33(1)-1105线圈流量（veh/20s)移动平均平滑后结果');

%%
%指数平滑
%流量
figure,
ZH3305_3smoothzhishu=zhishupingjun(ZH3305_bug{:,4:6},0.9);
ZH3305_10smoothzhishu=zhishupingjun(ZH3305_bug{:,4:6},0.6);
ZH3305_30smoothzhishu=zhishupingjun(ZH3305_bug{:,4:6},0.3);

subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,4},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothzhishu(:,1),'b'),legend('a=0.9');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothzhishu(:,1),'y'),legend('a=0.6');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothzhishu(:,1),'g'),legend('a=0.3');
suptitle('ZHWX33(1)-1105线圈流量(veh/20s)指数平均平滑后结果');
%%
m=2;
figure,
subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,m+3},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothyidong(:,m),'b'),legend('windows=3');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothyidong(:,m),'y'),legend('windows=10');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothyidong(:,m),'g'),legend('windows=30');
suptitle('ZHWX33(1)-1105线圈速度（km/h)移动平均平滑后结果');
%%
m=2;
figure,
subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,m+3},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothzhishu(:,m),'b'),legend('a=0.9');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothzhishu(:,m),'y'),legend('a=0.6');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothzhishu(:,m),'g'),legend('a=0.3');
suptitle('ZHWX33(1)线圈速度（km/h)指数平均平滑后结果');
%%
m=3;
figure,
subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,m+3},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothyidong(:,m),'b'),legend('windows=3');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothyidong(:,m),'y'),legend('windows=10');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothyidong(:,m),'g'),legend('windows=30');
suptitle('ZHWX33(1)--1105线圈占有率（%)移动平均平滑后结果');
%%
m=3;
figure,
subplot(2,2,1),plot(ZH3304{:,2},ZH3305_bug{:,m+3},'r'),legend('resource data');
subplot(2,2,2),plot(ZH3304{:,2},ZH3305_3smoothzhishu(:,m),'b'),legend('a=0.9');
subplot(2,2,3),plot(ZH3304{:,2},ZH3305_10smoothzhishu(:,m),'y'),legend('a=0.6');
subplot(2,2,4),plot(ZH3304{:,2},ZH3305_30smoothzhishu(:,m),'g'),legend('a=0.3');
suptitle('ZHWX33(1)线圈速度（km/h)指数平均平滑后结果');
%%
%绘制交通态势图
ZH3304_smooth=yidongpingjun(ZH3304{:,4:6},30);
ZH3305_smooth=yidongpingjun(ZH3305{:,4:6},30);
ZH3404_smooth=yidongpingjun(ZH3404{:,4:6},30);
ZH3405_smooth=yidongpingjun(ZH3405{:,4:6},30);
ZH3504_smooth=yidongpingjun(ZH3504{:,4:6},30);
ZH3505_smooth=yidongpingjun(ZH3505{:,4:6},30);
ZH3604_smooth=yidongpingjun(ZH3604{:,4:6},30);
ZH3605_smooth=yidongpingjun(ZH3605{:,4:6},30);
ZH3704_smooth=yidongpingjun(ZH3704{:,4:6},30);
ZH3705_smooth=yidongpingjun(ZH3705{:,4:6},30);
ZH3804_smooth=yidongpingjun(ZH3804{:,4:6},30);
ZH3805_smooth=yidongpingjun(ZH3805{:,4:6},30);
%%
x=1:1:4320;
y=[0,482,806,1265,1729,2143];
ytick=[1         415         879        1338        1662        2143];
n=3;
O4=data_imagesc(y,ZH3304_smooth(:,n),ZH3404_smooth(:,n),ZH3504_smooth(:,n),ZH3604_smooth(:,n), ZH3704_smooth(:,n),ZH3804_smooth(:,n));
colormap jet
imagesc(O4)
set(gca, 'YTick',ytick);         % Y轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
title('第四日交通态势图--占有率（%）');% X轴的记号点 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
colorbar('AxisLocation','in')
%%
n=1;
Q4=data_imagesc(y,ZH3304_smooth(:,n),ZH3404_smooth(:,n),ZH3504_smooth(:,n),ZH3604_smooth(:,n), ZH3704_smooth(:,n),ZH3804_smooth(:,n));
colormap winter
imagesc(Q4)
set(gca, 'YTick',ytick);         % X轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
colorbar('AxisLocation','in');
title('第四日交通态势图--流量（pcu/20s)');% X轴的记号点 
%%
n=2;
V4=data_imagesc(y,ZH3304_smooth(:,n),ZH3404_smooth(:,n),ZH3504_smooth(:,n),ZH3604_smooth(:,n), ZH3704_smooth(:,n),ZH3804_smooth(:,n));
colormap autumn
imagesc(V4)
set(gca, 'YTick',ytick);         % X轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
title('第四日交通态势图--速度（km/h)');% X轴的记号点 
colorbar('AxisLocation','in');
%%
n=1;
Q5=data_imagesc(y,ZH3305_smooth(:,n),ZH3405_smooth(:,n),ZH3505_smooth(:,n),ZH3605_smooth(:,n), ZH3705_smooth(:,n),ZH3805_smooth(:,n));
colormap winter
imagesc(Q5)
set(gca, 'YTick',ytick);         % X轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
title('第五日交通态势图--流量（pcu/20s)');% X轴的记号点 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
colorbar('AxisLocation','in');
%%
n=2;
V5=data_imagesc(y,ZH3305_smooth(:,n),ZH3405_smooth(:,n),ZH3505_smooth(:,n),ZH3605_smooth(:,n), ZH3705_smooth(:,n),ZH3805_smooth(:,n));
colormap autumn
imagesc(V5)
set(gca, 'YTick',ytick);         % X轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
title('第五日交通态势图--速度（km/h)');% X轴的记号点 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
colorbar('AxisLocation','in');
%%
n=3;
O5=data_imagesc(y,ZH3305_smooth(:,n),ZH3405_smooth(:,n),ZH3505_smooth(:,n),ZH3605_smooth(:,n), ZH3705_smooth(:,n),ZH3805_smooth(:,n));
colormap jet
imagesc(O5)
set(gca, 'YTick',ytick);         % X轴的记号点 
set(gca, 'YTicklabel',{'ZHWX38(1)','ZHWX37(1)','ZHWX36(1)','ZHWX35(1)','ZHWX34(1)','ZHWX33(1)'});   % X轴的记号
set(gca, 'XTick',0:480:4320); 
title('第五日交通态势图--占有率（%）');% X轴的记号点 
set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});   % X轴的记号
colorbar('AxisLocation','in');