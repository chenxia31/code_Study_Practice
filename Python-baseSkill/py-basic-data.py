#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/18
# @Author  : chenxia
# @File    : py-basic-data.py
# %%
# 赋值
spam = 1
text = 'this is not a coment but a indisde quotes'
# 加减乘除
2 + 2
5 * 6
(50 - 5 * 6) / 6
50 // 6  # 商
50 % 6  # 余数
5 ** 2  # 乘方
# division always returns a floating point number
# /返回浮点数，//返回整数类型
# 字符串
print('spam eggs')
print('doesn\'t')  # 特殊字符可以使用反义\，或者在前面加r
word = 'py' + 'thon'
print('py' 'thon')
print(word[0])
# 字符串的索引是下标访问，第一个字符的索引是0，负数索引的从右边开始计数
# 切片操作，输出结果包含切变开始，不包含切片结束
word[:2]
# 切片省略默认是最初的或者是最后的
# 字符串是immutable
str.format()
# 字符串的更多中文操作https://docs.python.org/zh-cn/3/library/stdtypes.html#string-methods

# 列表
squares = [1, 3, 5, 6]
# 支持索引和切片，这些都是sequence类型的概念
squares[0]
squares[-2]
squares[2:]
squares + [336, 49]  # 合并
squares.append(216)
len(squares)

# %%
# 控制语句if\for\while
x = int(input('please enter an integert:'))
if x < 0:
    x = 0
elif x == 0:
    print('n')
elif x == 1:
    print('e')
else:
    print('more')

for i in range(len(word)):
    print(i, word[i])

range(10)  # 返回对象的操作和列表很相似，但是两种对象不是一回事，
# 在迭代时，该对象基于所需序列返回连续项，并没有生成真正的列表，
# 从而节省空间,这种可迭代对象iterable
for n in range(2, 10):
    for x in range(2, n):
        if n % x == 0:
            print(n, 'equals', x, '*', n // x)
            break
    else:
        # loop fell through without finding a factor
        print(n, 'is a prime number')


# for函数的else更像是try函数的else语句
# break表示结束循环
# continue表示继续执行下一次循环的迭代

# 定义函数
def fib(n):
    """print a fibonacci series up to n"""
    #函数内第一条语句是字符串，该字符串就是文档字符串
    a,b=0,1
    while a<n:
        print(a,end='')
        a,b=b,a+b
        print()
fib(2000)
# 函数定义可支持可变数量的从那好苏，这里列出三种可以组合使用的形式
# 默认值参数
def ask_ok(prompt, retries=4, reminder='Please try again!'):
    while True:
        ok = input(prompt)
        if ok in ('y', 'ye', 'yes'):
            return True
        if ok in ('n', 'no', 'nop', 'nope'):
            return False
        retries = retries - 1
        if retries < 0:
            raise ValueError('invalid user response')
        print(reminder)
# 关键字参数kwarg-value
def parrot(voltage, state='a stiff', action='voom', type='Norwegian Blue'):
    print("-- This parrot wouldn't", action, end=' ')
    print("if you put", voltage, "volts through it.")
    print("-- Lovely plumage, the", type)
    print("-- It's", state, "!")

#%%
#数据结构
#列表
x=[1,2,3,4,5]
x.append(1)#在尾部添加一个元素
x.extend(range(1,10))#添加可迭代对象
x.insert(1,2)#在1位置插入2
list.remove(2)#删除列表中第一值为2的变量
list.pop(i)#delete index=i value ,default queals -1
del x[i]#删除对应元素
list.clear()#清空列表
list.index(x,['start,end'])#寻找第一个值的下标
list.count(x)#计算列表中元素x的出现次数
list.reverse()#排序列表的元素
list.copy()#复制列表

#列表推导式
squares=list(map(lambda x:x**2,range(10)))
squares=[x**2 for x in range(10)]
[(x,y) for x in range(3) for y in range(1,4)]

#嵌套的列表表达式
matrix=[[1,2],[3,4]]
[[row[i] for row in matrix] for i in range(2)]

#%%
#列表和字符串都有很多共性，例如索引和切片擦欧总，这两种数据类型都是序列类型
#随着python语言的发展，其他序列类型也被加入其中，另一个标准序列类型；运足
t=124,3432,'hello'
u=t,(12,3234,5436)
# 元祖tuple是immutable不可变的，一般包含不同类型元素序列，通过解包或者索引访问
# 列表是可变的，列表元素一般是为同质类型，可迭代访问

#%%
#集合 是由不重复元素组成的无序容器
#基本用法包括成员检测，消除重复元素
#集合支持合集、交集、差集、对称查分数学元素暗
# 创建集合利用花括号，或者set（）
basket={'apple','orange'}
a=set('sdfrdf')
#支持集合推导式

#%%
#字典，映射类型，一种常用的python内置数据类型，其他语言可能把字典称为
# 联合内存或者俄联合数组，与以连续整数为索引的序列不同，字典以关键字为索引
# 关键字通常是字符串或数字，也可以是其他任意不可遍类型，字典的键必须是独一无二的
tel={'jack':234235,'sape':23423}
#关键字存储，提取值，可以利用del删除key-value，复制可以删除
list(tel)
sorted(tel)
'jack 'in tel
dict([('sape', 4139), ('guido', 4127), ('jack', 4098)])
{x:x**2 for x in range(23)}
# 字典的循环
for k,v in tel.items():
    print (k,v)
for i,v in enumerate(['sape','jake']):
    print(i,v)

#同时循环两个躲着多个序列，可以用zip（）函数意义匹配

#%%
#输入和输出问题
#1. 使用格式化字符串自勉之，需要在字符串开头的引号添加f
a=2016
b='referendm'
print(f'Result og tje {a} {b}')
#2. 利用str.format
#https://docs.python.org/zh-cn/3/library/string.html#formatstrings
print('Result og tje {} {}'.format(a,b))
#3.利用字符串切片和合并操作完成字符串处理操作，穿件任何排版

#%%
# 读写文件f=open('workfile','w')
#可选的mode用read、write。add。+表示文件打开进行读写，b表示二进制
# 从文键好写入或读取字符串很简单，数字则笔记爱哦麻烦，python支持
#javascript object notation
#json标准模块采用python数据层次结构，并将之转换为字符串表示形式，serializing序列化
#从字符串表示中重建数据成为deserializing
import json
x=[12,3,4,'simple','list']
json.dumps(x)
f=open('test.txt','r+')
json.dump(x,f)
