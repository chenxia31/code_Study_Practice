import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

class knn:
    def loadDataset(self,filename):
        # 借用SVM的数据集，但是这里使用numpy返回np.array数据
        dataMat = [];
        labelMat = []
        fr = open(filename)
        for line in fr.readlines():  # 逐行读取，滤除空格等
            lineArr = line.strip().split('\t')
            dataMat.append([float(lineArr[0]), float(lineArr[1])])  # 添加数据
            labelMat.append(float(lineArr[2]))  # 添加标签
        dataMat=np.array(dataMat)
        self.dataMat=dataMat
        self.labelMat=labelMat

    def  visualDataset(self):
        sns.scatterplot(self.dataMat[:, 0],self.dataMat[:, 1],hue=self.labelMat)
        plt.show()

    def predict(self,input,k):
        def distance(point):
            points=np.tile(point,(self.dataMat.shape[0],1))
            dis=np.linalg.norm(points - self.dataMat,axis=1)
            return dis
        dis=distance(input)
        target=np.array(self.labelMat)[np.argsort(dis)<k]
        if sum(target)>0:
            return 1
        else:
            return -1

if __name__ == '__main__':
    model=knn()
    model.loadDataset('CS229_2018autumn/ProblemSet(课后作业）/codeByhand/datasets/testSet.txt')
    model.visualDataset()
    example=[0,0]
    print(model.predict(example,6))


