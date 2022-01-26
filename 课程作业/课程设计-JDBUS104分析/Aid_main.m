function [new0_gps_0906,new_gps_0906,final_gps_0906]=Aid_main(gps_0906,upstation,downstation,map_downstream,map_upstream)
% input 输入该站点的GPS数据，upstation上行站点数据、downstation下行站点数据
% output，new0-gps-0906地图匹配后的数据；new-gps-0906经过数据修复剔除之后，final-gps-0906是最终的数据
new0_gps_0906=table;
for i=1:max(gps_0906.nidx)
    for j=1:2
        example_gps=gps_0906(gps_0906.nidx==i&gps_0906.direction==j-1,:);
        % 提取对应的i班次的j- pattern的车辆的GPS数据
        [dis,targets_new]=Map_matching (map_upstream,map_downstream,example_gps);
        % map-match返回对应的点与匹配点的距离
        new0_gps_0906=[new0_gps_0906;targets_new];
        % 依次保存

    end
end

%%
% 修正数据漂移--二次修正、时空轨迹数据的转换、数据剔除和修复
% 修正数据并保存在new-gps-0906
new_gps_0906=table;
for i=1:max(gps_0906.nidx)
    for j=1:2
        example_gps=new0_gps_0906(new0_gps_0906.nidx==i&new0_gps_0906.direction==j-1,:);
        targets_new2=Spatial_correct(example_gps);
        new_gps_0906=[new_gps_0906;targets_new2];
    end
end

final_gps_0906=table;
for i=1:max(gps_0906.nidx)
    for j=1:2
        example_gps=new_gps_0906(new_gps_0906.nidx==i&new_gps_0906.direction==j-1,:);
        targets_new3=Station_time(example_gps,upstation,downstation);  
        final_gps_0906=[final_gps_0906;targets_new3];

    end
end


final_gps_0906=table;
for i=1:max(gps_0906.nidx)
    for j=1:2
        example_gps=new_gps_0906(new_gps_0906.nidx==i&new_gps_0906.direction==j-1,:);
        targets_new3=Station_time(example_gps,upstation,downstation);  
        final_gps_0906=[final_gps_0906;targets_new3];

    end
end