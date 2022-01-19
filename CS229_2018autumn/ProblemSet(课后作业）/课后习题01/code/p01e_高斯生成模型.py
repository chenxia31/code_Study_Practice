import numpy as np
import util
from linear_model import LinearModel
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt



def main(train_path, eval_path, pred_path):
    """Problem 1(e): Gaussian discriminant analysis (GDA)

    Args:
        train_path: Path to CSV file containing dataset for training.
        eval_path: Path to CSV file containing dataset for evaluation.
        pred_path: Path to save predictions.
    """
    # Load dataset
    x_train, y_train = util.load_dataset(train_path, add_intercept=False)
    # x_train :是一个shape(m,n)的dataset，每一行代表一个example
    # y_train：是一个0-1分布
    # *** START CODE HERE ***
    model = GDA()
    model.fit(x_train, y_train)
    model.visual(x_train,y_train)
    # *** END CODE HERE ***


class GDA(LinearModel):
    """Gaussian Discriminant Analysis.

    Example usage:
        > clf = GDA()
        > clf.fit(x_train, y_train)
        > clf.predict(x_eval)
    """

    def fit(self, x, y):
        """Fit a GDA model to training set given by x and y.

        Args:
            x: Training example inputs. Shape (m, n).
            y: Training example labels. Shape (m,).

        Returns:
            theta: GDA model parameters.
        """

        # *** START CODE HERE ***
        def gen_phi(y):
            """计算P(Y)伯努利分布的参数

            输入参数：shape(m,)
            返回参数：R
            """
            return np.mean(y)

        def gen_mu0(x, y):
            """计算P（X｜Y=0）的高斯分布均值

            输入参数：x shape（m,n) y shape(m,)
            返回参数：mu0 shape(1,n)
            """
            return np.mean(x[y == 0], axis=0)

        def gen_mu1(x, y):
            """计算P（X｜Y=1）的高斯分布均值

            输入参数：x shape（m,n) y shape(m,)
            返回参数：mu1 shape(1,n)
            """
            return np.mean(x[y == 1], axis=0)

        def gen_sigma(x, y):
            """ 计算P（X｜Y）的方差矩阵

            输入参数：x shape（m,n) y shape(m,)
            返回参数：sigma shape(n,n)
            """

            mu = np.tile(y, (2, 1)).T * gen_mu1(x, y).T + np.tile((1 - y.T), (2, 1)).T * (gen_mu0(x, y).T)
            sigma = np.dot(((x - mu).T), (x - mu)) / mu.shape[0]
            return sigma

        # 计算theta
        sigma_inv = np.linalg.inv(gen_sigma(x, y))
        theta = np.dot(sigma_inv, gen_mu1(x, y) - gen_mu0(x, y))

        theta_0 = 1 / 2 * gen_mu0(x, y) @ sigma_inv @ gen_mu0(x, y) - 1 / 2 * gen_mu1(x, y) @ sigma_inv @ gen_mu1(x,
                 y) - np.log((1 - gen_phi(y)) / gen_phi(y))

        self.theta = np.insert(theta, 0, theta_0)

        # *** END CODE HERE ***

    def visual(self,x,y):
        df=pd.DataFrame(x,columns=('x1','x2'))
        df['y']=y
        sns.scatterplot(data=df,x='x1',y='x2',hue='y')
        x1=np.linspace(0,8,100)
        x2=(self.theta[0]+self.theta[1]*x1)/self.theta[2]
        plt.plot(x1,-x2)
        plt.show()


    def predict(self, x):
        """Make a prediction given new inputs x.

        Args:
            x: Inputs of shape (m, n).

        Returns:
            Outputs of shape (m,).
        """
        # *** START CODE HERE ***
        # *** END CODE HERE


train_path = '../data/ds2_train.csv'
valid_path = '../data/ds2_valid.csv'
main(train_path, valid_path, valid_path)
