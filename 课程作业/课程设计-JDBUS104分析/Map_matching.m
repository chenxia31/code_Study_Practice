function [dis,targets_new]=Map_matching (map_up,map_down,targets)
% input
% map_up表示上行路网数据
% map——down表示下行路网数据
% targets，是需要匹配的路网点的数据，targets为包含点所对应的table数据
% output:
% dis 表示匹配点到投影点的距离
% targets——new中GPS数据更新，同时计算每个点到起始点的距离以及基准点
% blat、blon表示基准的distance；sum_dis表示累积距离


% 设计一个map——matching函数来作为地图匹配
% 思路是针对上行（下行）的每一个点是匹配上行（或者下行）时刻表中的数据
% 匹配是将时刻表路网数据看成是许多路单数据组成的，计算待匹配点到各路段所在直线的最短距离和投影的点
% 判断投影点是否在线段上
% 找到所有具有最短距离同时投影点在路段上的GPS，选择最短距离中最短的点作为该点在路段的投影点
% 如果投影的最短距离中最小值依旧大于50m，认为该路段漂移现象较为严重，因此可以舍去

dis=zeros(size(targets,1),1);
R=6371.004;
targets_new=targets;
targets_new.blat=zeros(size(targets,1),1);
targets_new.blon=zeros(size(targets,1),1);
targets_new.dis_sum=zeros(size(targets,1),1);
targets_new.error=zeros(size(targets,1),1);


% 区分上下行对应的road——gps，同时将路网数据转换为起点ori和终点des数据
if targets.direction==0
    % 上行
    map=map_up;
    road_gps=[map_up.LAT,map_up.LON];
    ori_s=road_gps(1:length(road_gps)-1,:);
    des_s=road_gps(2:length(road_gps),:);

else
    % 下行
    map=map_down;
    road_gps=[map_down.LAT,map_down.LON];
    ori_s=road_gps(1:length(road_gps)-1,:);
    des_s=road_gps(2:length(road_gps),:);
end



for j=1:size(targets,1)
    target=targets(j,:);
    % temp_GPS和temp_dis用来记录路段和对应的路段的距离
    % 在每次GPS的投影中都会更新
    temp_GPS=zeros(length(ori_s),2);
    temp_dis=zeros(length(ori_s),1);
    temp_dis_pre=distance([target.lat,target.lon],road_gps,R);
    % 记录每个点到所有点的距离，如果许多点都超过一定数值，认为这是一个错误的班次数据，error=1
    
    for i =1:length(ori_s)
        % 这里转换为最基本的三角问题，就是计算路段垂直点和垂直坐标的问题
        % road是路段标准化之后的向量,路网数据中各路段的向量数据
        ori=ori_s(i,:);
        des=des_s(i,:);
        road=des-ori;
        road=road/norm(road);
        vec1=[target.lat,target.lon]-ori;
        temp_GPS(i,:)=ori+dot(vec1,road)*road;
        if dot(vec1,road)<0 || dot(vec1,road)>norm(des-ori)
            temp_dis(i)=-distance(temp_GPS(i,1),temp_GPS(i,2),target.lat,target.lon,R);
            % 在路段反方向延长线，或者路段正方向延长线;将距离设置成不可能的数字（比如负）
        else
            temp_dis(i)=distance(temp_GPS(i,1),temp_GPS(i,2),target.lat,target.lon,R);
        end
    end
    
    index=temp_dis>=0;
    % 选择其中大于0的点，
    if sum(index)==0
        % 如果没有大于等于0的点，或者说最短路径都大于50m，说明这个点漂移的太严重
        % 对于这种点是不是要删掉
        dis(j)=min(temp_dis);
        targets_new(j,:).lat=temp_GPS(temp_dis==dis(j),1);
        targets_new(j,:).lon=temp_GPS(temp_dis==dis(j),2);
        targets_new(j,:).blat=ori_s(temp_dis==dis(j),1);
        targets_new(j,:).blon=ori_s(temp_dis==dis(j),2);
        targets_new(j,:).dis_sum=map(((road_gps(:,1)==targets_new(j,:).blat)+(road_gps(:,2)==targets_new(j,:).blon))==2,:).DIS+distance(targets_new(j,:).blat,targets_new(j,:).blon,targets_new(j,:).lat,targets_new(j,:).lon,R);
        targets_new(j,:).error=1;
    else
        %正常情况下找到投影点在路段上，距离最短的点
        dis(j)=min(temp_dis(index));
        [value,index]=ismember(dis(j),temp_dis);
        targets_new(j,:).lat=temp_GPS(index,1);
        targets_new(j,:).lon=temp_GPS(index,2);
        targets_new(j,:).blat=ori_s(index,1);
        targets_new(j,:).blon=ori_s(index,2);
        % 计算每个点相对于该路段基本初始点的距离
        targets_new(j,:).dis_sum=map(((road_gps(:,1)==targets_new(j,:).blat)+(road_gps(:,2)==targets_new(j,:).blon))==2,:).DIS+distance(targets_new(j,:).blat,targets_new(j,:).blon,targets_new(j,:).lat,targets_new(j,:).lon,R);
        if min(temp_dis_pre)>1
            targets_new(j,:).error=1;
        end
    end
    % 如果distance过大的时候，需要删除对应的newGPS数据，以及
end

targets_new=targets_new(dis<0.1,:);
dis=dis(dis<0.1);


end