function[real_time_up,real_time_down,daterate,real_time_driver]=Line_operation(final_gps_date,timetable_date_up,timetable_date_down)
% 函数的功能主要是计算返回运行间隔和运行时间等信息
% output: 
% real_time_up/down array返回该天的上行（下行）班次的：实际出发时间、实际到达时间、出发偏差、到达偏差
% daterate: array返回改天的上行准点率；上行早高峰准点率；下行早高峰准点率；下行准点率；下行早高峰准点率；下行晚高峰准点率
% real_time_up_driver(down):table包含上下行司机的信息（driver_up），以及对应的班次发车时间和班次到达时间(Var1,Var2)

% 第一次写是按照0906的，所以这里依旧为0906
timetable_0906_up=timetable_date_up;
timetable_0906_down=timetable_date_down;
driver_up=[];
driver_down=[];
 real_time_up=[];
 real_time_down=[];
Var1=[];
Var2=[];
driver=[];
pattern=[];
for i=1:max(final_gps_date.nidx)
    for j=1:2
        temp_gps=final_gps_date(final_gps_date.nidx==i&final_gps_date.direction==j-1,:);
        %% 无论是否是错误数据都传递给table的绘制时间间隔
           if size(temp_gps,1)<1
           else
                S=datevec(temp_gps(1,:).time);
                S_time=S(4)/24+S(5)/1440+S(6)/(1440*60);
                E=datevec(temp_gps(end,:).time);
                E_time=E(4)/24+E(5)/1440+E(6)/(1440*60);
                if E_time-S_time<2*60/1440
                    Var1=[Var1;S_time];
                    Var2=[Var2;E_time];
                    driver=[driver;temp_gps(1,:).vid];
                    pattern=[pattern;j-1];
                end
           end
           %% 将所有正确数据传递给array类型
           if sum(temp_gps.error)>0.1*size(temp_gps,1)
            
           else
               % 无错
                if size(temp_gps,1)<1
                    %非空
                else
                    if j==1
                        % 上行
                        start=datevec(temp_gps(1,:).time);
                        start_time=start(4)/24+start(5)/1440+start(6)/(1440*60);
                        End=datevec(temp_gps(end,:).time);
                        End_time=End(4)/24+End(5)/1440+End(6)/(1440*60);
                        if End_time-start_time<2*60/1440
                            % 大于2h的认为是错误数据
                            real_time_up=[real_time_up;[start_time,End_time]];
                            driver_up=[driver_up;temp_gps(1,:).vid];
                        end
                    else
                        % 下行
                        start=datevec(temp_gps(1,:).time);
                        start_time=start(4)/24+start(5)/1440+start(6)/(1440*60);
                        End=datevec(temp_gps(end,:).time);
                        End_time=End(4)/24+End(5)/1440+End(6)/(1440*60);
                        if End_time-start_time<2*60/1440
                            % 大于2h的认为是错误数据
                            real_time_down=[real_time_down;[start_time,End_time]];
                            driver_down=[driver_down;temp_gps(1,:).vid];
                        end
                    end
                end
           end
      
        
    end
end

real_time_driver=table(Var1,Var2,driver,pattern);
real_time_driver=sortrows(real_time_driver,1);
real_time_up=sortrows(real_time_up,1);
real_time_down=sortrows(real_time_down,1);

real_time_up=[real_time_up,zeros(size(real_time_up,1),2)];
for i =1:size(real_time_up)
    delta=real_time_up(i,1)-timetable_0906_up.VarName5;
    [l,index]=ismember(min(abs(delta)),abs(delta));
    real_time_up(i,3)=delta(index);
    real_time_up(i,4)=real_time_up(i,2)-timetable_0906_up.VarName6(index);
    % 都是按照实际时间-理论时间
end
real_time_down=[real_time_down,zeros(size(real_time_down,1),2)];
for i =1:size(real_time_down)
    delta=real_time_down(i,1)-timetable_0906_down.VarName5;
    [l,index]=ismember(min(abs(delta)),abs(delta));
    real_time_down(i,3)=delta(index);
    real_time_down(i,4)=real_time_down(i,2)-timetable_0906_down.VarName6(index);
    % 都是按照实际时间-理论时间
end
daterate=zeros(1,6);
daterate(1)=sum((real_time_up(:,3)<2/1440)+(real_time_up(:,3)>-1/1440)==2)/size(real_time_up,1);
real_time_up_cut=real_time_up(real_time_up(:,1)>7/24&real_time_up(:,1)<9.5/24,:);
daterate(2)=sum((real_time_up_cut(:,3)<2/1440)+(real_time_up_cut(:,3)>-1/1440)==2)/size(real_time_up_cut,1);
real_time_up_cu=real_time_up(real_time_up(:,1)>16.5/24&real_time_up(:,1)<19/24,:);
daterate(3)=sum((real_time_up_cu(:,3)<2/1440)+(real_time_up_cu(:,3)>-1/1440)==2)/size(real_time_up_cu,1);

daterate(4)=sum((real_time_down(:,3)<2/1440)+(real_time_down(:,3)>-1/1440)==2)/size(real_time_down,1);
real_time_down_cut=real_time_down(real_time_down(:,1)>7/24&real_time_down(:,1)<9.5/24,:);
daterate(5)=sum((real_time_down_cut(:,3)<2/1440)+(real_time_down_cut(:,3)>-1/1440)==2)/size(real_time_down_cut,1);
real_time_down_cu=real_time_down(real_time_down(:,1)>16.5/24&real_time_down(:,1)<19/24,:);
daterate(6)=sum((real_time_down_cu(:,3)<2/1440)+(real_time_down_cu(:,3)>-1/1440)==2)/size(real_time_down_cu,1);

end