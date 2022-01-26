function[station_time_new]=Road_operation(station_time,pattern)
% 针对输入的进站数据或者出站数据进行矫正
% in 为 0
% out 为1
if pattern==1
    % 需要对矩阵进行反转
    upstation_time_in=station_time(end:-1:1,:);
else
    upstation_time_in=station_time;
end

for i=1:size(upstation_time_in,2)
    bus=upstation_time_in(:,i);
    % 一个班次一个班次的调整
    for j=2:length(bus)
        % 这里假设前两个班次有数据，但是没有怎么办
        if bus(j)==0
            if j==length(bus)
                % 最后一位，后面肯定没有数了
                upstation_time_in(j,i)=upstation_time_in(j-1,i)+0.5*(upstation_time_in(j-1,i)-upstation_time_in(j-2,i));
            else
                % 不是最后一位，后面有数字的情况和后面都是0的情况
                if sum(bus(j:end))==0
                    % 后面的所有数字都是0的情况，说明没有一个可以差值的下标
                    % 默认不可能在第一个后面都是0
                     upstation_time_in(j,i)=upstation_time_in(j-1,i)+0.5*(upstation_time_in(j-1,i)-upstation_time_in(j-2,i));

                else
                    % 如果后面的数字并不都是0，说明第一个和最后一个之间可以寻找数字来进行线性插值
                    for index=1:(length(bus)-j)
                        % 判断目标数值的后面index位置是0
                        if bus(j+index)~=0
                            % 提取出来index
                            break
                        end
                    end
                    index
                    upstation_time_in(j:j+index-1,i)=upstation_time_in(j-1,i)+(1:index)*(upstation_time_in(j+index,i)-upstation_time_in(j-1,i))/(index+1);
                    bus=upstation_time_in(:,i);
                end
            end
        end
    end
end

if pattern==1
    % 最后将矩阵重新反转回来
    station_time_new=upstation_time_in(end:-1:1,:);
else
    station_time_new=upstation_time_in
end
end