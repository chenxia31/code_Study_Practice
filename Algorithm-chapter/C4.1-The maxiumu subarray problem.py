#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/7/31
# @Author  : chenxia
# @File    : C4.1-The maximum subarray problem.py
from math import floor


def find_max_crossing_array(A, low, mid, high):
    max_left=max_right=mid
    upper=-1000
    left_sum = right_sum = upper
    sum = 0
    for i in range(mid, low - 1, -1):
        sum = sum + A[i]
        if sum > left_sum:
            left_sum = sum
            max_left = i
    sum = 0
    for j in range(mid + 1, high, 1):
        sum = sum + A[j]
        if sum > right_sum:
            right_sum = sum
            max_right = j
    return max_left, max_right, left_sum + right_sum


def find_maximum_array(A, low, high):
    if low == high:
        return low, high, A[low-1]
    else:
        mid = floor((low + high) / 2)
        (left_low, left_high, left_sum) = find_maximum_array(A, low, mid)
        (right_low, right_high, right_sum) = find_maximum_array(A, mid + 1, high)
        (cross_low, cross_high, cross_sum) = find_max_crossing_array(A, low, mid, high)
        if left_sum >= right_sum and left_sum >= cross_sum:
            return left_low, left_high, left_sum
        elif right_sum >= left_sum and right_sum >= cross_sum:
            return right_low, right_high, right_sum
        else:
            return cross_low, cross_high, cross_sum
A=[1,2]
l,r,sum_re=find_maximum_array(A, 0, len(A))
print(sum_re)
