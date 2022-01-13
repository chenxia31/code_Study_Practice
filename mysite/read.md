1. 新建项目的文件和目录解释

外层的mysite/目录与Django无关，知识项目的容器
manage。py 是命令行工具，是管理DJango的交互脚本

内部的mysit/是真正的项目包括目录

**Django的开发服务器具有自动重载功能，当你python代码修改，服务器会在一定周期内自动更新，但是有一些工作需要自己重新修改

2。 新建自己的APP
app是实现某个具体功能
project是配置文件和多个app的集合

app的存放位置可以是任何节点，通常都放在与manage.py脚本同目录的脚本下

创建模型
Django通过自定义python类的形式来定义具体形式的模型，每个模型的存在方式就是python中
的类class，每个模型代表数据库中的一张表，每个类的实际例子代表数据表中的一行数据
类中的每个变量代表数据表中的一列字段
Django通过模型，将python代码和数据库操作结合起来是、，实现SQL查询语言的封装

这样通过python的代码进行数据库的操作，这就是所谓ORM，将python程序员和数据库管理员进行分工


修改模型分为三步
1。 在models.py中修改模型
2。 运行python manage。py makemigration 给改动创建迁移记录文件
3。 运行python manage。py migrate将操作同步到数据库

model的使用很重要，是动态网站与数据库交互的核心，对于初学者需要理解

在投票的应用中，将建立下面的视图
index 显示最新的问卷
detail 显示一个问卷的详细文本内容
results 显示某个问卷的投票或者调查结果

## 编写实际的view
最基本的
返回一个包含请求页面的HttpResponse
或者染出一个类似Http404的一场

## 表单和视图
request。POST是一个类似字典的对象，允许通过健名
在选择计数器加以之后，返回的是一个redirect，是一个良好的web开发