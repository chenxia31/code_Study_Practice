#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2021/8/8
# @Author  : chenxia
# @File    : L周赛5838.py
def isPrefixString(s, words) :
    chars=''
    temp=0
    for items in words:
        chars=chars+items
        if chars==s:
            temp=1
    if temp==1:
        return True
    else:
        return False

print(isPrefixString('ilove',['ie','love']))