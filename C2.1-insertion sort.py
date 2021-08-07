#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/7/29
# @Author  : chenxia
# @File    : C2.1-insertion sort.py
def insertion_sort(sorted_list):
    for j in range(1, len(sorted_list)):
        key = sorted_list[j]
        i = j - 1
        while i > -1 and sorted_list[i] > key:
            sorted_list[i + 1] = sorted_list[i]
            i = i - 1
        sorted_list[i + 1] = key
    return sorted_list


def searching_problem(target, search_list):
    result = 'NULL'
    for i in range(0, len(search_list)):
        if search_list[i] == target:
            result = i
    return result


a = [3, 11, 2, 1, 5]
print(insertion_sort(a))
print(searching_problem(11, a))
