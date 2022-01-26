function [targets_new]=Spatial_correct(targets)
% 对于单个班次的数据targets数据进行分析
% 实现二次修正和数据剔除和修复
% 保证数据一直是向前推进的

targets.dis_sum=sort(targets.dis_sum);%取巧，方便操作
index_delete=zeros(size(targets,1),1);
for i =2:size(targets,1)
    % 这里的判断条件应该是车速大于80或者负数
    delta_time=datenum(targets(i,:).time-targets(i-1,:).time)*1440;
    % delta_time的单位是min
    speed=(targets(i,:).dis_sum-targets(i-1,:).dis_sum)/(60*delta_time);
    if targets(i,:).dis_sum<targets(i-1,:).dis_sum || speed>80
        % 是利用删除的方式，还是利用线型差值的方式来，弥补过失
        index_delete(i)=1;
    end
end

targets_new=targets(index_delete==0,:);


% 根据index——delete中删除的数据过多而将该轨迹标记为错误
% 根据行驶距离没有超过3km的认定为错误数据
if sum(index_delete)>0.5*size(targets_new,1)
    targets_new.error=ones(size(targets_new,1),1);
end
if max(targets_new.dis_sum)-min(targets_new.dis_sum)<3
    targets_new.error=ones(size(targets_new,1),1);
end
% error为1表示错误，eeror为0表示正确

% [线性内插]在一个长时间段、存在GPS数据缺失，或者相邻两个匹配点之间的距离大于50m的情况进行线性内插作为数据补全
if size(targets_new,1)>2
    for i =2:size(targets_new,1)
        delta_time=datenum(targets_new(i,:).time-targets_new(i-1,:).time)*1440;
        if delta_time>0.5
            temp_n=ceil(delta_time/0.1);%以6s为时间间隔填充数据
            insert_index=i-1;
            insert_time=targets_new(insert_index,:).time+((1:temp_n)/temp_n)*datenum(targets_new(insert_index+1,:).time-targets_new(insert_index,:).time);
            insert_dis_sum=targets_new(insert_index,:).dis_sum+((1:temp_n)/temp_n)*(targets_new(insert_index+1,:).dis_sum-targets_new(insert_index,:).dis_sum);
            for j=1:temp_n-1
                insert_temp=targets_new(insert_index,:);
                insert_temp.time=insert_time(j);
                insert_temp.dis_sum=insert_dis_sum(j);
                targets_new=[targets_new(1:insert_index,:);insert_temp;targets_new(insert_index+1:end,:)];
                insert_index=insert_index+1;
                % 新插入行索引为insert_index+1
            end

        end 
    end
    for i =2:size(targets_new,1)
        delta_dis=targets_new(i,:).dis_sum-targets_new(i-1,:).dis_sum;
        if delta_dis>0.05
            temp_n=ceil(delta_dis/0.05);%以50m填充数据
            insert_index=i-1;
            insert_time=targets_new(insert_index,:).time+((1:temp_n)/temp_n)*datenum(targets_new(insert_index+1,:).time-targets_new(insert_index,:).time);
            insert_dis_sum=targets_new(insert_index,:).dis_sum+((1:temp_n)/temp_n)*(targets_new(insert_index+1,:).dis_sum-targets_new(insert_index,:).dis_sum);
            for j=1:temp_n-1
                insert_temp=targets_new(insert_index,:);
                insert_temp.time=insert_time(j);
                insert_temp.dis_sum=insert_dis_sum(j);
                targets_new=[targets_new(1:insert_index,:);insert_temp;targets_new(insert_index+1:end,:)];
                insert_index=insert_index+1;
                % 新插入行索引为insert_index+1
            end
        end
    end
end

% [确定进站和出站]确定车辆的进站数据数据或者出站数据

