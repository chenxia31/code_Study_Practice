import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import seaborn as sns
import numpy as np
import FinalTest_function
import tensorflow as tf

from tkinter import font
from pandas.plotting import scatter_matrix
from pylab import mpl
from sklearn.cluster import KMeans
from sklearn import metrics
from mpl_toolkits.mplot3d import Axes3D
from tslearn.metrics import dtw
from scipy.stats import norm
from statsmodels.tsa.seasonal import seasonal_decompose
from statsmodels.tsa.seasonal import STL
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from sklearn.mixture import GaussianMixture as GMM
from sklearn.model_selection import train_test_split #这里是引用了交叉验证
from sklearn.linear_model import LinearRegression  #线性回归
from dtaidistance import dtw
from dtaidistance import dtw_visualisation as dtwvis

mpl.rcParams['font.sans-serif'] = ['SimHei']
plt.figure(dpi=600)
#%%导入数据
names_LoopDetector = ['begin', 'end',
                      'road1_speed', 'road2_speed', 'road3_speed', 'road4_speed', 'road5_speed', 'road6_speed',
                      'road1_volume', 'road2_volume', 'road3_volume', 'road4_volume', 'road5_volume', 'road6_volume',
                      'road1_occ', 'road2_occ', 'road3_occ', 'road4_occ', 'road5_occ', 'road6_occ']
df_LoopDetector = pd.read_excel('2021年交通数据分析-期末大作业数据.xlsx', sheet_name=0, skiprows=[0], names=names_LoopDetector)
df_LoopDetector=df_LoopDetector.fillna(-1)
names_FLoatingCar = ['begin', 'end',
                     'road1_speed', 'road2_speed', 'road3_speed', 'road4_speed', 'road5_speed', 'road6_speed']
df_FloatingCar = pd.read_excel('完整数据.xlsx', sheet_name=1, skiprows=1, names=names_FLoatingCar)
names_AVI = ['begin', 'end', 'speed']
df_AVI = pd.read_excel('完整数据.xlsx', sheet_name=2, skiprows=1, names=names_AVI)
names_Real = ['begin', 'end',
              'road1_speed', 'road2_speed', 'road3_speed', 'road4_speed', 'road5_speed', 'road6_speed']
df_Real = pd.read_excel('完整数据.xlsx', sheet_name=3, skiprows=1, names=names_Real)
name_road = ['road1', 'road2', 'road3', 'road4', 'road5', 'road6']
Road_dis = pd.Series([507, 687, 490, 600, 267, 417], index=name_road)

#%%第一题
TravelTime_Real = pd.DataFrame(columns=name_road)
for road in name_road:
    TravelTime_Real[road] = Road_dis[road] / df_Real[road + '_speed']
Result1 = sum(Road_dis) / TravelTime_Real.apply(lambda x: x.sum(), axis=1)
print('-----T1.1  统计量-----------')
print(Result1.describe())
print('-----T1.2 五分位数和箱型图----')
print(Result1.quantile([0.2,0.4,0.6,0.8]))
print('四分位数')
print(Result1.quantile(0.25)-1.5*(Result1.quantile(0.75)-Result1.quantile(0.25)))
print(Result1.quantile(0.75)+1.5*(Result1.quantile(0.75)-Result1.quantile(0.25)))
plt.boxplot(Result1, labels=['平均行程速度'], vert=True, patch_artist=True, boxprops=dict(facecolor='lightblue'))
plt.title('干线平均行程速度箱箱图分布', fontsize=12)
plt.ylabel('观测值(km/h)')
plt.show()
print('-----T1.3 频数与累计频率分布----------')
fig1=plt.figure()
plt.xlabel('行程速度间隔区间(km/h)')
plt.title('干线平均行程速度--区间频数与累计分布频率')
ax1 = fig1.add_subplot(111)
binBoundaries = np.linspace(0,80,9)
a1,a2,a3=plt.hist(Result1,bins=binBoundaries,color='steelblue',edgecolor='k')
plt.ylabel('频数')
Result1_sumfre=[]
for i in range(1,len(a2)):
    Result1_sumfre.append(sum(a1[:i]))
ax2=ax1.twinx()
plt.plot(np.linspace(5,75,8),Result1_sumfre/sum(a1),'r-^')
plt.ylim(0,1.2)
plt.yticks(np.linspace(0,1.2,7),['0%','20%','40%','60%','80%','100%','120%'],color='r')

plt.ylabel('累计频率',color='r')
plt.legend(('累计频率曲线',))
plt.show()
#%%
sns.set_palette("hls") #设置所有图的颜色，使用hls色彩空间
sns.distplot(Result1,bins=30,kde_kws={"color":"seagreen", "lw":3 }, hist_kws={ "color": "b" }) 
plt.xlabel('速度')
plt.title('干线平均行程速度的直方图分布')
plt.show()
#%%
plt.title('干线平均行程速度速度的STL分解')
stl1=STL(Result1,period=13,robust=True)
res_robust=stl1.fit()
res_robust.plot()
acf = plot_acf(Result1, lags=20)
plt.title("ACF")
acf.show()

pacf = plot_pacf(Result1, lags=20)
plt.title("PACF")
pacf.show()
#%%
Result1.to_csv('作业第一题_干线平均行程速度.csv',index=False,header=False)

#%%第二题
#分路段进行异常值检测
r1=[]
r2=[]
r3=[]
for i in range(1,7):
    index_speed=df_LoopDetector['road'+str(i)+'_speed']
    index_volume=df_LoopDetector['road'+str(i)+'_volume']
    index_occ=df_LoopDetector['road'+str(i)+'_occ']
    t1,t2,t3,temp1,temp2,temp3=speed_volume_occupancy_judge(index_speed,index_volume,index_occ)
    r1.append(temp1)
    r2.append(temp2)
    r3.append(temp3)

#分路段对缺失值和异常值进行处理
for i in range(1,7):
    speed_volume_occupancy_correct(df_LoopDetector['road'+str(i)+'_speed'])
    speed_volume_occupancy_correct(df_LoopDetector['road'+str(i)+'_volume'])
    speed_volume_occupancy_correct(df_LoopDetector['road'+str(i)+'_occ'])

#%%
df_LoopDetector.to_csv('作业第二题_筛选修复线圈数据.csv',header=True,index=False)
#%%
grid = sns.PairGrid(df_LoopDetector.iloc[:,range(2,8)])
def corr(x, y, **kwargs):
    # Calculate the value
    coef = np.corrcoef(x, y)[0][1]
    # Make the label
    label = r'$\rho$ = ' + str(round(coef, 2))
    # Add the label to the plot
    ax = plt.gca()
    ax.annotate(label, xy = (0.2, 0.95), size = 20, xycoords = ax.transAxes)
grid = grid.map_upper(sns.regplot)
grid = grid.map_upper(corr)
grid = grid.map_lower(sns.kdeplot, cmap = 'Blues')
grid = grid.map_diag(sns.histplot, bins = 10, color = 'lightsteelblue');

#%% 第三题,选择路段2的车辆进行聚类分析
road_choose_mean=2;
index_speed='road'+str(road_choose_mean)+'_speed'
index_volume='road'+str(road_choose_mean)+'_volume'
index_occ='road'+str(road_choose_mean)+'_occ'
Database3_kmeans=df_LoopDetector[[index_speed,index_volume,index_occ]]
#%%
Database3_kmeans=norm_min_max(Database3_kmeans,3)
#%%
score1_kmeans=[]
score2_kmeans=[]
score1_gmm=[]
score2_gmm=[]
for i in range(2,10):
    estimator=KMeans(n_clusters=i,random_state=35,init='k-means++')
    kmeans=estimator.fit(Database3_kmeans)
    score1_kmeans.append(metrics.silhouette_score(Database3_kmeans, estimator.labels_, metric='euclidean'))
    score2_kmeans.append(metrics.calinski_harabasz_score(Database3_kmeans, estimator.labels_))
    gmm_e = GMM(n_components=i).fit(Database3_kmeans) #指定聚类中心个数为4
    labels = gmm_e.predict(Database3_kmeans)
    score1_gmm.append(metrics.silhouette_score(Database3_kmeans, labels, metric='euclidean'))
    score2_gmm.append(metrics.calinski_harabasz_score(Database3_kmeans, labels))
plt.plot(range(2,10),score1_kmeans,'b')
plt.plot(range(2,10),score1_gmm,'r')
plt.xlabel('k值')
plt.ylabel('轮廓系数')
plt.legend(['kmeans','gmm'])
    
#%%
#构造聚类数为3的聚类器
estimator=KMeans(n_clusters=3,random_state=35)
kmeans=estimator.fit(Database3_kmeans)
print(kmeans.labels_)
print(kmeans.cluster_centers_)
print("轮廓系数：", metrics.silhouette_score(Database3_kmeans, estimator.labels_, metric='euclidean'))
kmeans_color=['r','b','k','y','g']
ax=plt.subplot(111,projection='3d')
Database3_kmeans.index=kmeans.labels_
for i in range(3):
    print('----类别'+str(i)+'的流密速统计信息---')
    print(Database3_kmeans.loc[i].describe())
    ax.scatter(Database3_kmeans.loc[i,index_speed],Database3_kmeans.loc[i,index_volume],Database3_kmeans.loc[i,index_occ],c=kmeans_color[i])
ax.set_zlabel('occupancy')
ax.set_ylabel('volume')
ax.set_xlabel('speed')
plt.legend(['class1','class2','class3'])
plt,title('k-means(k=3)')
plt.show()
Database3_kmeans.to_csv('作业第三题_聚类数据.csv',header=True,index=True)
#%%
gmm = GMM(n_components=2).fit(Database3_kmeans) #指定聚类中心个数为4
ax=plt.subplot(111,projection='3d')
labels = gmm.predict(Database3_kmeans)
ax.scatter(Database3_kmeans.loc[:,index_speed],Database3_kmeans.loc[:,index_volume],Database3_kmeans.loc[:,index_occ], c=labels, cmap='jet')
ax.set_zlabel('occupancy')
ax.set_ylabel('volume')
ax.set_xlabel('speed')
plt,title('GMM（k=2）')
plt.show()
#%%
Database3_kmeans['class_k']=estimator.labels_
Database3_kmeans['class_k'] = Database3_kmeans['class_k'].map({0:'class1',1:'class2',2:'class3'})
sns.pairplot(Database3_kmeans,
             kind = 'scatter', #散点图/回归分布图{'scatter', 'reg'})
             diag_kind = 'kde', #直方图/密度图{'hist'， 'kde'}
             hue = 'class_k',   #按照某一字段进行分类
             markers = ['o', 's', 'D'], #设置不同系列的点样式（这里根据参考分类个数）
             size = 2  #图标大小
             )

#%%第四题
path = dtw.warping_path(df_LoopDetector['road3_speed'],df_Real['road3_speed'])
dtwvis.plot_warping(df_LoopDetector['road3_speed'],df_Real['road3_speed'], path)
#%%
for idx in range(len(df_Real['road3_speed'])):
    if random.random() < 0.05:
        df_Real['road3_speed'][idx] += (random.random() - 0.5) / 2
d, paths = dtw.warping_paths(df_LoopDetector['road3_speed'],df_Real['road3_speed'], window=25, psi=2)
best_path = dtw.best_path(paths)
dtwvis.plot_warpingpaths(df_LoopDetector['road3_speed'],df_Real['road3_speed'], paths, best_path)
#%%
disLR1,disLR2,matrixLR1,covLR,corLR=distance_counting(df_LoopDetector['road3_speed'],df_Real['road3_speed'])
disFR1,disFR2,matrixFR1,covFR,corFR=distance_counting(df_FloatingCar['road3_speed'],df_Real['road3_speed'])
cmap = sns.cubehelix_palette(start = 1.5, rot = 3, gamma=0.8, as_cmap = True)
plt.plot(df_LoopDetector['road3_speed'])
plt.plot(df_FloatingCar['road3_speed'])
plt.plot(df_Real['road3_speed'])
legend(['LoopDetector','FloatingCar','Real'])
print('------Result4-----')
print('----车道3----')
print('--LoopDetector and Real---')
print(disLR1)
print(disLR2)
print(covLR)
print(corLR)
print('---FloatingCar and Real---')
print(disFR1)
print(disFR2)
print(covFR)
print(corFR)
#%%

disLR12,disLR22,matrixLR12,covLR2,corLR2=distance_counting(df_LoopDetector['road6_speed'],df_Real['road6_speed'])
disFR12,disFR22,matrixFR12,covFR2,corFR2=distance_counting(df_FloatingCar['road6_speed'],df_Real['road6_speed'])
cmap = sns.cubehelix_palette(start = 1.5, rot = 3, gamma=0.8, as_cmap = True)
plt.plot(df_LoopDetector['road6_speed'])
plt.plot(df_Real['road6_speed'])
plt.plot(df_FloatingCar['road6_speed'])
print('------Result4-----')
print('----车道6----')
print('--LoopDetector and Real---')
print(disLR12)
print(disLR22)
print(covLR2)
print(corLR2)
print('---FloatingCar and Real---')
print(disFR12)
print(disFR22)
print(covFR2)
print(corFR2)

#sns.heatmap(t3,cmap=cmap)
#%%绘制相关系数的热力图
FC_covf=[]
LD_covf=[]
for i in range(6):
    LD_covf.append(np.corrcoef(df_Real.iloc[:,i+2],df_LoopDetector.iloc[:,i+2])[0,1])
    FC_covf.append(np.corrcoef(df_Real.iloc[:,i+2],df_FloatingCar.iloc[:,i+2])[0,1])
x1=np.arange(6)
x2=np.arange(6)+0.3
plt.bar(x1,height=LD_covf,width=0.2,color='c')
plt.bar(x2,height=FC_covf,width=0.2,color='mistyrose')
plt.xticks(range(6),name_road)
plt.ylabel('corrcoef')
legend(['LoopDetector','FloatingCar','AVI'])
#%%
[D, distance] = dtw(df_LoopDetector['road3_speed'], 168, df_Real['road3_speed'], 168)
# print('D',D.shape)
colormat = np.ones((167,167))
index = path(distance,D,168,168)
    # print(index)
draw(range(168),df_FloatingCar['road3_speed'],range(168),df_Real['road3_speed'],index)

#%%第五题
MAPE_Loop=[]
RMSE_Loop=[]
MAPE_FR=[]
RMSE_FR=[]
MAPE_AVI=0
RMSE_AVI=0
for i in range(1,7):
    index='road'+str(i)+'_speed'
    MAPE_Loop_temp,RMSE_Loop_temp=MAPE_RMSE_counting(df_LoopDetector[index],df_Real[index])
    MAPE_FR_temp,RMSE_FR_temp=MAPE_RMSE_counting(df_FloatingCar[index],df_Real[index])
    MAPE_Loop.append(MAPE_Loop_temp)
    RMSE_Loop.append(RMSE_Loop_temp)
    MAPE_FR.append(MAPE_FR_temp)
    RMSE_FR.append(RMSE_FR_temp)
MAPE_AVI,RMSE_AVI=MAPE_RMSE_counting(df_AVI['speed'],Result1)
#%%
# 使用两次 bar 函数画出两组条形图
index1_mape = np.arange(6)
index2_mape = index1_mape + 0.2
index3_mape=index2_mape+0.2
plt.bar(index1_mape, height=MAPE_Loop, width=0.2, color='m')
plt.bar(index2_mape, height=MAPE_FR, width=0.2, color='tan')
plt.bar(index3_mape, height=MAPE_AVI, width=0.2, color='c')
plt.xticks(range(6),name_road)
plt.ylabel('MAPE')
legend(['LoopDetector','FloatingCar','AVI'])

#%%第
index1_rmse = np.arange(6)
index2_rmse= index1_rmse + 0.2
index3_rmse=index2_rmse+0.2
plt.bar(index1_rmse, height=RMSE_Loop, width=0.2, color='m')
plt.bar(index2_rmse, height=RMSE_FR, width=0.2, color='tan')
plt.bar(index3_rmse, height=RMSE_AVI, width=0.2, color='c')
plt.xticks(range(6),name_road)
plt.ylabel('RMSE')
legend(['LoopDetector','FloatingCar','AVI'])
%%
sum(MAPE_Loop)/6
sum(MAPE_FR)/6
sum(RMSE_Loop)/6
sum(RMSE_FR)/6
#%%第六题
ld1=df_LoopDetector.iloc[:,range(2,8)]
ld1.to_csv('speed_loop.csv',index=False,header=False)
fc1=df_FloatingCar.iloc[:,range(2,8)]
fc1.to_csv('speed_FR.csv',index=False,header=False)
avi1=df_AVI.iloc[:,2]
avi1.to_csv('speed_AVI.csv',index=False,header=False)
re1=df_Real.iloc[:,range(2,8)]
re1.to_csv('speed_Real.csv',index=False,header=False)





