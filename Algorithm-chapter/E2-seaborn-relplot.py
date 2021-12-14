#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/3
# @Author  : chenxia
# @File    : E2-seaborn-relplot.py

import seaborn as sns
from matplotlib import pyplot as plt

tips = sns.load_dataset("tips")
print(tips.head())

sns.lmplot(data=tips,x='total_bill',y='tip',hue='sex')
plt.show()