#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/2
# @Author  : chenxia
# @File    : E1-iris.py
import pandas as pd
from matplotlib import pyplot as plt
from sklearn import datasets
import seaborn as sns

data = datasets.load_iris()

# %%
# 打印数据集现实
for k in data:
    print("#########\n##%s##\n#######\n" % k)
    print(data[k])

df=pd.DataFrame(data.data)
df.columns=data.feature_names
df['species']=[data['target_names'][x] for x in data.target]
print(df.head())

#%% 数据是否会受到极值、缺失值的影响
sns.pairplot(df,hue='species')

# %%
from sklearn.decomposition import PCA
pca=PCA()
df_sub=df[data.feature_names[0:3]]
pca.fit(df_sub)

pca_result=pca.transform(df_sub)
fig=plt.figure(figsize=(4,4))
ax=fig.add_subplot(111)
ax.scatter(pca_result[:,0],pca_result[:,1],c=data.target,cmap=plt.cm.Set3)
plt.show()
#主成分分析发

