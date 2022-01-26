#!/usr/bin/env python
# coding: utf-8

# In[1]:


# 导入相对应的数据库
import keras.models
import pandas as pd
from sklearn.datasets import fetch_openml
import matplotlib as mpl
import matplotlib.pyplot as plt
import tensorflow as tf


# In[29]:


# 导入数据mnist数据集，（前6w train、后1w test）
mnist = tf.keras.datasets.mnist.load_data()


# In[4]:


# 查看第一张图片的数据例子、以及对应标签值
some_digit_image=mnist[0][0][0]
plt.imshow(some_digit_image,cmap='binary')
plt.axis('off')
plt.show()
print('训练集第一张图片对应的结果是：')
print(mnist[0][1][0])


# 许多机器学习设计每个训练实例的成千上万甚至数百万的特征，所有这些特征不仅让训练变得缓慢，还会让找到好的解决方案变得更加的困难，这个问题通常被称为维度的诅咒，比如在MNIST数据集中，图像边界上的像素几乎都是白色，因此可以从训练集中完全删除这些像素而不会丢失太多信息
# 两种主要的数据降维方法：
# * 投影
# * 流形学习
# 
# 三种主要的数据降维技术：
# * PCA
# * kernal PCA
# * LLE

# In[30]:


# 划分训练集和测试集，并作出归一化来提高神经网络对于数据的吸收
(x_train, y_train), (x_test, y_test) = mnist
x_train, x_test = x_train / 255, x_test / 255


# ## 分析PCA和没有PCA处理的速度和精度

# In[49]:


# 利用keras快速搭建网络
model=keras.models.Sequential([
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(300,activation='relu'),
    tf.keras.layers.Dense(100,activation='relu'),
    tf.keras.layers.Dense(10,activation='softmax')
])


# In[38]:


from sklearn.decomposition import PCA

x_train_pca=x_train.reshape(60000,784)
x_test_pca=x_test.reshape(10000,784)


# In[44]:


import numpy as np
pca=PCA(n_components=x_train_pca.shape[1])
pca.fit(x_train_pca)

# 查看各主成分能够解释原始数据集的方差的比例，可以看出主成分的重要程度，帮助选择最好的维度，可以取0.95分位数
plt.plot([i for i in range(x_train_pca.shape[1])],
        [np.sum(pca.explained_variance_ratio_[:i+1]) for i in range(x_train_pca.shape[1])])
plt.title('PCA of mnist dimension')
plt.show()


# In[45]:


pca=PCA(0.95)
pca.fit(x_train_pca)

x_train_reduction = pca.transform(x_train_pca)
x_test_reduction = pca.transform(x_test_pca)


# In[50]:


model.compile(loss='sparse_categorical_crossentropy',optimizer='sgd',metrics=['accuracy'])
history=model.fit(x_train_reduction, y_train, epochs = 15, validation_data = (x_test_reduction, y_test), validation_freq = 1)


# In[51]:


# 输出训练过程中的训练集、测试集中accuracy
pd.DataFrame(history.history).plot(figsize=(8,5))
plt.grid(True)
plt.gca().set_ylim(0,1)
plt.show()
print(model.summary())


# In[52]:


from sklearn.neighbors import KNeighborsClassifier
knn_clf = KNeighborsClassifier()
knn_clf.fit(x_train_reduction, y_train)
print(knn_clf.score(x_test_reduction, y_test))


# In[53]:


# 利用keras快速搭建网络
model=keras.models.Sequential([
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(300,activation='relu'),
    tf.keras.layers.Dense(100,activation='relu'),
    tf.keras.layers.Dense(10,activation='softmax')
])

model.compile(loss='sparse_categorical_crossentropy',optimizer='sgd',metrics=['accuracy'])
history=model.fit(x_train, y_train, epochs = 15, validation_data = (x_test, y_test), validation_freq = 1)

# 输出训练过程中的训练集、测试集中accuracy
pd.DataFrame(history.history).plot(figsize=(8,5))
plt.grid(True)
plt.gca().set_ylim(0,1)
plt.show()
print(model.summary())


# ## 依旧针对网络结果来测试对应的分类属性

# In[66]:


y_train_pred=model.predict_classes(x_train)
from sklearn.metrics import confusion_matrix
conf_mx=confusion_matrix(y_train,y_train_pred)


# In[69]:


row_sums=conf_mx.sum(axis=1,keepdims=True)
norm_conf_mx=conf_mx/row_sums

np.fill_diagonal(norm_conf_mx,0)
plt.matshow(norm_conf_mx,cmap=plt.cm.gray)
plt.show()


# ### 由上图可以看出在深度学习中，数字4和数字9、以及数字3和数字5容易发生混淆

# In[82]:


# EXTRA
def plot_digits(instances, images_per_row=10, **options):
    size = 28
    images_per_row = min(len(instances), images_per_row)
    images = [instance.reshape(size,size) for instance in instances]
    n_rows = (len(instances) - 1) // images_per_row + 1
    row_images = []
    n_empty = n_rows * images_per_row - len(instances)
    images.append(np.zeros((size, size * n_empty)))
    for row in range(n_rows):
        rimages = images[row * images_per_row : (row + 1) * images_per_row]
        row_images.append(np.concatenate(rimages, axis=1))
    image = np.concatenate(row_images, axis=0)
    plt.imshow(image, cmap = mpl.cm.binary, **options)
    plt.axis("off")
    
def mnist_confusion(num1,num2):
    x_aa=x_train[(y_train==num1)&(y_train_pred==num1)]
    x_bb=x_train[(y_train==num2)&(y_train_pred==num2)]
    x_ab=x_train[(y_train==num1)&(y_train_pred==num2)]
    x_ba=x_train[(y_train==num2)&(y_train_pred==num1)]
    plt.figure(figsize=(8,8))
    plt.subplot(221);plot_digits(x_aa[:25],images_per_row=5)
    plt.subplot(222);plot_digits(x_bb[:25],images_per_row=5)
    plt.subplot(223);plot_digits(x_ab[:25],images_per_row=5)
    plt.subplot(224);plot_digits(x_ba[:25],images_per_row=5)
    plt.show()
    
mnist_confusion(4,9)


# In[83]:


mnist_confusion(3,5)


# 可以看出混淆的矩阵（均为下面两个）中错误比较明显，原因在与神经网络得到的是针对像素值的加权模型，因此对于相邻的像素值如果模式类似的话，神经网络
# 模型会非常容易混淆，比如4和9的差距从像素的角度来理解则是是否会开闭，那么如果像素值产生移位或者旋转，神经网络会非常容易的将两者混淆

# ### 尝试使用卷积神经网络CNN来对mnist进行识别，最简单的输入层、卷积层、池化层、卷积层、池化层、全连接层等

# In[107]:


model_cnn=keras.models.Sequential([
    keras.layers.Conv2D(64,7,activation='relu',padding='same',input_shape=[28,28,1]),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(128,3,activation='relu',padding='same'),
    keras.layers.Conv2D(128,3,activation='relu',padding='same'),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(256,3,activation='relu',padding='same'),
    keras.layers.Conv2D(256,3,activation='relu',padding='same'),
    keras.layers.MaxPooling2D(2),
    keras.layers.Flatten(),
    keras.layers.Dense(128,activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(64,activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(10,activation='softmax'),
])


# In[108]:


print(model_cnn.summary())


# In[110]:


x_train_cnn = x_train.reshape((60000, 28, 28, 1))
x_test_cnn = x_test.reshape((10000, 28, 28, 1))
model_cnn.compile(loss='sparse_categorical_crossentropy',optimizer='sgd',metrics=['accuracy'])
history=model_cnn.fit(x_train_cnn, y_train, epochs = 15, validation_data = (x_test_cnn, y_test))

# 输出训练过程中的训练集、测试集中accuracy
pd.DataFrame(history.history).plot(figsize=(8,5))
plt.grid(True)
plt.gca().set_ylim(0,1)
plt.show()
print(model_cnn.summary())


# In[120]:


pca=PCA(n_components=169)
pca.fit(x_train_pca)

x_train_reduction = pca.transform(x_train_pca)
x_test_reduction = pca.transform(x_test_pca)

x_train_nn_pca=x_train_reduction.reshape(60000,13,13,1)
x_test_nn_pca=x_test_reduction.reshape(10000,13,13,1)


model_cnn_pca=keras.models.Sequential([
    keras.layers.Conv2D(64,7,activation='relu',padding='same',input_shape=[13,13,1]),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(128,3,activation='relu',padding='same'),
    keras.layers.Conv2D(128,3,activation='relu',padding='same'),
    keras.layers.MaxPooling2D(2),
    keras.layers.Conv2D(256,3,activation='relu',padding='same'),
    keras.layers.Conv2D(256,3,activation='relu',padding='same'),
    keras.layers.MaxPooling2D(2),
    keras.layers.Flatten(),
    keras.layers.Dense(128,activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(64,activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(10,activation='softmax'),
])

print(model_cnn_pca.summary())


# In[122]:


model_cnn_pca.compile(loss='sparse_categorical_crossentropy',optimizer='sgd',metrics=['accuracy'])
history=model_cnn_pca.fit(x_train_nn_pca, y_train, epochs = 15, validation_data = (x_test_nn_pca, y_test), validation_freq = 1)


# In[123]:


# 输出训练过程中的训练集、测试集中accuracy
pd.DataFrame(history.history).plot(figsize=(8,5))
plt.grid(True)
plt.gca().set_ylim(0,1)
plt.show()
print(model_cnn_pca.summary())


# In[134]:


# 查看第一张图片的数据例子、以及对应标签值
some_digit_image=x_train_nn_pca[0].reshape(13,13)
plt.imshow(some_digit_image,cmap='binary')
plt.axis('off')
plt.show()


# 观察发现，主成分分析之后会将原始图像5转换成没有图像特征的杂乱的点，因此无法识别

# In[ ]:




