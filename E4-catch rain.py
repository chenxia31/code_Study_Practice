#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/5
# @Author  : chenxia
# @File    : E4-catch rain.py
class Solution:
    def trap(height) -> int:
        before=[]
        after=[]
        att=[]
        before.append(height[0])
        after.append(height[-1])
        length=len(height)
        for i in range(1,length):
            before.append(max(before[-1],height[i]))
            after.append(max(after[-1],height[-i-1]))
        after.reverse()
        for i in range(length):
            att.append(min(before[i],after[i]))
        return sum(att)-sum(height)
print(Solution.trap([0,1,0,2,1,0,1,3,2,1,2,1]))