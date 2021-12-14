#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/22
# @Author  : chenxia
# @File    : py- standard.py

#%%
# 随机数random（）模块
import random
print(random.randrange(1,10,2))
print(random.randbytes(4))
random.choice(['luan','shanghai','hefei','hangzhou'])

#%%
#re

#%%
#datetime module
from datetime import timedelta
delta=timedelta(days=50,seconds=27,microseconds=10,milliseconds=2900,weeks=2)
print(delta.total_seconds())