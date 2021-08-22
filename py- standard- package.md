# python标准库参考
> 由于之前并没有学过python，这里对常见的python库进行了解
> python标准库非常庞大，所提供的组件和设计范围十分广泛，这个库中包含多个内置的模块，python利用他们来实现系统级别功能

## random.py 生成伪随机数
>  对于整数，从范围中统一的选择，对于序列存在随机元素的统一选择，用于欧生成列表的随机排列的函数，以及用于随机抽样而无需替换的函数
>  在实数轴上，有计算均匀、正态、对数、负指数、伽马、和贝塔分布的函数
> 

所有的模块依赖于基本函数**random（）**：在半开发的0，1区间内生成随机浮点数
random.seed()如果a被省略则为系统时间，
### 生成随机字节
random.randbytes(n)生成随机字节
### 生成随机整数
### 在序列中随机
random.choice()
random.choices()
random.shuffle()
random.sample()
###实值分布
random.random()
random.uniform()
random.triangular(low,high,mode)三角分布
random.beravariate(alpha,beta)beta分布
random.expovariate(lambd)指数分布
random.gammavariate(alpha,beta)gamma分布
random.gauss(mu,sigma)

## string 常见的字符串操作
文本序列类型 str
太复杂了，看不懂～～

##re 正则表达式操作
> 模式和被搜索的字符串可以是unicode字符串（str），也可以是8位字节串（bytes）
> 正则表达式用反斜杠字符'\'表示特殊格式，或者是在使用特殊字符时不引发她他们的特殊含义
> 正则表达水指定了一组与之匹配的字符串，模版内的函数可以检查某个字符串是否与给定的正则表达式匹配


正则表达式的具体语法可以超着
* re.compile(pattern)\re.match()\re.match()利用compile将正则表达式的
* 样式编译位一个正则表达水对象，可以用于匹配，通过这个对象的方法match和search来寻找
* re.match \re,search\re,fullmatch
* re.split，用pattern分开string

## datetime 基本日期和时间类型
> 在支持日期时间数学运算的同时，实现的关注点更注重与如何能够更有效地解决其属性用于格式输出和数据操作

* 感知型对象和简单性对象，在充分掌握应用性算法和政治性时间调整信息例如时区和夏令时的情况下，一个感知型对象就能相对于其他感知型对象来精确定位自身时间点，感知型对象是用来表示一个没有结识空间的固定时间点
* 简单型对象没有包括足够多的信息来无歧义地相对于其他对象来定位自身的时间点

* datetime.date
* datatime.time
* datetime.datetime(year,month,hour,minute,second,mincrosecond,tzinfo)
* datetime.timedelta **两个date，timem，datetime之间的差值

## logging -python的日志记录工具
> 这个模块为应用与库实现来灵活的事件日志系统的函数与类
> 记录器暴露类应用程序代码直接使用的接口
> 处理器将日志记录发送到适当的目标
> 过滤器提供类更细粒度的功能，用于确定要输出的日志记录
> 格式器指定最终输出在日志记录的样式