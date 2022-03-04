import util
import seaborn as sns
import matplotlib.pyplot as plt
Xa, Ya = util.load_csv('../data/ds1_b.csv', add_intercept=True)
print(Xa)
sns.scatterplot(Xa[:,1],Xa[:,2],hue=Ya)
plt.show()