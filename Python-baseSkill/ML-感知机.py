#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/9
# @Author  : chenxia
# @File    : ML-感知机.py
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd

# 原先尝试随机生成数据，来分类，但是失败
# positive = np.random.randint(0, 10, size=[50, 2])
# label_po=np.ones((50,1))
# negative= np.random.randint(-10, 0, size=[50, 2])
# label_ne=-np.ones((50,1))
# X=np.vstack((negative,positive))
# label=np.vstack((label_ne,label_po))
# sns.scatterplot(X[:, 0], X[:, 1],hue=label[:,0])
# plt.show()

data = pd.read_csv('../Algorithm-chapter/data.csv', header=None)
# 样本输入，维度（100，2）
X = data.iloc[:, :2].values
# 样本输出，维度（100，）
label = data.iloc[:, 2].values

# %%
# 可视化
plt.scatter(X[:, 0], X[:, 1], c=label + 1, cmap='coolwarm')
# plt.scatter(X[:50, 0], X[:50, 1], color=, marker='o', label='Positive')
# plt.scatter(X[50:, 0], X[50:, 1], color='red', marker='x', label='Negative')
# plt.xlabel('Feature 1')
# plt.ylabel('Feature 2')
# plt.legend(loc = 'upper left')
# plt.title('Original Data')
plt.show()

# %%
w = [0, 0]  # 初始化w参数
b = 0  # 初始化b参数


def update(xs, labels):
    global w, b
    w[0] += 1 * labels * xs[0]  # w的第一个分量更新
    w[1] += 1 * labels * xs[1]  # w的第二个分量更新
    b += 1 * labels
    print('w = ', w, 'b=', b)  # 打印出结果


def judge(xs, labels):  # 返回y = yi(w*x+b)的结果
    res = 0
    for i in range(len(xs)):
        res += xs[i] * w[i]  # 对应公式w*x
    res += b  # 对应公式w*x+b
    res *= labels  # 对应公式yi(w*x+b)
    return res


def check():  # 检查所有数据点是否分对了
    flag = False
    for xs, labels in zip(X, label):
        if judge(xs, labels) <= 0:  # 如果还有误分类点，那么就小于等于0
            flag = True
            update(xs, labels)  # 只要有一个点分错，我就更新
            xtemp = [3, 10]
            ytemp = [1, 1]
            for i in range(len(xtemp)):
                ytemp[i] = -(b + w[0] * xtemp[i]) / w[1]
            plt.scatter(X[:, 0], X[:, 1], c=label + 1, cmap='coolwarm')
            plt.plot(xtemp, ytemp)
            plt.show()
    return flag  # flag为False，说明没有分错的了


if __name__ == '__main__':
    flag = False
    for i in range(1000):
        if not check():  # 如果已经没有分错的话
            flag = True
            break
    if flag:
        print("在1000次以内全部分对了")
    else:
        print("很不幸，1000次迭代还是没有分对")
#%%

