function [targets_new]=Station_time(targets,upstation,downstation)
% 设计思路是给targets——new设置一个表示站点的数据，数字0表示再路上，数字1，2，3表示在站点中
% 挑选合适的出站数据和进站数据
% 那么如何搜寻到该站点的出站时间和到站时间，搜索==station_name，该数组中的1为进站，end为出站
R=6371.004;
begin=0;
End=0;

%寻找出站
if size(targets,1)<10
         targets_new=targets;
        targets_new.station=zeros(size(targets_new,1),1);
else
    if (sum(targets.error)>0.5*size(targets,1))
        targets_new=targets;
        targets_new.station=zeros(size(targets_new,1),1);
    else
        if targets(1,:).direction==0
            % 车辆上行
            for i=1:size(targets,1)
                if distance(targets(i,:).lat,targets(i,:).lon,upstation(1,:).LAT,upstation(1,:).LON,R)>0.05
                    % 大于50m的条件
                    % 计算speed,delta_time为min，dis——sum单位为km
                    delta_time=datenum(targets(i+1,:).time-targets(i,:).time)*1440;
                    delta_dis_sum=(targets(i+1,:).dis_sum-targets(i,:).dis_sum);
                    speed=delta_dis_sum*60/delta_time;
                    if speed>25 || distance(targets(i,:).lat,targets(i,:).lon,upstation(1,:).LAT,upstation(1,:).LON,R)>0.2
                        begin=i;
                        break;
                    end
                end

            end
        else
             % 车辆下行
            for i=1:size(targets,1)
                if distance(targets(i,:).lat,targets(i,:).lon,downstation(1,:).LAT,downstation(1,:).LON,R)>0.05
                    % 大于50m的条件
                    % 计算speed,delta_time为min，dis——sum单位为km
                    delta_time=datenum(targets(i+1,:).time-targets(i,:).time)*1440;
                    delta_dis_sum=(targets(i+1,:).dis_sum-targets(i,:).dis_sum);
                    speed=delta_dis_sum*60/delta_time;
                    if speed>25|| distance(targets(i,:).lat,targets(i,:).lon,upstation(1,:).LAT,upstation(1,:).LON,R)>0.2
                        begin=i;
                        break;
                    end
                end

            end
        end

        %%寻找出站点
        if targets(1,:).direction==0
            % 车辆上行
            for i=(size(targets,1)-1):-1:1
                if distance(targets(i,:).lat,targets(i,:).lon,upstation(end,:).LAT,upstation(end,:).LON,R)>0.025
              
                  
                        End=i;
                        break;
                  

                end


            end
        else
        % 车辆下行
         for i=(size(targets,1)-1):-1:1
                if distance(targets(i,:).lat,targets(i,:).lon,downstation(end,:).LAT,downstation(end,:).LON,R)>0.025
    
                        End=i;
                        break;
             

                end   
         end
        end

        targets_new=targets(begin:End,:);
        targets_new.station=zeros(size(targets_new,1),1);

        % 寻找中间站点
        if targets_new(1,:).direction==0
            % 如果是上行
            for j=1:size(upstation,1)
                temp_distance=distance([upstation(j,:).LAT,upstation(j,:).LON],[targets_new.lat,targets_new.lon],R);
                targets_new.station(temp_distance<0.025)=j*ones(sum(temp_distance<0.025),1);  
            end

        else
            % 如果是下行
            for j=1:size(downstation,1)
                temp_distance=distance([downstation(j,:).LAT,downstation(j,:).LON],[targets_new.lat,targets_new.lon],R);
                targets_new.station(temp_distance<0.025)=j*ones(sum(temp_distance<0.025),1);  
            end
        end
    end
end
end
