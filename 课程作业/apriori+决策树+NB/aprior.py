#!/user/bin/env python
# -*- coding:utf-8 -*-
# author:Xu_Chenlong
# 2021-05-16
def apriori_is_fre(item_judge, database_target, k_is_fre):
    # 计算某一项在表中重复次数
    count = 0
    for key in database_target:
        count_temp = 0
        for value in item_judge:
            if value in database_target[key]:
                count_temp = count_temp + 1
        if count_temp == k_is_fre:
            count = count + 1
    return count


def apriori_gen(frequent_item_set_ori):
    # 由k阶频繁项集生成k+1阶潜在频繁项集，由于数目较少，未剪枝
    frequent_item_set_new = []
    fre_string = ''
    for item in frequent_item_set_ori:
        fre_string = fre_string + item
    fre_char = list(set(fre_string))
    for item in frequent_item_set_ori:
        for add_char in fre_char:
            if (add_char in item) == 0:
                frequent_item_set_new.append(''.join(sorted(item + add_char)))  # 对字符排序
    frequent_item_set_new = set(frequent_item_set_new)  # 删除重复元素
    return frequent_item_set_new


def apriori_subset(item_set_subset, k_subset, database_subset, support):
    # 从k阶潜在频繁项集筛选出k阶频繁项集
    frequent_item_set_subset = []
    for item in item_set_subset:
        if apriori_is_fre(item, database_subset, k_subset) >= len(database_subset) * support:
            frequent_item_set_subset.append(item)
    return frequent_item_set_subset


database = {'T100': 'MONKEY', 'T200': 'DONKEY', 'T300': 'MAKE', 'T400': 'MUCKY', 'T500': 'COOKIE'}
length = len(database)
min_sup = 0.6
min_conf = 0.8
# 生成初始项集
frequent_item_set = []
item_set = list(set(database['T100'] + database['T200'] + database['T300'] + database['T400'] + database['T500']))
k = 1
while len(item_set):
    frequent_item_set = apriori_subset(item_set, k, database, min_sup)
    item_set = apriori_gen(frequent_item_set)
    k = k + 1
print('The frequent  item sets is ', str(frequent_item_set))
count0 = apriori_is_fre(frequent_item_set[0], database, 3)
print('The support of the frequent item set is {}'.format(count0 / length))
print('--association rules--support--confidence')
for item in frequent_item_set[0]:
    count1 = apriori_is_fre(item, database, 1)
    if count1 <= (count0/min_conf):
        print('{}-->{}               {}           {}'.format(item, frequent_item_set[0].replace(item, ''),
                                                             (count1 / length),
                                                             count0 / count1))
    count2 = apriori_is_fre(frequent_item_set[0].replace(item,''), database, 2)
    if count2 <= (count0/min_conf):
        print('{}-->{}               {}           {}'.format(frequent_item_set[0].replace(item, ''), item,
                                                             count2 / length,
                                                             count0 / count2))
