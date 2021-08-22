# 8 错误与异常
##8.1 句法错误 
syntax error
##8.2 异常
即使语句或者表达式使用了正确的语法，执行时仍然可能触发错误，执行时检查到的错误称为
异常比如
* Zerodivision error
* nameerror
##8.3 处理异常
可以编写程序处理选定的异常，比如下例会要求用户一直输入内容，知道输入的内容为有效的整数
但允许用户中断程序
```python
while True:
    try:
        x = int(input("Please enter a number: "))
        break
    except ValueError:
        print("Oops!  That was no valid number.  Try again...")
```
##8.4 触发异常
raise语句支持强制触发制定的异常
raise NameError（'HiThere'）
---
##8.8 预定义的清理操作
某些对象定义了不需要该对象是要执行的标准清理操纵，无论使用该对象的操作是否成功，都会执行清理
操作，比如，打开一个文件
```python
for line in open('myfile.txt'):
    print(line,end='')
```
其问题在于执行完代码之后，文件在一段不确定的时间内处于打开状态，with语句支持以及时
正确的清理的方式使用文件对象：、
```python
with open('myfile.txt') as f:
    for line in f:
        print(line,end='')
```

# 9类class
类把数据与功能绑定在一起，创建新class就是创新新的对象类型，进而创建该类型的新实例

> 支持所有面向对象编程（OOP）的标准特性：类继承机制支持多个基类，派生类可以覆盖基
> 类的任何方法，类的方法可以调用基类中相同名称的方法。对象可以包含任意数量和类型的数据。和模块一样，类也拥有 Python 天然的动态特性：在运行时创建，创建后也可以修改。

通常类的数据成员是public，也有私有变量private
所有成员函数是virtual

##9.1作用域和命名空间举例
如果一个名称被声明为全局变量，则所有引用和复制将直接包含该模块的全局名称的中间作用域，要重新绑定在最内层作用域之外找到的变量，可以使用nonlocal语句声明为非本地变量
##9.3 类定义语法以及操作

在实际操作