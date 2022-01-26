# -*- coding: utf-8 -*-
"""
Created on Sun Jun 13 23:01:43 2021

@author: 25396
"""

def speed_volume_occupancy_judge(speed,volume,occupancy):
    #对于同一路段的流密度进行分析，异常值和缺失值都设置为-1方便后面修改
#独立判断
    for spe in speed:
        if (spe<0) | (spe>84):
            spe=-1
    for vol in  volume:
        if (vol<0) | (vol>205):
            vol=-1
#联合判断
    logic_normal=(speed>0) & (volume>0) &(occupancy>0)&(occupancy<=0.8)
    logic_jam_none=(speed<5)&(volume<25)&(occupancy>0.8)
    logic_less=(speed>0) &(volume<25)&(occupancy==0)
    logic=logic_normal|logic_jam_none|logic_less
    print(logic)
    for i in range(len(speed)):
        if ~(logic[i]):
            speed[i]=-1
            volume[i]=-1
            occupancy[i]=-1
#有效车长判断   
    avel=1000*speed*occupancy/(12*volume)
    print(avel)
    for i in range(len(avel)):
        if (avel[i]<=1.5)|(avel[i]>22):
            speed[i]=-1
            volume[i]=-1
            occupancy[i]=-1
    return(speed,volume,occupancy)

t1,t2,t3=speed_volume_occupancy_judge(df_LoopDetector['road1_speed'],df_LoopDetector['road1_volume'],df_LoopDetector['road1_occ'])
