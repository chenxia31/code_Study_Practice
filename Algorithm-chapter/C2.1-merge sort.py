#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/7/30
# @Author  : chenxia
# @File    : C2.1-merge sort.py
from math import floor


def merge_sort(A, p, r):
    if p < r:
        q = floor((p + r) / 2)
        merge_sort(A, p, q)
        merge_sort(A, q + 1, r)
        merge(A, p, q, r)
    return A


def merge(A, p, q, r):
    n1 = q - p + 1
    n2 = r - q
    L = []
    R = []
    ceiling = 10000
    for i in range(0, n1):
        L.append(A[p + i - 1])
    for j in range(0, n2):
        R.append(A[q + j])
    L.append(ceiling)
    R.append(ceiling)
    i = 0
    j = 0
    for k in range(p - 1, r):
        if L[i] <= R[j]:
            A[k] = L[i]
            i = i + 1
        else:
            A[k] = R[j]
            j = j + 1
    return A


print(merge_sort([1, 3, 4, 2, 3, 1], 1, 6))
