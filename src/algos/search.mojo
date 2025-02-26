
fn binary_search(lst: List[Int], val: Int) -> Bool:
    if len(lst) == 0: return False
    var left = 0
    var right = len(lst) -1

    while left <= right:
        var mid = (right - left)//2 + left
        # print('mid:', mid)
        if val < lst[mid]:
            right = mid -1
        elif val > lst[mid]:
            left = mid + 1
        else:
            return True
    return False

def main():
    l = List[Int](0,1,2,3,4,5,27)
    print('true statements')
    print(binary_search(l,0)) 
    print(binary_search(l,1)) 
    print(binary_search(l,2)) 
    print(binary_search(l,3)) 
    print(binary_search(l,4)) 
    print(binary_search(l,5)) 
    print('false statements')
    print(binary_search(l,-1)) 
    print(binary_search(l,6)) 
    print(binary_search(l,7)) 