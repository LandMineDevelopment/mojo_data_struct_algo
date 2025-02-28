trait W_Comp_Coll(WritableCollectionElement,Comparable):
    ...

fn quick_sort[C: W_Comp_Coll](lst: List[C]) -> List[C]:
    if len(lst) == 1 or len(lst) == 0:
        return lst
    var left = List[C]()
    var right = List[C]()
    for i in range(1, len(lst)):
        if lst[i] < lst[0]:
            left.append(lst[i])
        else:
            right.append(lst[i])
    return quick_sort(left) + List[C](lst[0]) + quick_sort(right)

fn bucket_sort(mut lst: List[Int]):
    if len(lst) == 0 or len(lst) == 1: return
    var max = lst[0]
    var min = lst[0]

    for i in range(1,len(lst)):
        if lst[i] < min: min = lst[i]
        elif lst[i] > max: max = lst[i]
    
    var num_of_buckets = max-min + 1
    var bucket_list = List[Int](capacity=num_of_buckets)
    bucket_list.resize(num_of_buckets, 0)

    for i in range(len(lst)):
        bucket_list[lst[i]-min] += 1
    
    var pointer = 0
    for i in range(len(bucket_list)):
        for _ in range(bucket_list[i]):
            lst[pointer] = i + min
            pointer += 1

fn merge_inplace(mut a: List[Int], end: Int, owned a_small: Int, owned b_small: Int):
    var tmp: Int
    for curr in range(a_small, end+1):
        if a_small < curr: a_small = curr
        if a_small == b_small: return

        if a[b_small] < a[curr] and a[b_small] < a[a_small] and b_small < end+1:
            tmp = a[b_small]
            a[b_small] = a[curr]
            a[curr] = tmp
            if a_small == curr: a_small = b_small
            b_small += 1 
        
        elif a[a_small] < a[curr]:
            tmp = a[a_small]
            a[a_small] = a[curr]
            a[curr] = tmp
            if b_small - a_small > 1:
                a_small += 1

fn merge_sort(mut lst: List[Int]):
    merge_sort(lst,0,len(lst)-1)

fn merge_sort(mut lst: List[Int], start: Int, end: Int):
    if start >= end:
        # print('same:', start)
        return
    # print('s,e:',start,(end-start)//2 + start)
    # print_lst(lst)
    merge_sort(lst,start,(end-start)//2 + start)
    merge_sort(lst,(end-start)//2 + start + 1, end)
    # print('merge:', start,(end-start)//2 + start, end)
    merge_inplace(lst,end,start, (end-start)//2 + start +1)
    # print_lst(lst)


#######helper funcitons for testing
from random import random_si64
fn random_sorted_list(length: Int, max: Int) -> List[Int]:
    ret = List[Int](capacity = length)
    for _ in range(length):
        ret.append(Int(random_si64(0,max)))

    bucket_sort(ret)
    return ret
    
fn random_list(length: Int, max: Int) -> List[Int]:
    ret = List[Int](capacity = length)
    for _ in range(length):
        ret.append(Int(random_si64(0,max)))

    # bucket_sort(ret)
    return ret


fn check_sort(lst: List[Int]) -> Bool:
    var last = lst[0]
    for e in lst:
       if e[] < last: return False 
       last = e[]
    return True 
fn print_lst[C: W_Comp_Coll](lst: List[C]):
    var s = String('[')
    for i in range(len(lst)-1):
        s += String(lst[i], ',')
    s += String(lst[-1], ']') 
    print(s)


# def main():
#     l = List[Int](5,4,3,2,1,5,5)
#     # l = List[Int](1,2,3,4,5)
#     # l = List[Int](3,2,5,1,4)
#     # bucket_sort(l)
#     l = quick_sort(l)
#     print_lst(l)

