import numpy as np
import util
from linear_model import LinearModel
import numpy as np


def main(train_path, eval_path, pred_path):
    """Problem 1(b): Logistic regression with Newton's Method.

    Args:
        train_path: Path to CSV file containing dataset for training.
        eval_path: Path to CSV file containing dataset for evaluation.
        pred_path: Path to save predictions.
    """
    x_train, y_train = util.load_dataset(train_path, add_intercept=True)
    x_eval, y_eval = util.load_dataset(eval_path, add_intercept=True)

    # *** START CODE HERE ***
    model = LogisticRegression()
    model.fit(x_train, y_train)
    # *** END CODE HERE ***


class LogisticRegression(LinearModel):
    """Logistic regression with Newton's Method as the solver.

    Example usage:
        > clf = LogisticRegression()
        > clf.fit(x_train, y_train)
        > clf.predict(x_eval)
    """

    def fit(self, x, y):
        """Run Newton's Method to minimize J(theta) for logistic regression.

        Args:
            x: Training example inputs. Shape (m, n).
            y: Training example labels. Shape (m,).
        """

        # *** START CODE HERE ***
        def h(theta, x):
            ''' logistic的假设

            参数：
                theta：超参数
                x：输入变量，或者是特征值
            '''
            return 1 / (1 + np.exp(-np.dot(x, theta)))

        # *** END CODE HERE ***

        def gradient(theta, x, y):
            ''' 计算梯度

            参数：
                theta：超参数
                x：输入变量
                y：验证变量

            '''
            m, _ = x.shape
            return -1 / m * np.dot(x.T, (y - h(theta, x)))

        def hessian(theta, x):
            """ 计算Hessian公式
            """
            m, _ = x.shape
            h_theta_x = np.reshape(h(theta, x), (-1, 1))
            return 1 / m * np.dot(x.T, h_theta_x * (1 - h_theta_x) * x)

        def next_theta(theta, x, y):
            """通过Newton法来更新theta

            :param theta: Shape (n,).
            :return:      The updated theta of shape (n,).
            """
            return theta - np.dot(np.linalg.inv(hessian(theta, x)), gradient(theta, x, y))

        m, n = x.shape  # m是训练集的大小，n是特征的多少

        # 初始化theta
        if self.theta is None:
            self.theta = np.zeros(n)

        # 更新theta
        old_theta = self.theta
        new_theta = next_theta(self.theta, x, y)

        # 合适的时候停止
        while np.linalg.norm(new_theta - old_theta, 1) >= self.eps:
            old_theta = new_theta
            new_theta = next_theta(old_theta, x, y)

        self.theta = new_theta

    def predict(self, x):
        """Make a prediction given new inputs x.

        Args:
            x: Inputs of shape (m, n).

        Returns:
            Outputs of shape (m,).
        """
        # *** START CODE HERE ***
        return x @ self.theta >= 0
        # *** END CODE HERE ***


train_path = '../data/ds1_train.csv'
valid_path = '../data/ds1_valid.csv'
prad_path = '../data/ds1_valid.csv'
main(train_path, valid_path, prad_path)
