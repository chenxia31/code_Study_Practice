#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/5
# @Author  : chenxia
# @File    : E3-traiangle.py
triangle=[[2], [3, 4], [6, 5, 7], [4, 1, 8, 3]]
DP=[]
DP.append(triangle[0])
if len(triangle)>=1:
    for story in range(1, len(triangle)):
        temp=[]
        for i in range(0, len(triangle[story])):
            if i==0:
                temp.append(DP[story-1][0] + triangle[story][0])
            elif i==(len(triangle[story]) - 1):
                temp.append(DP[story-1][i-1] + triangle[story][i])
            else:
                temp.append(min(triangle[story][i] + DP[story - 1][i - 1], triangle[story][i] + DP[story - 1][i]))
        DP.append(temp)
min(DP[-1])