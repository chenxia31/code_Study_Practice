def cal_square(x):
    if x==1:
        return 1
    else:
        return x*x+cal_square(x-1)

print(cal_square(100))