% 2021秋，《交通信息检测与处理》课程设计
% author：chenxia
% Tel:17721279356
% Mail:1854084@tongji.edu.cn
% MATLAB R2021a -- based intel
%% 
% 导入数据，可以选择跳过！！，因为数据重新保存在mat中
load('/Users/chenxia/Documents/MATLAB/Project_class_design/交通信息检测database.mat')
% gps_[date]是104路运行数据，Matlab.table
% vid - 车牌号 --数值型
% time，date - 时间（YYYY-MM-DD HH-mm-SS），日期（YYYY-MM-DD）
% lon，lat--经纬度
% direction -- 0上行，1下行
% nidx -- 周转记录，完成一次上行下行++
% deadheading -- 文本，标记是否空驶

% map_upstream\map_downstream 是104上下行数据 ，Matlab.table
% LON，LAT --经纬度
% NAME --文本
% TYPE -- 数值，该点的类型

% timetable_[date]_up/down 某天该线路的上下行时刻表
% VarName1～VarName4：分类变量：线路名称、车牌、起点、终点
% VarName5：计划发车时间，数值型
% VarName6：应该到达时间，数值型
%%
R=6371.004;
%同时删除其中deadheading的情况
%gps_0906(gps_0906.deadheading~='',:)=[];
gps_0907(gps_0907.deadheading~='',:)=[];
gps_0908(gps_0908.deadheading~='',:)=[];
gps_0909(gps_0909.deadheading~='',:)=[];
gps_0910(gps_0910.deadheading~='',:)=[];

%给地图数据增加距离起始点的累积距离
map_downstream.DIS=zeros(size(map_downstream,1),1);
map_upstream.DIS=zeros(size(map_upstream,1),1);
for i =2:size(map_downstream,1)
    map_downstream.DIS(i)=map_downstream.DIS(i-1)+distance(map_downstream(i,:).LAT,map_downstream(i,:).LON,map_downstream(i-1,:).LAT,map_downstream(i-1,:).LON,R);
end

for i =2:size(map_upstream,1)
    map_upstream.DIS(i)=map_upstream.DIS(i-1)+distance(map_upstream(i,:).LAT,map_upstream(i,:).LON,map_upstream(i-1,:).LAT,map_upstream(i-1,:).LON,R);
end
upstation=map_upstream(map_upstream.TYPE==1,:);
downstation=map_downstream(map_downstream.TYPE==1,:);
%%  任务1 数据处理
% 【可视化】观察漂移现象
geoscatter(gps_0906.lat,gps_0906.lon,'b.')
hold on
geoplot(map_upstream.LAT,map_upstream.LON,'r','LineWidth',2)
title('嘉定公交104路09-06 GPS分布')
legend('原始GPS','路网数据')
%geoscatter(gps_0906.lat(gps_0906.nidx==0&gps_0906.direction==0),gps_0906.lon(gps_0906.nidx==0&gps_0906.direction==0))
%% 【可视化】地图数据
subplot(2,1,1)
geoplot(map_upstream.LAT,map_upstream.LON,'r','LineWidth',2)
legend('上行')
subplot(2,1,2)
geoplot(map_downstream.LAT,map_downstream.LON,'b','LineWidth',2)
legend('下行')
%% 【可视化】时刻表数据
temp_driver=unique(timetable_0906_up.VarName2);
for i=1:size(timetable_0906_up,1)
    [l,in]=ismember(timetable_0906_up.VarName2,temp_driver);
    plot([timetable_0906_up.VarName5(i),timetable_0906_up.VarName6(i)]*1440,[in,in])
    hold on
end

%% 选择一个0906的上行第一个班次的数据来作为离I数据进行分析
example_gps=gps_0906(gps_0906.nidx==22&gps_0906.direction==0,:);
% 设计一个map——matching函数来作为地图匹配
% 输入：上行GPS、下行GPS、待匹配数据
% 输出：修改之后的待匹配数据表格
% 思路是针对上行（下行）的每一个点是匹配上行（或者下行）时刻表中的数据
% 匹配是将时刻表路网数据看成是许多路单数据组成的，计算待匹配点到各路段所在直线的最短距离和投影的点
% 判断投影点是否在线段上
% 找到所有具有最短距离同时投影点在路段上的GPS，选择最短距离中最短的点作为该点在路段的投影点
% 如果投影的最短距离中最小值依旧大于10m，认为该路段漂移现象较为严重，因此可以舍去
[dis,targets_new]=Map_matching (map_upstream,map_downstream,example_gps);
% 上述返回
% newGPS是对应的车辆的GPS数据
% dis是原始点对应投射点的距离
% targets_news是删除对应点，和修改GPS之后的车辆行程过程的table 数据

% 下面计算车辆行驶的累积距离
targets_new=Spatial_correct(targets_new);
figure()
geoplot(targets_new.lat,targets_new.lon)
%%
% 举例子
% % % % % for i=1:3
% % % % %     example_gps=gps_0906(gps_0906.nidx==i&gps_0906.direction==1,:);
% % % % %     [dis,targets_new]=Map_matching (map_upstream,map_downstream,example_gps);
% % % % %     targets_new2=Spatial_correct(targets_new);
% % % % %     plot(targets_new2.time,targets_new2.dis_sum)
% % % % %     % Spatial_plot(targets_new,upstation,downstation) 
% % % % %     hold on
% % % % % end
%% 这部分是数据处理的主函数，运行时间较长，生成的数据已经在.mat中
%后面三个部分都整合到Aid-main函数中
%  运行下列程序之后，保存所有数据到文件为map_matched_database.mat
% 后续运行程序中不需要再重新调整
% new0开头表示经过第一次地图匹配的结果；增加blat、blon相未知，GPS修改，error表示错误
% new表示经过第一次时空修正之后的结果，对异常数据进行剔除
% final表示该数据的第一个数据为出站数据、第二个数据为进站数据，同时中间站点的站内时间为该站的编号，在路上的标记为0
% 之后运行可以直接从part02开始
[new0_gps_0906,new_gps_0906,final_gps_0906]=Aid_main(gps_0906,upstation,downstation,map_downstream,map_upstream);
%%
[new0_gps_0907,new_gps_0907,final_gps_0907]=Aid_main(gps_0907,upstation,downstation,map_downstream,map_upstream);
%%
[new0_gps_0908,new_gps_0908,final_gps_0908]=Aid_main(gps_0908,upstation,downstation,map_downstream,map_upstream);
%%
[new0_gps_0909,new_gps_0909,final_gps_0909]=Aid_main(gps_0909,upstation,downstation,map_downstream,map_upstream);
%%
[new0_gps_0910,new_gps_0910,final_gps_0910]=Aid_main(gps_0910,upstation,downstation,map_downstream,map_upstream);

%% 【可视化】匹配之后的点和路网数据
geoscatter(final_gps_0906.lat(final_gps_0906.error==0),final_gps_0906.lon(final_gps_0906.error==0),'b.')
hold on
geoplot(map_upstream.LAT,map_upstream.LON,'r','LineWidth',1)
geoplot(map_downstream.LAT,map_downstream.LON,'r','LineWidth',1)
title('嘉定公交104路09-06 GPS地图匹配之后分布')
legend('地图匹配之后GPS','路网数据（上下行')
hold off
%%
% 修正数据漂移--地图匹配map- matching
% 新的地图数据放在new0-gps-0906，新加blat、blon和error
% [part of Aid——main（）]
% % % % % % new0_gps_0906=table;
% % % % % % for i=1:max(gps_0906.nidx)
% % % % % %     for j=1:2
% % % % % %         example_gps=gps_0906(gps_0906.nidx==i&gps_0906.direction==j-1,:);
% % % % % %         % 提取对应的i班次的j- pattern的车辆的GPS数据
% % % % % %         [dis,targets_new]=Map_matching (map_upstream,map_downstream,example_gps);
% % % % % %         % map-match返回对应的点与匹配点的距离
% % % % % %         new0_gps_0906=[new0_gps_0906;targets_new];
% % % % % %         % 依次保存
% % % % % %         plot(targets_new.time,targets_new.dis_sum)
% % % % % %         % Spatial_plot(targets_new,upstation,downstation) 
% % % % % %         hold on
% % % % % %     end
% % % % % % end
%%
% 修正数据漂移--二次修正、时空轨迹数据的转换、数据剔除和修复
% 修正数据并保存在new-gps-0906
% [part of Aid——main（）]
% % % % % % new_gps_0906=table;
% % % % % % for i=1:max(gps_0906.nidx)
% % % % % %     for j=1:2
% % % % % %         example_gps=new0_gps_0906(new0_gps_0906.nidx==i&new0_gps_0906.direction==j-1,:);
% % % % % %         targets_new2=Spatial_correct(example_gps);
% % % % % %         new_gps_0906=[new_gps_0906;targets_new2];
% % % % % %         if sum(targets_new2.error)==0
% % % % % %             plot(targets_new2.time,targets_new2.dis_sum)
% % % % % %         end
% % % % % %         hold on
% % % % % %     end
% % % % % % end

%%
% 补充进站或者出站的信息，绘制出时空轨迹图
% 将完整的数据保存在final_gps_0906中
% [part of Aid——main（）]
% % % % % % final_gps_0906=table;
% % % % % % for i=1:max(gps_0906.nidx)
% % % % % %     for j=1:2
% % % % % %         example_gps=new_gps_0906(new_gps_0906.nidx==i&new_gps_0906.direction==j-1,:);
% % % % % %         targets_new3=Station_time(example_gps,upstation,downstation);  
% % % % % %         final_gps_0906=[final_gps_0906;targets_new3];
% % % % % %         if sum(targets_new3.error)==0
% % % % % %             if size(targets_new3,1)<10
% % % % % %             else
% % % % % %                 targets_new3(end,:).dis_sum
% % % % % %                 plot(targets_new3.time,targets_new3.dis_sum)
% % % % % %                 hold on
% % % % % %             end
% % % % % %         end
% % % % % %     end
% % % % % % end


%% 【可视化】错误数据
geoscatter(gps_0906.lat(gps_0906.nidx==5&gps_0906.direction==0),gps_0906.lon(gps_0906.nidx==5&gps_0906.direction==0))
title('嘉定104错误轨迹数据：0906-nidx=5-direction=0')
%% 【可视化】仅地图匹配之后的时空轨迹图
for i=1:max(new0_gps_0906.nidx)
    temp_gps=new0_gps_0906(new0_gps_0906.nidx==i&new0_gps_0906.direction==1,:);
    if sum(temp_gps.error)==0
        % 无错
            if size(temp_gps,1)<10
                % 非空
            else
                plot(temp_gps.time,temp_gps.dis_sum)
                title('嘉定104路地图匹配--下行时空轨迹图','LineWidth',2)
                xlabel('时间Time')
                ylabel('累积距离Dis\_sum（km）')
                hold on
            end
    end
end

%% 【可视化】down时空轨迹图
for i=1:max(final_gps_0907.nidx)
    temp_gps=final_gps_0907(final_gps_0907.nidx==i&final_gps_0907.direction==1,:);
    if sum(temp_gps.error)==0
        % 无错
            if size(temp_gps,1)<10
                % 非空
            else
                plot(temp_gps.time,temp_gps.dis_sum)
                title('嘉定104路\_09月07日\_处理之后下行时空轨迹图','LineWidth',2)
                xlabel('时间Time')
                ylabel('累积距离Dis\_sum（km）')
                hold on
            end
    end
end
%% 【可视化】up时空轨迹图
for i=1:max(final_gps_0907.nidx)
    temp_gps=final_gps_0907(final_gps_0907.nidx==i&final_gps_0907.direction==0,:);
    if sum(temp_gps.error)==0
        % 无错
            if size(temp_gps,1)<10
                % 非空
            else
                plot(temp_gps.time,temp_gps.dis_sum)
                title('嘉定104路\_09月07日\_处理之后上行时空轨迹图','LineWidth',2)
                xlabel('时间Time')
                ylabel('累积距离Dis\_sum（km）')
                hold on
            end
    end
end
%% 车辆使用情况
driver=unique(final_gps_0906.vid);
for i=1:max(final_gps_0906.nidx)
    for j=1:2
        temp_gps=final_gps_0906(final_gps_0906.nidx==i&final_gps_0906.direction==j-1,:);
        if sum(temp_gps.error)==0
            % 无错
                if size(temp_gps,1)<10
                    % 非空
                else
                    if j==1
                        [logic,index]=ismember(temp_gps.vid,driver);
                        plot(temp_gps.time,index,'r','LineWidth',4)
                        hold on
                    else
                        [logic,index]=ismember(temp_gps.vid,driver);
                        plot(temp_gps.time,index,'b','LineWidth',4)
                        hold on
                    end
                end
        end
    end
end
title('嘉定104路09月06日车辆使用情况图')
legend('上行','下行')
%% part02- 线路运行指标；准点率、时刻表偏差、发车间隔分析、运行时间分析、layover时间分析
% 准点率计算
% rate每一行表示每天，列：上行准点率、上行早高峰、下行早高峰、下行准点率、下行早高峰、下行晚高峰
% runtime_array_date_pattern：表示date的班次上行pattern（或者下行）的：发车时间、到达时间、发车偏差、到达偏差
% runtime_driver_date:表示包含driver在date中（pattern)的发车时间Var1、到达时间Var2,路牌driver、上下行区别pattern
rate=zeros(4,6);
[runtime_array_0906_up,runtime_array_0906_down,rate(1,:),runtime_driver_0906]=Line_operation(final_gps_0906,timetable_0906_up,timetable_0906_down);
[runtime_array_0907_up,runtime_array_0907_down,rate(2,:),runtime_driver_0907]=Line_operation(final_gps_0907,timetable_0907_up,timetable_0907_down);
[runtime_array_0908_up,runtime_array_0908_down,rate(3,:),runtime_driver_0908]=Line_operation(final_gps_0908,timetable_0908_up,timetable_0908_down);
[runtime_array_0909_up,runtime_array_0909_down,rate(4,:),runtime_driver_0909]=Line_operation(final_gps_0909,timetable_0909_up,timetable_0909_down);
[runtime_array_0910_up,runtime_array_0910_down,rate(5,:),runtime_driver_0910]=Line_operation(final_gps_0910,timetable_0910_up,timetable_0910_down);
bar(rate')
colormap('winter')
xticklabels({'上行准点率','上行早高峰','上行晚高峰','下行准点率','下行早高峰','下行晚高峰'})
legend('09-06','09-07','09-08','09-09','09-10')
title('不同天不同准点率的对比')
%% 【可视化】选择最严重的0907分析该天出发/到达时刻表的偏差情况
subplot(2,2,1)
bar(runtime_array_0906_up(:,3)*1440)
ylim([-10,30])
subplot(2,2,2)
bar(runtime_array_0906_up(:,4)*1440)
ylim([-10,30])
subplot(2,2,3)
bar(runtime_array_0906_down(:,3)*1440)
ylim([-10,30])
subplot(2,2,4)
bar(runtime_array_0906_down(:,4)*1440)
ylim([-10,30])
%% 【可视化】发车间隔--包含有error的数据,行发车间隔--包含有error的数据
diff_time_down=zeros(64,5);
temp_pattern=runtime_driver_0906(runtime_driver_0906.pattern==1,:);
diff_time_down(1:size(temp_pattern,1)-1,1)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0907(runtime_driver_0907.pattern==1,:);
diff_time_down(1:size(temp_pattern,1)-1,2)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0908(runtime_driver_0908.pattern==1,:);
diff_time_down(1:size(temp_pattern,1)-1,3)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0909(runtime_driver_0909.pattern==1,:);
diff_time_down(1:size(temp_pattern,1)-1,4)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0910(runtime_driver_0910.pattern==1,:);
diff_time_down(1:size(temp_pattern,1)-1,5)=diff(temp_pattern.Var1)*1440;
diff_time_down(diff_time_down>50)=20;
diff_time_down(diff_time_down<3)=15;
subplot(2,1,2)
plot((sum(diff_time_down,2)-max(diff_time_down')'-min(diff_time_down')')./(sum(diff_time_down~=0,2)-2))
ylabel('下行发车时间间隔（min）')
xlabel('班次')

diff_time_up=zeros(64,5);
temp_pattern=runtime_driver_0906(runtime_driver_0906.pattern==0,:);
diff_time_up(1:size(temp_pattern,1)-1,1)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0907(runtime_driver_0907.pattern==0,:);
diff_time_up(1:size(temp_pattern,1)-1,2)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0908(runtime_driver_0908.pattern==0,:);
diff_time_up(1:size(temp_pattern,1)-1,3)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0909(runtime_driver_0909.pattern==0,:);
diff_time_up(1:size(temp_pattern,1)-1,4)=diff(temp_pattern.Var1)*1440;
temp_pattern=runtime_driver_0910(runtime_driver_0910.pattern==0,:);
diff_time_up(1:size(temp_pattern,1)-1,5)=diff(temp_pattern.Var1)*1440;
diff_time_up(diff_time_up>50)=20;
diff_time_up(diff_time_up<3)=15;
subplot(2,1,1)
plot((sum(diff_time_up,2)-max(diff_time_up')'-min(diff_time_up')')./(sum(diff_time_up~=0,2)-2))
ylabel('上行发车时间间隔（min）')
xlabel('班次')

%% 【可视化】运营时间分析上行--理论上没error的数据
runway_time_up=zeros(64,5);
runway_time_up(1:size(runtime_array_0906_up,1),1)=runtime_array_0906_up(:,2)-runtime_array_0906_up(:,1);
runway_time_up(1:size(runtime_array_0907_up,1),2)=runtime_array_0907_up(:,2)-runtime_array_0907_up(:,1);
runway_time_up(1:size(runtime_array_0908_up,1),3)=runtime_array_0908_up(:,2)-runtime_array_0908_up(:,1);
runway_time_up(1:size(runtime_array_0909_up,1),4)=runtime_array_0909_up(:,2)-runtime_array_0909_up(:,1);
runway_time_up(1:size(runtime_array_0910_up,1),5)=runtime_array_0910_up(:,2)-runtime_array_0910_up(:,1);
runway_time_up=runway_time_up*1440;
%对于每一行的最大值和最小值进行删除，因为数据处理错误的方式，将异常数据给重新剔除,同时计算0。85分位数
for i=1:size(runway_time_up)
    runway_time_up(i,runway_time_up(i,:)==max(runway_time_up(i,:)))=mean(runway_time_up(i,:));
end
subplot(2,1,1)
hold on
scatter([1:60],runway_time_up(1:60,1),'k.','LineWidth',2)
scatter([1:60],runway_time_up(1:60,2),'k.','LineWidth',2)
scatter([1:60],runway_time_up(1:60,3),'k.','LineWidth',2)
scatter([1:60],runway_time_up(1:60,4),'k.','LineWidth',2)
scatter([1:60],runway_time_up(1:60,5),'k.','LineWidth',2)
plot(prctile(runway_time_up(1:end-4,:),85,2),'r','LineWidth',2)
plot((timetable_0906_up.VarName6(1:60)-timetable_0906_up.VarName5(1:60))*1440,'b','LineWidth',2)
legend('09-06','09-07','09-08','09-09','09-10','85%运营时间','时刻表计划时间')
xlabel('班次')
ylabel('上行运营时间')
ylim([30,90])
hold off
subplot(2,1,2)
runway_time_down=zeros(64,5);
runway_time_down(1:size(runtime_array_0906_down,1),1)=runtime_array_0906_down(:,2)-runtime_array_0906_down(:,1);
runway_time_down(1:size(runtime_array_0907_down,1),2)=runtime_array_0907_down(:,2)-runtime_array_0907_down(:,1);
runway_time_down(1:size(runtime_array_0908_down,1),3)=runtime_array_0908_down(:,2)-runtime_array_0908_down(:,1);
runway_time_down(1:size(runtime_array_0909_down,1),4)=runtime_array_0909_down(:,2)-runtime_array_0909_down(:,1);
runway_time_down(1:size(runtime_array_0910_down,1),5)=runtime_array_0910_down(:,2)-runtime_array_0910_down(:,1);
runway_time_down=runway_time_down*1440;
for i=1:size(runway_time_down)
    runway_time_down(i,runway_time_down(i,:)==max(runway_time_down(i,:)))=mean(runway_time_down(i,:));
end
scatter([1:60],runway_time_down(1:60,1),'k.')
hold on
scatter([1:60],runway_time_down(1:60,2),'k.')
scatter([1:60],runway_time_down(1:60,3),'k.')
scatter([1:60],runway_time_down(1:60,4),'k.')
scatter([1:60],runway_time_down(1:60,5),'k.')
plot(prctile(runway_time_down(1:end-4,:),85,2),'r','LineWidth',2)
plot((timetable_0906_down.VarName6(4:63)-timetable_0906_down.VarName5(4:63))*1440,'b','LineWidth',2)
legend('09-06','09-07','09-08','09-09','09-10','85%运营时间','时刻表计划时间')
xlabel('班次')
ylabel('下行运营时间')
ylim([30,90])
hold off
%% 【可视化】layover-up -down
layover_0906_main=[];
layover_0906_aid=[];
% 第一行计算终点时间1：edn-1，第二行是休息时间2：end-1：end-1，driver还是那个driver求对应driver就行
% 时间是相同计算，但是pattern是0的时候为主战，pattern为0的时候为负站
for i=1:size(driver,1)
    temp_one_driver=runtime_driver_0906(runtime_driver_0906.driver==driver(i),:);
    for j =1:size(temp_one_driver)-1
        temp_layover=[temp_one_driver.Var2(j),(temp_one_driver.Var1(j+1)-temp_one_driver.Var2(j))*1440,i]
        if temp_one_driver.pattern(j)==0&&temp_one_driver.pattern(j+1)==1
            % 上行终点站在副站
            layover_0906_aid=[layover_0906_aid;temp_layover];
        else
            if temp_one_driver.pattern(j)==1&&temp_one_driver.pattern(j+1)==0
            % 下行终点站在主站
                    layover_0906_main=[layover_0906_main;temp_layover];
            end
        end
        
    end
end
subplot(2,1,1)
bubblechart(layover_0906_main(:,1),layover_0906_main(:,3),layover_0906_main(:,2),layover_0906_main(:,2),'MarkerFaceAlpha',0.20)

title('主站layover时间变化（09-06）')
yticks([1:1:13])
yticklabels({'沪-9359D','沪-9169D','沪-8706D','沪-3593','沪-1976D','沪-1880D','沪-1722D','沪-1339D','沪-1202D','沪-577D','沪-576D','沪7360D','沪7695D'})
xticks([0:3/12:1])
xticklabels({'0:00','6:00','12:00','18:00','24:00'})
subplot(2,1,2)
bubblechart(layover_0906_aid(:,1),layover_0906_aid(:,3),layover_0906_aid(:,2),layover_0906_aid(:,2),'MarkerFaceAlpha',0.20)
title('副站layover时间变化（09-06）')
yticks([1:1:13])
yticklabels({'沪-9359D','沪-9169D','沪-8706D','沪-3593','沪-1976D','沪-1880D','沪-1722D','沪-1339D','沪-1202D','沪-577D','沪-576D','沪7360D','沪7695D'})
xticks([0:3/12:1])
xticklabels({'0:00','6:00','12:00','18:00','24:00'})

%% 【可视化】站点分析

boxplot(abs(layover_0906_main(:,2)),categorical(layover_0906_main(:,3)))
title('嘉定公交104路主站司机休息时间分布')
xlabel('司机编号')
ylabel('休息时间min')
ylim([0,300])
%%
%[part of line-operation]
% % % % % real_time_down=[];
% % % % % real_time_up=[];
% % % % % for i=1:max(final_gps_0906.nidx)
% % % % %     for j=1:2
% % % % %         temp_gps=final_gps_0906(final_gps_0906.nidx==i&final_gps_0906.direction==j-1,:);
% % % % %            if sum(temp_gps.error)>0.1*size(temp_gps,1)
% % % % %             % 无错
% % % % %            else
% % % % %             if size(temp_gps,1)<1
% % % % %                 %非空
% % % % %             else
% % % % %                 if j==1
% % % % %                     % 上行
% % % % %                     start=datevec(temp_gps(1,:).time);
% % % % %                     start_time=start(4)/24+start(5)/1440+start(6)/(1440*60);
% % % % %                     End=datevec(temp_gps(end,:).time);
% % % % %                     End_time=End(4)/24+End(5)/1440+End(6)/(1440*60);
% % % % %                     real_time_up=[real_time_up;[start_time,End_time]];
% % % % %                 else
% % % % %                     % 下行
% % % % %                     start=datevec(temp_gps(1,:).time);
% % % % %                     start_time=start(4)/24+start(5)/1440+start(6)/(1440*60);
% % % % %                     End=datevec(temp_gps(end,:).time);
% % % % %                     End_time=End(4)/24+End(5)/1440+End(6)/(1440*60);
% % % % %                     real_time_down=[real_time_down;[start_time,End_time]];
% % % % %                 end
% % % % %             end
% % % % %            end
% % % % %       
% % % % %         
% % % % %     end
% % % % % end
% % % % % real_time_up=sortrows(real_time_up,1);
% % % % % real_time_down=sortrows(real_time_down,1);
%%
%[part of line-operation]
% % % % % real_time_up=[real_time_up,zeros(size(real_time_up,1),2)];
% % % % % for i =1:size(real_time_up)
% % % % %     delta=real_time_up(i,1)-timetable_0906_up.VarName5;
% % % % %     [l,index]=ismember(min(abs(delta)),abs(delta));
% % % % %     real_time_up(i,3)=delta(index);
% % % % %     real_time_up(i,4)=real_time_up(i,2)-timetable_0906_up.VarName5(index);
% % % % %     % 都是按照实际时间-理论时间
% % % % % end
%%
%[part of line-operation]
%第三行是真实数据的差值；第四行是到达时间的差值
% % % % % temp_rate=sum((real_time_up(:,3)<2/1440)+(real_time_up(:,3)>-1/1440)==2)/size(real_time_up,1)
% % % % % real_time_up_cut=real_time_up(real_time_up(:,1)>7/24&real_time_up(:,1)<9.5/24,:);
% % % % % temp_rate_morning=sum((real_time_up_cut(:,3)<2/1440)+(real_time_up_cut(:,3)>-1/1440)==2)/size(real_time_up_cut,1)
% % % % % real_time_up_cu=real_time_up(real_time_up(:,1)>16.5/24&real_time_up(:,1)<19/24,:);
% % % % % temp_rate_morning=sum((real_time_up_cu(:,3)<2/1440)+(real_time_up_cu(:,3)>-1/1440)==2)/size(real_time_up_cu,1)
%%
% 公交路段运行情况分析【1116】
% 4。1 路段运营时间及延误分析，选择一天，绘制该天上下行早晚高峰时督办延误情况，并在地图上标记出来
% 计算出路段的运行时间，设计一个表示，计算每一个路段n--n+1的时间，每个班次的像里面填充数据
% 4。2 计算站点平均停靠时间，和上面相似，只是从路段时间转换到站点时间
% 4。3 同一个站点的时间分析
% 4。4 乘客延误分析，在3的基础上计算公式应该还可以

%% 路段运营时间及延误
% 先匹配station
% 注意使用后赋值
% % % % % % final_gps_0908_temp=table;
% % % % % % for i=1:max(final_gps_0908.nidx)
% % % % % %     for j=1:2
% % % % % %             temp_gps=final_gps_0908(final_gps_0908.nidx==i&final_gps_0908.direction==j-1,:);
% % % % % %             % 前面计算的station不对，重置
% % % % % %             temp_gps.station=zeros(size(temp_gps,1),1);
% % % % % %             if sum(temp_gps.error)==0
% % % % % %                 % 无错
% % % % % %                     if size(temp_gps,1)<10
% % % % % %                         % 非空
% % % % % %                     else
% % % % % %                         % map_stream中包含对应站点LAT、LON和累积距离，可以根据累积距离来推断出车辆在该站点的理论时间
% % % % % %                         if j==1
% % % % % %                             % 上行
% % % % % % 、                           for k=1:size(temp_gps,1)
% % % % % %                                 dis_delta=temp_gps.dis_sum(k)-upstation.DIS;
% % % % % %                                 % 如果距离差值为30认为已经进站
% % % % % %                                 if min(abs(dis_delta))<0.03
% % % % % %                                     [l,index]=ismember(min(abs(dis_delta)),abs(dis_delta));
% % % % % %                                     temp_gps.station(k)=index;
% % % % % %                                 end
% % % % % %                             end
% % % % % %                             unique(temp_gps.station)
% % % % % %                         else
% % % % % %                            % 下行     
% % % % % %                            
% % % % % %                            for k=1:size(temp_gps,1)
% % % % % %                                dis_delta=temp_gps.dis_sum(k)-downstation.DIS;
% % % % % %                                 
% % % % % %                                % 如果距离差值为30认为已经进站
% % % % % %                                if min(abs(dis_delta))<0.03
% % % % % %                                    [l,index]=ismember(min(abs(dis_delta)),abs(dis_delta));
% % % % % %                                    temp_gps.station(k)=index;
% % % % % %                                end
% % % % % %                            end
% % % % % %                            
% % % % % %                     
% % % % % %                         end
% % % % % %                    end
% % % % % %             end
% % % % % %             final_gps_0906_temp=[final_gps_0906_temp;temp_gps];
% % % % % %     end
% % % % % % end
% % % % % % final_gps_0908=final_gps_0906_temp;
%% 从已经填补好station的数据中获得每天每个班次进入该路段的时间
%  in或者out是针对路段来说的，因此这四个数据在相对应的行上面的针对同一个路段来说的
% 计算站点时间的时候需要错位相减
upstation_time_in=[];
downstation_time_in=[];
upstation_time_out=[];
downstation_time_out=[];
for i=1:max(final_gps_0907.nidx)
    for j=1:2
            temp_gps=final_gps_0907(final_gps_0907.nidx==i&final_gps_0907.direction==j-1,:);
            % 提取单程轨迹信息
            if sum(temp_gps.error)==0
                % 无错
                    if size(temp_gps,1)<10
                        % 非空
                    else
                        % map_stream中包含对应站点LAT、LON和累积距离，可以根据累积距离来推断出车辆在该站点的理论时间
                        if j==1
                            % 上行                          
                            temp_station_time=zeros(size(upstation,1)-1,1);
                            temp_station_time_out=zeros(size(upstation,1)-1,1);
                            for k=1:(size(upstation,1)-1)
                                if k==1
                                    time_duration=datevec(temp_gps.time(1));
                                    temp_station_time(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24); 

                                else
                                    temp_station_time_gps=temp_gps.time(temp_gps.station==k);
                                    if size(temp_station_time_gps,1)~=0
                                       time_duration=datevec(temp_station_time_gps(end));
                                       temp_station_time(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24);
                                    end
                                end
                                if k==(size(upstation,1)-1)
                                    time_duration=datevec(temp_gps.time(end));
                                    temp_station_time_out(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24); 

                                else
                                    temp_station_time_gps=temp_gps.time(temp_gps.station==(k+1));
                                    if size(temp_station_time_gps,1)~=0
                                       time_duration=datevec(temp_station_time_gps(1));
                                       temp_station_time_out(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24);
                                    end
                                end
                                
                            end
                            upstation_time_in=[upstation_time_in,temp_station_time];
                            upstation_time_out=[upstation_time_out,temp_station_time_out];
                            

                         else
                            % 下行              
                            temp_gps.station
                            temp_station_time=zeros(size(downstation,1)-1,1);
                            temp_station_time_out=zeros(size(downstation,1)-1,1);
                            for k=1:(size(downstation,1)-1)
                                if k==1
                                    time_duration=datevec(temp_gps.time(1));
                                    temp_station_time(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24);
                                    
                                else
                                    temp_station_time_gps=temp_gps.time(temp_gps.station==k);
                                    if size(temp_station_time_gps,1)~=0
                                       time_duration=datevec(temp_station_time_gps(end));
                                       temp_station_time(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24);
                                    end
                                end
                                if k==(size(downstation,1)-1)
                                    time_duration=datevec(temp_gps.time(end));
                                    temp_station_time_out(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24); 

                                else
                                    temp_station_time_gps=temp_gps.time(temp_gps.station==(k+1));
                                    if size(temp_station_time_gps,1)~=0
                                       time_duration=datevec(temp_station_time_gps(1));
                                       temp_station_time_out(k)=time_duration(4)/24+time_duration(5)/(60*24)+time_duration(6)/(60*60*24);
                                    end
                                end
                                
                            end
                            downstation_time_in=[downstation_time_in,temp_station_time];
                            downstation_time_out=[downstation_time_out,temp_station_time_out];
                                
                                
                        end

                    end
             end
     end
end

%% 由于第一行、第二行肯定有数,修复函数
% [part of Road_operation]
% % % % % for i=1:size(upstation_time_in,2)
% % % % %     bus=upstation_time_in(:,i);
% % % % %     % 一个班次一个班次的调整
% % % % %     for j=2:length(bus)
% % % % %         % 这里假设前两个班次有数据，但是没有怎么办
% % % % %         if bus(j)==0
% % % % %             if j==length(bus)
% % % % %                 % 最后一位，后面肯定没有数了
% % % % %                 upstation_time_in(j,i)=upstation_time_in(j-1,i)+0.5*(upstation_time_in(j-1,i)-upstation_time_in(j-2,i));
% % % % %             else
% % % % %                 % 不是最后一位，后面有数字的情况和后面都是0的情况
% % % % %                 if sum(bus(j:end))==0
% % % % %                     % 后面的所有数字都是0的情况，说明没有一个可以差值的下标
% % % % %                     % 默认不可能在第一个后面都是0
% % % % %                      upstation_time_in(j,i)=upstation_time_in(j-1,i)+0.5*(upstation_time_in(j-1,i)-upstation_time_in(j-2,i));
% % % % % 
% % % % %                 else
% % % % %                     % 如果后面的数字并不都是0，说明第一个和最后一个之间可以寻找数字来进行线性插值
% % % % %                     for index=1:(length(bus)-j-1)
% % % % %                         % 判断目标数值的后面index位置是0
% % % % %                         if bus(j+index)~=0
% % % % %                             % 提取出来index
% % % % %                             break
% % % % %                         end
% % % % %                     end
% % % % %                     upstation_time_in(j:j+index,i)=upstation_time_in(j-1,i)+(1:index+1)*(upstation_time_in(j+index,i)-upstation_time_in(j-1,i))/(index+1);
% % % % %                 end
% % % % %             end
% % % % %         end
% % % % %     end
% % % % % end
% 进路段需要填 0
% 出路段需要填 1 
upstation_time_in=Road_operation(upstation_time_in,0);
upstation_time_out=Road_operation(upstation_time_out,1);
downstation_time_in=Road_operation(downstation_time_in,0);
downstation_time_out=Road_operation(downstation_time_out,1);
upstation_time_in=sortrows(upstation_time_in')';
upstation_time_out=sortrows(upstation_time_out')';
downstation_time_in=sortrows(downstation_time_in')';
downstation_time_out=sortrows(downstation_time_out')';
%%  4.1 路段运行时间
runtime_up=upstation_time_out-upstation_time_in;
runtime_all=prctile(abs(runtime_up),15,2)*1440;
temp_index_mor=(upstation_time_in(1,:)>7/24&upstation_time_in(1,:)<9.5/24);
runtime_morning=1440*sum((upstation_time_out(:,temp_index_mor)-upstation_time_in(:,temp_index_mor)),2);
temp_index_nig=(upstation_time_in(1,:)>16.5/24&upstation_time_in(1,:)<19/24);
runtime_night=1440*sum((upstation_time_out(:,temp_index_nig)-upstation_time_in(:,temp_index_nig)),2);
% 出站一场修复
runtime_morning(1)=10;
runtime_night(1)=10;
subplot(2,1,1)
hold on
yyaxis left
delay_rate=(runtime_morning-runtime_all*sum(temp_index_mor))./(runtime_all*sum(temp_index_mor));
ylabel('延误占比%')
bar(delay_rate)
xticks([1:1:23])
xticklabels(roadname)

yyaxis right
plot(runtime_morning,'Linewidth',4)

plot(runtime_all*sum(temp_index_mor),'Linewidth',4)
ylabel('运营时间min')
legend('延误占比','高峰运营时间','自由流运营时间')
hold off
subplot(2,1,2)
hold on
yyaxis left
delay_rate=(runtime_night-runtime_all*sum(temp_index_nig))./(runtime_all*sum(temp_index_nig));

bar(delay_rate)
ylabel('延误占比%')
xticks([1:1:23])
xticklabels(roadname)

yyaxis right
plot(runtime_night,'Linewidth',4)

plot(runtime_all*sum(temp_index_nig),'Linewidth',4)
legend('延误占比','高峰运营时间','自由流运营时间')
ylabel('运营时间min')
hold off
%% 【可视化】路段运行时间下行
runtime_down=downstation_time_out-downstation_time_in;
runtime_all=prctile(abs(runtime_down),30,2)*1440;
temp_index_mor=(downstation_time_in(1,:)>7/24&downstation_time_in(1,:)<9.5/24);
runtime_morning=1440*sum((downstation_time_out(:,temp_index_mor)-downstation_time_in(:,temp_index_mor)),2);
temp_index_nig=(downstation_time_in(1,:)>16.5/24&downstation_time_in(1,:)<19/24);
runtime_night=1440*sum((downstation_time_out(:,temp_index_nig)-downstation_time_in(:,temp_index_nig)),2);
% 出站一场修复
runtime_morning(1)=20;
runtime_night(1)=20;
subplot(2,1,1)
hold on
yyaxis left
delay_rate=(runtime_morning-runtime_all*sum(temp_index_mor))./(runtime_all*sum(temp_index_mor));
ylabel('延误占比%')
bar(delay_rate)
xticks([1:1:23])
xticklabels(roadname(end:-1:1))

yyaxis right
plot(runtime_morning,'Linewidth',4)

plot(runtime_all*sum(temp_index_mor),'Linewidth',4)
ylabel('运营时间min')
legend('延误占比','高峰运营时间','自由流运营时间')
hold off
subplot(2,1,2)
hold on
yyaxis left
delay_rate=(runtime_night-runtime_all*sum(temp_index_nig))./(runtime_all*sum(temp_index_nig));

bar(delay_rate)
ylabel('延误占比%')
xticks([1:1:23])
xticklabels(roadname(end:-1:1))

yyaxis right
plot(runtime_night,'Linewidth',4)

plot(runtime_all*sum(temp_index_nig),'Linewidth',4)
legend('延误占比','高峰运营时间','自由流运营时间')
ylabel('运营时间min')
hold off
%% 4.2 站点的平均停站时间

station_leave=abs(upstation_time_in(2:end,:)-upstation_time_out(1:end-1,:))*1440*60;
subplot(2,1,1)
bar(median(station_leave'))
xlabel('站点')
xticks([1:1:22])
xticklabels(upstation.NAME(2:end-1))
ylabel('停站时间中位数')
title('嘉定104路--0907--各站点停站时间中位数s（上行）')
station_leave=abs(downstation_time_in(2:end,:)-downstation_time_out(1:end-1,:))*1440*60;
subplot(2,1,2)
bar(median(station_leave'))
xlabel('站点')
xticks([1:1:22])
xticklabels(downstation.NAME(2:end-1))
ylabel('停站时间中位数')
title('嘉定104路--0907--各站点停站时间中位数s（下行）')
%% 20站点停站分析
subplot(2,1,1)
station_leave=abs(upstation_time_in(2:end,:)-upstation_time_out(1:end-1,:))*1440*60;
plot(station_leave(20,station_leave(20,:)<100&station_leave(20,:)>4))
xlabel('班次')


ylabel('停站时间s')
title('嘉定104路上行["曹安公路星华公路"]停站时间变化')

subplot(2,1,2)
station_leave=abs(downstation_time_in(2:end,:)-downstation_time_out(1:end-1,:))*1440*60;
plot(station_leave(2,station_leave(2,:)<100&station_leave(2,:)>4))
xlabel('班次')
ylabel('停站时间s')
title('嘉定104路下行["曹安公路星华公路"]停站时间变化')
%% 4.3 计算发车间隔时间
subplot(2,1,1)
h_station_up=diff(upstation_time_in')'*1440;
h_station_up(abs(h_station_up)>30)=20+0.1*h_station_up(abs(h_station_up)>30);
yyaxis left
boxplot(abs(h_station_up'),'label',upstation.NAME(1:23))
ylabel('站点车间时距（min）')
hold on
yyaxis right
plot(diff(upstation.DIS),'color',[0.8,0.8,0.8],'Linewidth',4)
xlabel('上行站点')
ylabel('路段距离')
title('嘉定104路--0907--上行站点车头时距')
subplot(2,1,2)
h_station_down=diff(downstation_time_in')'*1440;
h_station_down(abs(h_station_down)>30)=20+0.1*h_station_down(abs(h_station_down)>30);
boxplot(abs(h_station_down'),'label',downstation.NAME(1:23))
ylabel('站点车间时距（min）')
hold on
yyaxis right
plot(diff(downstation.DIS),'color',[0.8,0.8,0.8],'Linewidth',4)
xlabel('下行站点')
ylabel('路段距离')
title('嘉定104路--0907--下行站点车头时距')
%% 乘客延误分析
 e_upstation=0.5*mean(h_station_up,2).*(1+var(h_station_up,0,2)./mean(h_station_up,2).^2)
 e_downstation=0.5*mean(h_station_down,2).*(1+var(h_station_down,0,2)./mean(h_station_down,2).^2)
 subplot(2,1,1)
 plot(e_upstation,'Linewidth',3)
 ylim([5,13])
 hold on 
 plot(0.5*mean(h_station_up,2),'Linewidth',3)
 xlabel('站点')
 ylabel('时间min')
 title('嘉定104路--0907--上行乘客平均延误变化')
 legend('乘客平均等待时间','1/2发车间隔')
 hold off
  subplot(2,1,2)
 plot(e_downstation,'Linewidth',3)
 ylim([5,13])
 hold on 
 plot(0.5*mean(h_station_down,2),'Linewidth',3)
  xlabel('站点')
 ylabel('时间min')
 title('嘉定104路--0907--下行乘客平均延误变化')
  legend('乘客平均等待时间','1/2发车间隔')
 hold off
 
 %% 延误路段分析
 geoplot(map_upstreamCopy.LAT,map_upstreamCopy.LON,'Linewidth',2)
 hold on
 for i=1:max(map_upstreamCopy.Crowd)
 geoplot(map_upstreamCopy.LAT(map_upstreamCopy.Crowd==i),map_upstreamCopy.LON(map_upstreamCopy.Crowd==i),'Linewidth',4)

 end
  legend('线路','拥挤路段1','拥挤路段2','拥挤路段3','拥挤路段4')
  title('嘉定公交104路拥堵路段分析（09-07数据）')

%% 不敢丢的代码，可忽略
% % % % % %%
% % % % % for i=1:max(gps_0906.nidx)
% % % % %     for j=1:2
% % % % %        
% % % % %         example_gps=gps_0906(gps_0906.nidx==i&gps_0906.direction==j-1,:);
% % % % %         figure();
% % % % %         geoscatter(example_gps.lat,example_gps.lon);
% % % % %         
% % % % %     end
% % % % % end
% % % % % %%
% % % % % % 
% % % % % geoplot(map_upstream.LAT,map_upstream.LON)
% % % % % 
% % % % % for i =1:size(newGPS,1)
% % % % %     geoscatter(newGPS(1:i,1),newGPS(1:i,2)) 
% % % % %     hold on
% % % % %     pause(0.02)
% % % % % end
% % % % % 
% % % % % %%
% % % % % time=gps_0906.time(gps_0906.direction==0&gps_0906.nidx==1);
% % % % % plot(time,dist)
% % % % % %%
% % % % % geoscatter(des_s(1:10,1),des_s(1:10,2))
% % % % % hold on
% % % % % geoscatter(ori_s(1:11,1),ori_s(1:11,2))
% % % % % % 观察上行和下行中关键点的区别，所以在上面进行地图匹配的环节还是需要对不同的pattern的线路利用不同上行或者下行的地图来进行匹配
% % % % % % 那就是可以用一段一段来重新赋值的方式来进行更新
% % % % % 
% % % % % geoscatter(newGPS(:,1),newGPS(:,2))
% % % % % hold on
% % % % % geoplot(map_upstream.LAT,map_upstream.LON)
% % % % % %%
% % % % % d=zeros(size(map_upstream,1),1);
% % % % % % 计算所有点到原始的距离
% % % % % for i= 1:size(map_upstream,1)
% % % % %     d(i)=distance(newGPS(394,1),newGPS(394,2),map_upstream(i,:).LAT,map_upstream(i,:).LON);
% % % % % end
% % % % % min(d)
% % % % % 
% % % % % sum(targets_new.blat==upstation(3,:).LAT)
% % % % % 
% % % % % %%
% % % % % geoplot(gps_0906(gps_0906.nidx==5&gps_0906.direction==0,:).lat,gps_0906(gps_0906.nidx==5&gps_0906.direction==0,:).lon)
% % % % % 
% % % % % prctile([2,7,3],85,2)





