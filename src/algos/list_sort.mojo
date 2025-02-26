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

fn print_lst[C: W_Comp_Coll](lst: List[C]):
    var s = String('[')
    for i in range(len(lst)-1):
        s += String(lst[i], ',')
    s += String(lst[-1], ']') 
    print(s)


def main():
    l = List[Int](5,4,3,2,1,5,5)
    # l = List[Int](1,2,3,4,5)
    # l = List[Int](3,2,5,1,4)
    # bucket_sort(l)
    l = quick_sort(l)
    print_lst(l)

