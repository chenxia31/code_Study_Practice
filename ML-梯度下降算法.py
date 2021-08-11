#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/11
# @Author  : chenxia
# @File    : ML-梯度下降算法.py

#%%
# 首先用梯度下降算法来实现具体函数的极值求解
# 函数选取r = ((x1+x2-4)**2 + (2*x1+3*x2 - 7)**2 + (4*x1+x2-9)**2)*0.5
# 求导来实现对应的导数求解：
#     r1 = (x1+x2-4) + (2*x1+3*x2-7)*2 + (4*x1+x2-9)*4
#     r2 = (x1+x2-4) + (2*x1+3*x2-7)*3 + (4*x1+x2-9)
import numpy as np
from matplotlib import pyplot as plt
import time


def argminf(x1, x2):
    r = ((x1+x2-4)**2 + (2*x1+3*x2 - 7)**2 + (4*x1+x2-9)**2)*0.5
    return r

def deriv_x(x1, x2):
    r1 = (x1+x2-4) + (2*x1+3*x2-7)*2 + (4*x1+x2-9)*4
    r2 = (x1+x2-4) + (2*x1+3*x2-7)*3 + (4*x1+x2-9)
    return r1, r2

def gradient_descent(epoches,learning_rate):
    x1=0
    x2=0
    y1=argminf(x1,x2)
    for i in range(epoches):
        d1,d2=deriv_x(x1,x2)
        x1=x1-d1*learning_rate
        x2=x2-d2*learning_rate
        y2=argminf(x1,x2)
        ax.scatter(x1, x2, y2, color='r')
        print([x1,x2,y2])
        time.sleep(0.2)
        if y1 - y2 < 1e-6:
            return x1, x2, y2
        if y2 < y1:
            y1 = y2
    return [x1, x2, y2]



fig = plt.figure(figsize=(12, 8),facecolor='lightyellow')
ax = plt.axes(fc='whitesmoke',projection='3d' )
x = np.linspace(-9, 9, 1000)
y = np.linspace(-9, 9, 1000)
X, Y = np.meshgrid(x, y)
ax.plot_surface(X,Y,Z=argminf(X,Y),color='g',alpha=0.6)
x1,x2,y2=gradient_descent(1000,0.001)

plt.show()

