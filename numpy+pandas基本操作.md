# numpy 基础知识
> NumPy是使用python进行科学计算的基础包，包含主要的内容
> 一个强大的N维度数组对象，复杂的广播功能，用于集成其他芋圆代码的工具
>有用的线性代数，傅立叶变换和随机数的功能
## 数据类型
Numpy的主要对象是同构多维数组，它是由一个元素表组成，Numpy的数组类被调用
ndarray，**这里的numpy.array和标准库的array.array，后者智能处理一维
数组并提供较少的功能，ndarray对象的属性常有：
* ndarray.ndim，数组轴的个数，也被称为rank
* ndarrat.shape 数组的维度，表示维度的数组（n,m），shape的长度就是ndim
* ndarray.size数组中元素的总数，n*m
* ndaary.dtype 描述数组中元素类型的对象，**python标准类型**或者**numpy.int32**
* ndarray.itemsize 数组中每个元素的字节大小
* ndarray.data 该缓冲区包含数组的实际元素，通常我们不实用此属性

## 创建数组
* 使用array函数从常规的python列表或者元祖中创建数组，但是array函数智能提供单个数字
* 列表类型作为参数,也可以用列表嵌套列表的方式来生成不同ndim的数组

* zeros，ones，empty随机的数组,np.arrange返回特定步长的数组，np.linspace接受元素数量

打印数组，numpy会用嵌套列表类似的方式，常具有一下布局的特点
> 最后一个轴从左向右打印
> 倒数第二个从上到下打印
> 其余部分也从上到下打印，每个切片用空行分隔

数组太大无法打印，可以使用np.set_printoptions(threshold=sys.maxsize)
## 数组的基本操作，算术运算度会应用到元素级别
类似matlab的矩阵操作
* 、+
* 、-
* 、**
* 、constant*
* 、<\>\>=\<=\==
* 与许多矩阵语言不同，*在numpy数组中按照元素进行运算，@或者dot执行矩阵乘

* 许多一元操作，例如计算数组中所有元素的总类，都是作为ndarray类的方法实现的
* 可以通过制定axis参数，可以沿这数组的制定轴应用操作，axis=0按照列
* axis=1是按照行

Numpy提供熟悉的数学函数，这些在numpy被称为通函数

##索引、切片和迭代
一维的数组可以进行索引、切片和迭代操作，就像列表和其他python序列类型一样
多轴的数组每个轴可以有一个索引，这些索引以逗号分隔的元祖给出

对于多维数组进行迭代是相对于第一个轴完成的，若要对每个数组进行操作，需要用的flat属性

改变数组的形状，可以使用各种命令更改数组的形状，但是下列三个命令都会返回一个修改
后的数组，但不会修改原属数组
a.ravel()
a.reshape()
a.T

**使用ndarray.resize(())会更改数组本身，制定-1，会自动计算其他size的大小

将不同数组堆叠在一起
* 几个数组沿着不同的轴堆叠在一起vstack，hstack,column_stack,row_stack
 利用hsplit可以沿数组的水平轴数组，方法是要制定要返回的形状相等的数组的数量，
* 或者制定应该在其之后进行分隔的列，利用vsplit可以沿垂直轴分隔，利用array-split允许制定要分隔的轴

## Nnumpy的功能和方法概述，常见的API
* 数组的创建array creation
* 转换和变换conversions
* 操纵术manipulations
* 询问questions
* 顺序ordering
* 操作operation
* 基本统计basic  statistics
* 基本线性代数 basic linear algorithm