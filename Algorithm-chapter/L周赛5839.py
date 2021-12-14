#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/8
# @Author  : chenxia
# @File    : L周赛5839.py
from math import floor, ceil


def minStoneSum(piles,k):
    for i in range(k):
        max_list=max(piles)
        max_index=piles.index(max_list)
        piles[max_index]=ceil(max_list/2)
    return  sum(piles)

print(minStoneSum([5,4,9],2))
